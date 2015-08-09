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
    docs = [
      {meta: {uuid: 'hoge1', title: 'hogefuga', updatedAt: Date.parse('2015-07-14T00:00:00.000Z')}, text: 'hoge fuga piyo'}
      {meta: {uuid: 'hoge2', title: 'abracadabra', updatedAt: Date.parse('2015-07-15T00:00:00.000Z')}, text: 'abracadabra'}
      {meta: {uuid: 'hoge3', title: 'ほげふが', updatedAt: Date.parse('2015-07-12T00:00:00.000Z')}, text: 'ほげ ふが ぴよ'}
    ]
    searcher = new Searcher(docs)

    assert.deepEqual searcher.recent(), ['hoge2', 'hoge1', 'hoge3']

