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

