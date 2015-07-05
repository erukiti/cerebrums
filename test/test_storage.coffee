assert = require 'power-assert'
sinon = require 'sinon'

uuidv4 = require 'uuid-v4'
sha256 = require 'sha256'
Rx = require 'rx'
msgpack = require 'msgpack'

Storage = require '../src/storage.coffee'

describe 'Storage', ->
  describe '#create(writeObservable)', ->
    it 'normal case', ->
      class DummyRawDriver
        constructor: ->
          @writeBlobCounter = 0
          @writePointerCounter = 0

        writeBlob: (hash, content) ->
          switch @writeBlobCounter
            when 0 
              assert hash == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
              assert content == 'hogefuga'
            when 1
              meta = msgpack.unpack(content)
              assert meta.sha256 == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
              @hash = hash
            when 2
              assert hash == '34bc1d987ef7374f827c850728e0305d564afe73698bf928c4f7d7b4151e6831'
              assert content == 'fugahoge'
            when 3
              meta = msgpack.unpack(content)
              assert meta.sha256 == '34bc1d987ef7374f827c850728e0305d564afe73698bf928c4f7d7b4151e6831'
              @hash = hash

          @writeBlobCounter++
          Rx.Observable.just(hash)

        writePointer: (uuid, content) ->
          assert uuidv4.isUUID(uuid)
          assert content == @hash
          @writePointerCounter++
          Rx.Observable.just(@writePointerCounter)

        verify: ->
          assert @writeBlobCounter == 4 && @writePointerCounter == 2

      dummyObservable = {}
      dummyRawDriver = new DummyRawDriver()

      writeObservable = Rx.Observable.from([{
        type: 'save'
        meta: {title: 'hoge'}
        content: 'hogefuga'
      }, {
        type: 'save'
        meta: {title: 'fuga'}
        content: 'fugahoge'
      }])

      storage = new Storage(dummyRawDriver)
      Rx.Observable.merge(
        storage.create(writeObservable),
        Rx.Observable.empty()
      ).toArray().subscribe (x) ->
        console.dir x

      dummyRawDriver.verify()


  describe '#open(uuid)', ->
    it 'normal', ->
      class DummyRawDriver
        constructor: ->
          @readPointerCounter = 0
          @readBlobCounter = 0
          @writePointerCounter = 0
          @writeBlobCounter = 0

        readPointer: (uiud) ->
          assert uuid = '1111'
          @readPointerCounter++
          Rx.Observable.just('2222')

        readBlob: (hash) ->
          assert hash = '2222'
          @readBlobCounter++
          Rx.Observable.just(msgpack.pack({sha256: '4444', title: 'hoge'}))

        writeBlob: (hash, content) ->
          if @writeBlobCounter == 0
            assert hash == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
            assert content == 'hogefuga'
          else
            meta = msgpack.unpack(content)
            assert meta.sha256 == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
            assert meta.prevSha256 == '4444'
            @hash = hash

          @writeBlobCounter++
          Rx.Observable.just(hash)

        writePointer: (uuid, content) ->
          assert uuid = '1111'
          assert content == @hash
          @writePointerCounter++
          Rx.Observable.just(2)

        verify: ->
          assert @writeBlobCounter == 2 && 
          　　　　@writePointerCounter == 1　&&
                 @readBlobCounter == 1 &&
                 @readPointerCounter == 1

      dummyObservable = {}
      dummyRawDriver = new DummyRawDriver()

      # storage = new Storage(dummyRawDriver)
      # storage.open('1111', writeObservable).subscribe (x) =>
      #   console.dir x

      # dummyRawDriver.verify()

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
