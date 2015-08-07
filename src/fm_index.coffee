WaveletMatrix = require './wavelet_matrix.coffee'
BWT = require './bwt.coffee'

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
      console.dir ary

      for a in ary
        if s[a - 1]
          result.push s[a - 1]
        else
          last = ind
          result.push 0
        ind++

      console.dir result
      console.dir last
      @bwt = new WaveletMatrix(result)
      @last = last

    @usedChars = []
    n = 2
    for doc in documents
      for ch in doc.text
        @usedChars[ch.charCodeAt(0)] = n++ unless @usedChars[ch.charCodeAt(0)]

    s = []
    for doc in documents
      for ch in doc.text
        s.push @usedChars[ch.charCodeAt(0)]
      s.push 1
    s.push 0

    _encode(s)
    @bwtLength = s.length

    console.dir s

  decode: ->
    _lf = (ind, c) =>
      @bwt.rank(ind, c) + @bwt.rankLessThan(@bwtLength, c)

    ind = @last
    result = []
    i = 0
    while i < @bwtLength
      result.unshift @bwt.get(ind)
      ind = _lf(ind, @bwt.get(ind))
      i++
    result

    # s = ''
    # for ind in result
    #   s += @usedChars[]

  search: (query) ->
    _lf = (ind, c) =>
      @bwt.rank(ind, c) + @bwt.rankLessThan(@bwtLength, c)

    q = []
    for ch in query
      unless @usedChars[ch.charCodeAt(0)]
        return []
      else
        q.push @usedChars[ch.charCodeAt(0)]

    start = 0
    end = @bwtLength

    i = q.length - 1
    while i >= 0
      c = q[i]
      start = _lf(start, c)
      end = _lf(end, c)
      return [] if start >= end
      i--

    for ind in [start...end]
      pos = 0
      while @bwt.get(ind) != 0
        console.dir ind
        ind = _lf(ind, @bwt.get(ind))
        pos++
      pos

module.exports = FmIndex
