assert = require 'power-assert'
sinon = require 'sinon'

FS = require '../src/fs.coffee'

class Dummy
  blobWrite: (hash, content, func) ->
    assert hash == "4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75"
    assert content == "hogefuga"
    func()

  metaWrite: () ->


describe 'FS', ->
  it '#create', ->
    dummy = new Dummy()
    fs = new FS(dummy)
    # assert fs.create("hogefuga") == "hoge"
