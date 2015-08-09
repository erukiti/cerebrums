assert = require 'power-assert'
sinon = require 'sinon'

Searcher = require '../src/searcher.coffee'

describe 'Searcher', ->
  it '#search', ->
    docs = [
      {meta: {uuid: 'hoge1', title: 'hogefuga'}, text: 'hoge fuga piyo'}
      {meta: {uuid: 'hoge2', title: 'abracadabra'}, text: 'abracadabra'}
      {meta: {uuid: 'hoge3', title: 'ほげふが'}, text: 'ほげ ふが ぴよ'}
    ]
    searcher = new Searcher(docs)

    assert.deepEqual searcher.search('h'), ['hoge1']
    assert.deepEqual searcher.search('a'), ['hoge1', 'hoge2']
    assert.deepEqual searcher.search('ほ'), ['hoge3']

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

