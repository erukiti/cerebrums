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

assert = require 'power-assert'
sinon = require 'sinon'

Searcher = require '../src/searcher.coffee'

describe 'Searcher', ->
  it '#search', ->
    meta1 = {uuid: 'hoge1', title: 'hogefuga', updatedAt: Date.parse('2015-07-14T00:00:00.000Z')}
    meta2 = {uuid: 'hoge2', title: 'abracadabra', updatedAt: Date.parse('2015-07-15T00:00:00.000Z')}
    meta3 = {uuid: 'hoge3', title: 'ほげふが', updatedAt: Date.parse('2015-07-12T00:00:00.000Z')}
    docs = [
      {meta: meta1, text: 'hoge fuga piyo'}
      {meta: meta2, text: 'abracadabra'}
    ]
    searcher = new Searcher(docs)

    assert.deepEqual searcher.search('h'), [meta1]
    assert.deepEqual searcher.search('a'), [meta1, meta2]
    assert.deepEqual searcher.search('ほ'), []

    searcher.add(meta3, 'ほげ ふが ぴよ')

    console.dir searcher.search('')


  it '#recent', ->
    meta1 = {uuid: 'hoge1', title: 'hogefuga', updatedAt: Date.parse('2015-07-14T00:00:00.000Z')}
    meta2 = {uuid: 'hoge2', title: 'abracadabra', updatedAt: Date.parse('2015-07-15T00:00:00.000Z')}
    meta3 = {uuid: 'hoge3', title: 'ほげふが', updatedAt: Date.parse('2015-07-12T00:00:00.000Z')}

    docs = [
      {meta: meta1, text: 'hoge fuga piyo'}
      {meta: meta2, text: 'abracadabra'}
      {meta: meta3, text: 'ほげ ふが ぴよ'}
    ]
    searcher = new Searcher(docs)

    assert.deepEqual searcher.getRecent(), [meta2, meta1, meta3]

