assert = require 'power-assert'
sinon = require 'sinon'

uuidv4 = require 'uuid-v4'
sha256 = require 'sha256'
Rx = require 'rx'
msgpack = require 'msgpack'

Storage = require '../src/storage.coffee'

describe 'Storage', ->
  it '#create', ->
    class DummyRawDriver
      constructor: ->
        @writeBlobCounter = 0
        @writePointerCounter = 0

      writeBlob: (hash, content) ->
        if @writeBlobCounter == 0
          assert hash == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
          assert content == 'hogefuga'
        else
          meta = JSON.parse(content)
          assert meta.sha256 == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
          @hash = hash
        @writeBlobCounter++
        Rx.Observable.just(hash)

      writePointer: (uuid, content) ->
        assert uuidv4.isUUID(uuid)
        assert content == @hash
        @writePointerCounter++
        Rx.Observable.just(2)

      verify: ->
        assert @writeBlobCounter == 2 && @writePointerCounter == 1

    dummyObservable = {}
    dummyRawDriver = new DummyRawDriver()

    storage = new Storage(dummyRawDriver)
    storage.create('hogefuga').subscribe (x) ->
      assert x == 2

    dummyRawDriver.verify()

  it '#read(uuid)', ->
    meta = {sha256: '4444'}
    dummyFunc = -> null
    dummyRawDriver = {readPointer: dummyFunc, readBlob: dummyFunc}
    stubReadPointer = sinon.stub(dummyRawDriver, 'readPointer')
    stubReadBlob = sinon.stub(dummyRawDriver, 'readBlob')
    stubReadPointer.withArgs('1111').returns(Rx.Observable.just('2222'))
    stubReadBlob.withArgs('2222').returns(Rx.Observable.just(JSON.stringify(meta)))
    stubReadBlob.withArgs('4444').returns(Rx.Observable.just('hogefuga'))

    storage = new Storage(dummyRawDriver)
    storage.read('1111').subscribe (data) ->
      assert data == 'hogefuga'

    assert stubReadPointer.calledOnce
    assert stubReadBlob.calledTwice

  describe '#open(uuid)', ->
    it 'read normal', ->
      meta = {sha256: '4444', title: 'hoge'}
      dummyFunc = -> null
      dummyRawDriver = {readPointer: dummyFunc, readBlob: dummyFunc}
      stubReadPointer = sinon.stub(dummyRawDriver, 'readPointer')
      stubReadBlob = sinon.stub(dummyRawDriver, 'readBlob')
      stubReadPointer.withArgs('1111').returns(Rx.Observable.just('2222'))
      stubReadBlob.withArgs('2222').returns(Rx.Observable.just(msgpack.pack(meta)))
      stubReadBlob.withArgs('4444').returns(Rx.Observable.just('hogefuga'))

      storage = new Storage(dummyRawDriver)
      storage.open('1111').read.toArray().subscribe (data) ->
        assert.deepEqual data, [
          {type: 'meta', title: 'hoge'},
          {type: 'content', content: 'hogefuga'}
        ]

      assert stubReadPointer.calledOnce
      assert stubReadBlob.calledTwice


  it '#update', ->
    meta = {sha256: '4444'}
    dummyFunc = -> null
    dummyRawDriver = {readPointer: dummyFunc, readBlob: dummyFunc, writePointer: dummyFunc, writeBlob: dummyFunc}
    stubReadPointer = sinon.stub(dummyRawDriver, 'readPointer')
    stubReadBlob = sinon.stub(dummyRawDriver, 'readBlob')
    stubWritePointer = sinon.stub(dummyRawDriver, 'writePointer')
    stubWriteBlob = sinon.stub(dummyRawDriver, 'writeBlob')
    stubReadPointer.withArgs('1111').returns(Rx.Observable.just('2222'))
    stubReadBlob.withArgs('2222').returns(Rx.Observable.just(JSON.stringify(meta)))
    stubWriteBlob.withArgs('4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75', 'hogefuga').returns(Rx.Observable.just(1))
    meta.sha256 = '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
    metaJson = JSON.stringify(meta)
    stubWriteBlob.withArgs(sha256(metaJson), metaJson).returns(Rx.Observable.just(2))
    stubWritePointer.withArgs('1111', sha256(metaJson)).returns(Rx.Observable.just(3))

    storage = new Storage(dummyRawDriver)
    storage.update('1111', 'hogefuga').subscribe (x) ->
      assert x == 3
    
    assert stubReadPointer.calledOnce
    assert stubReadBlob.calledOnce
    assert stubWriteBlob.calledTwice
    assert stubWritePointer.calledOnce
