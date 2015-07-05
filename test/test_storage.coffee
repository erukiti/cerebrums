assert = require 'power-assert'
sinon = require 'sinon'

uuidv4 = require 'uuid-v4'
sha256 = require 'sha256'
Rx = require 'rx'
msgpack = require 'msgpack'

Storage = require '../src/storage.coffee'

describe 'Storage', ->
  describe '#create(writeObservable)', ->
    it 'normal', ->
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
              assert meta.title == 'hoge'
              @hash = hash
            when 2
              assert hash == '34bc1d987ef7374f827c850728e0305d564afe73698bf928c4f7d7b4151e6831'
              assert content == 'fugahoge'
            when 3
              meta = msgpack.unpack(content)
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

      storage = new Storage(dummyRawDriver)
      Rx.Observable.merge(
        storage.create(writeObservable),
        Rx.Observable.empty()
      ).toArray().subscribe (x) ->
        console.dir x

      dummyRawDriver.verify()

  describe '#open(uuid, writeObservable)', ->
    it 'normal', ->
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
              assert meta.prevSha256 == '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75'
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

