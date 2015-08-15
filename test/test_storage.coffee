assert = require 'power-assert'
sinon = require 'sinon'

uuidv4 = require 'uuid-v4'
sha256 = require 'sha256'
Rx = require 'rx'
msgpack = require 'msgpack-js'

Storage = require '../src/storage.coffee'

describe 'Storage', ->
  describe '#create(writeObservable)', ->
    it 'normal', ->
      fakeTime = Date.parse('2015-07-12T00:00:00.000Z')
      fakeTimeStr = (new Date(fakeTime)).toISOString()

      class DummyRawDriver
        constructor: ->
          @writePointerCounter = 0
          @writeBlobCounter = 0

        getAllPointer: ->
          Rx.Observable.empty()

        writeBlob: (hash, content) ->
          switch @writeBlobCounter
            when 0 
              assert hash == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
              assert content == 'hogefuga'
            when 1
              meta = msgpack.decode(content)
              assert meta.sha256 == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
              assert meta.createdAt == fakeTimeStr
              assert meta.updatedAt == fakeTimeStr
              assert meta.title == 'hoge'
              @hash = hash
            when 2
              assert hash == '34bc1d987ef7374f827c850728e0305d564afe73698bf928c4f7d7b4151e6831'
              assert content == 'fugahoge'
            when 3
              meta = msgpack.decode(content)
              assert meta.sha256 == '34bc1d987ef7374f827c850728e0305d564afe73698bf928c4f7d7b4151e6831'
              assert meta.prevSha256 == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
              assert meta.title == 'fuga'
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

      clock = sinon.useFakeTimers(fakeTime)

      result = []
      storage = new Storage(dummyRawDriver)
      storage.create(writeObservable).subscribe (x) ->
        result.push x

      assert result.length == 3
      assert result[0].type == 'uuid'
      assert result[1].type == 'saved'
      assert result[2].type == 'saved'

      dummyRawDriver.verify()

      clock.restore()

  describe '#open(uuid, writeObservable)', ->
    it 'normal', ->
      fakeTime = Date.parse('2015-07-12T00:00:00.000Z')
      fakeTimeStr = (new Date(fakeTime)).toISOString()

      class DummyRawDriver
        constructor: ->
          @readPointerCounter = 0
          @readBlobCounter = 0
          @writePointerCounter = 0
          @writeBlobCounter = 0

        getAllPointer: ->
          Rx.Observable.empty()

        readPointer: (uuid) ->
          assert uuid == '1111'
          @readPointerCounter++
          Rx.Observable.just('2222')

        readBlob: (hash) ->
          switch @readBlobCounter
            when 0
              assert hash == '2222'
              @readBlobCounter++
              Rx.Observable.just(msgpack.encode({sha256: '4444', title: 'hoge', createdAt: '2015-07-11T00:00:00.000Z', updatedAt: '2015-07-11T00:00:00.000Z'}))
            when 1
              assert hash == '4444'
              @readBlobCounter++
              Rx.Observable.just('hogefuga')

        writeBlob: (hash, content) ->
          switch @writeBlobCounter
            when 0
              assert hash == '34bc1d987ef7374f827c850728e0305d564afe73698bf928c4f7d7b4151e6831'
              assert content == 'fugahoge'
            when 1
              meta = msgpack.decode(content)
              assert meta.sha256 == '34bc1d987ef7374f827c850728e0305d564afe73698bf928c4f7d7b4151e6831'
              assert meta.createdAt == '2015-07-11T00:00:00.000Z'
              assert meta.updatedAt == fakeTimeStr
              assert meta.prevSha256 == '4444'
              assert meta.title == 'fuga'
              @hash = hash

          @writeBlobCounter++
          Rx.Observable.just(hash)

        writePointer: (uuid, content) ->
          assert uuid == '1111'
          assert content == @hash
          @writePointerCounter++
          Rx.Observable.just(@writePointerCounter)

        verify: ->
          assert @readPointerCounter == 1 &&
            @readBlobCounter == 2 &&
            @writePointerCounter == 1 &&
            @writeBlobCounter == 2

      dummyObservable = {}
      dummyRawDriver = new DummyRawDriver()

      writeObservable = Rx.Observable.from([{
        type: 'save'
        meta: {title: 'fuga', createdAt: '2015-07-11T00:00:00.000Z', updatedAt: '2015-07-11T00:00:00.000Z'}
        content: 'fugahoge'
      }])

      clock = sinon.useFakeTimers(fakeTime)

      result = []
      storage = new Storage(dummyRawDriver)
      storage.open('1111', writeObservable).subscribe (x) ->
        result.push x

      assert.deepEqual result, [
        {type: 'meta', title: 'hoge', createdAt: '2015-07-11T00:00:00.000Z', updatedAt: '2015-07-11T00:00:00.000Z'},
        {type: 'content', content: 'hogefuga'},
        {type: 'saved'}
      ]

      dummyRawDriver.verify()
  
      clock.restore()

  describe '#getRecent', ->
    meta1 = {uuid: '1111', title: 'hoge', sha256: '5555'}
    meta2 = {uuid: '2222', title: 'fuga', sha256: '6666'}
    dummyFunc = -> null
    dummyRawDriver = {getAllPointer: dummyFunc, readPointer: dummyFunc, readBlob: dummyFunc}
    stubGetAllPointer = sinon.stub(dummyRawDriver, 'getAllPointer')
    stubGetAllPointer.withArgs().returns(Rx.Observable.from(['1111', '2222']))
    stubReadPointer = sinon.stub(dummyRawDriver, 'readPointer')
    stubReadPointer.withArgs('1111').returns(Rx.Observable.just('3333'))
    stubReadPointer.withArgs('2222').returns(Rx.Observable.just('4444'))
    stubReadBlob = sinon.stub(dummyRawDriver, 'readBlob')
    stubReadBlob.withArgs('3333').returns(Rx.Observable.just(msgpack.encode(meta1)))
    stubReadBlob.withArgs('4444').returns(Rx.Observable.just(msgpack.encode(meta2)))
    stubReadBlob.withArgs('5555').returns(Rx.Observable.just('hoge hoge'))
    stubReadBlob.withArgs('6666').returns(Rx.Observable.just('fuga fuga'))

    storage = new Storage(dummyRawDriver)
    storage.getRecent().toArray().subscribe (x) ->
      assert.deepEqual x, [meta1, meta2]

    assert stubGetAllPointer.calledOnce
    assert stubReadPointer.calledTwice
    assert stubReadBlob.called

  describe '#search', ->
    meta1 = {uuid: '1111', title: 'hoge', sha256: '5555'}
    meta2 = {uuid: '2222', title: 'fuga', sha256: '6666'}
    dummyFunc = -> null
    dummyRawDriver = {getAllPointer: dummyFunc, readPointer: dummyFunc, readBlob: dummyFunc}
    stubGetAllPointer = sinon.stub(dummyRawDriver, 'getAllPointer')
    stubGetAllPointer.withArgs().returns(Rx.Observable.from(['1111', '2222']))
    stubReadPointer = sinon.stub(dummyRawDriver, 'readPointer')
    stubReadPointer.withArgs('1111').returns(Rx.Observable.just('3333'))
    stubReadPointer.withArgs('2222').returns(Rx.Observable.just('4444'))
    stubReadBlob = sinon.stub(dummyRawDriver, 'readBlob')
    stubReadBlob.withArgs('3333').returns(Rx.Observable.just(msgpack.encode(meta1)))
    stubReadBlob.withArgs('4444').returns(Rx.Observable.just(msgpack.encode(meta2)))
    stubReadBlob.withArgs('5555').returns(Rx.Observable.just('hoge hoge'))
    stubReadBlob.withArgs('6666').returns(Rx.Observable.just('fuga fuga'))

    storage = new Storage(dummyRawDriver)
    storage.search('hoge').toArray().subscribe (x) ->
      assert.deepEqual x, [meta1]

    assert stubGetAllPointer.calledOnce
    assert stubReadPointer.calledTwice
    assert stubReadBlob.called


