# Copyright 2015 SASAKI, Shunsuke. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

WaveletMatrix = require './wavelet_matrix.coffee'

class FmIndex
  constructor: (documents) ->

    _encode = (s) =>
      ary = [0..s.length - 1].sort (a, b) =>
         while true
          return -1 if s[a] == 0
          return 1 if s[b] == 0
          return -1 if s[a] < s[b]
          return 1 if s[a] > s[b]
          a++
          b++

      # console.dir ary
      result = []
      ind = 0
      last = null

      for a in ary
        if s[a - 1]
          result.push s[a - 1]
        else
          last = ind
          result.push 0
        ind++

      @bwt = new WaveletMatrix(result)
      @last = last

    @usedChars = []
    n = 2
    for doc in documents
      if doc.text
        for ch in doc.text
          @usedChars[ch.charCodeAt(0)] = n++ unless @usedChars[ch.charCodeAt(0)]

    s = []
    @metaArray = []
    for doc in documents
      if doc.text
        for ch in doc.text
          s.push @usedChars[ch.charCodeAt(0)]
        s.push 1
        @metaArray.push {uuid: doc.uuid}
    s.pop() # 最後の1を捨てる
    s.push 0

    _encode(s)
    @bwtLength = s.length

    ind = @last
    metaInd = @metaArray.length - 1

    @wayPoints = []
    @wayPointsPerFile = []

    _lf = (ind, c) =>
      @bwt.rank(ind, c) + @bwt.rankLessThan(@bwtLength, c)

    i = 0
    wayPoints = []
    while i < @bwtLength
      c = @bwt.get(ind)
      # console.log "#{ind}: #{c}"
      if ind % 16 == 0
        wayPoints.push {ind: ind, i: i}

      if c == 1
        for wayPoint in wayPoints
          @wayPoints[wayPoint.ind >> 4] = {meta: metaInd, ind: i - wayPoint.i}

        @wayPointsPerFile[ind] = metaInd
        metaInd--
        wayPoints = []

      ind = _lf(ind, c)
      i++

    for wayPoint in wayPoints
      @wayPoints[wayPoint.ind >> 4] = {meta: metaInd, ind: i - wayPoint.i}

    @wayPointsPerFile[ind] = metaInd

  search: (query, max = 0) ->
    _lf = (ind, c) =>
      @bwt.rank(ind, c) + @bwt.rankLessThan(@bwtLength, c)

    q = []
    for ch in query
      unless @usedChars[ch.charCodeAt(0)]
        return {hits: 0, results:[]}
      else
        q.push @usedChars[ch.charCodeAt(0)]

    start = 0
    end = @bwtLength

    i = q.length - 1
    while i >= 0
      c = q[i]
      start = _lf(start, c)
      end = _lf(end, c)
      return {hits: 0, results:[]} if start >= end
      i--

    if max > 0 && end - start > max
      return {hits: end - start, results: []}

    results = for ind in [start...end]
      pos = 0
      metaInd = 0
      while (c = @bwt.get(ind)) != 0
        if (c == 1)
          metaInd = @wayPointsPerFile[ind]
          break

        if ind % 16 == 0
          wp = @wayPoints[ind >> 4]
          metaInd = wp.meta
          pos += wp.ind
          break

        ind = _lf(ind, c)
        pos++
      {uuid: @metaArray[metaInd].uuid, pos: pos}

    {hits: end - start, results: results}

module.exports = FmIndex
