Rx = require 'rx'
sha256 = require 'sha256'
uuidv4 = require 'uuid-v4'
msgpack = require 'msgpack-js'

Searcher = require './searcher.coffee'

class Storage
  constructor: (rawDriver) ->
    @rawDriver = rawDriver
    @searcher = new Searcher([])

    docs = []
    @rawDriver.getAllPointer().flatMap (uuid) =>
      @rawDriver.readPointer(uuid).flatMap (metaHash) =>
        @rawDriver.readBlob(metaHash).flatMap (metaMsgpack) =>
          meta = msgpack.decode(metaMsgpack)
          meta.uuid = uuid
          @rawDriver.readBlob(meta.sha256).map (content) =>
            {meta: meta, text: content.toString('utf-8')}
    .toArray()
    .subscribe (docs) =>
      @searcher = new Searcher(docs)

  _write: (rawDriver, uuid, writeObservable, subscriber, prevHash) =>
    return unless writeObservable
    w = writeObservable.filter((packet) => packet.type == 'change' || packet.type == 'save')
    w.buffer(w.throttle(1000))
      .map (list) => list[list.length - 1]
      .subscribe (packet) =>
        console.dir packet
        packed = msgpack.encode({meta: packet.meta, content: packet.content})
        rawDriver.writeTemp(uuid, packed).subscribe (x) =>
          console.dir("temp saved #{uuid}")
        , (err) => console.error err

    writeObservable.filter((packet) => packet.type == 'save').subscribe((packet) =>
      content = packet.content
      contentHash = sha256(content)
      rawDriver.writeBlob(contentHash, content).subscribe((x) =>
        meta = packet.meta
        meta.sha256 = contentHash
        meta.createdAt = (new Date()).toISOString() unless prevHash
        meta.updatedAt = (new Date()).toISOString()
        meta.prevSha256 = prevHash if prevHash
        meta.uuid = uuid
        metaMsgpack = msgpack.encode(meta)
        metaHash = sha256(metaMsgpack)

        @searcher.add(meta, content)

        rawDriver.writeBlob(metaHash, metaMsgpack).subscribe((x) =>
          rawDriver.writePointer(uuid, metaHash).subscribe((x) =>
            prevHash = contentHash
            subscriber.onNext({type: 'saved'})
          , (err) => console.error err
          )
        , (err) => console.error err
        )
      , (err) => console.error err
      )
    , (err) => console.error err
    )

  create: (writeObservable) ->
    Rx.Observable.create (subscriber) =>
      uuid = uuidv4()
      console.log "create: #{uuid}"
      subscriber.onNext {type: 'uuid', uuid: uuid}
      @_write(@rawDriver, uuid, writeObservable, subscriber)

  open: (uuid, writeObservable) ->
    Rx.Observable.create (subscriber) =>
      console.log "open: #{uuid}"
      @rawDriver.readPointer(uuid).subscribe (metaHash) =>
        @rawDriver.readBlob(metaHash).subscribe (metaMsgpack) =>
          meta = msgpack.decode(metaMsgpack)
          contentHash = meta.sha256
          delete meta.sha256
          meta.type = 'meta'
          subscriber.onNext(meta)

          @rawDriver.readBlob(contentHash).subscribe (content) =>
            subscriber.onNext({type: 'content', content: content})
          , (err) => subscriber.onError(err)

          @_write(@rawDriver, uuid, writeObservable, subscriber, contentHash)

        , (err) => subscriber.onError(err)
      , (err) => subscriber.onError(err)

  getRecent: ->
    Rx.Observable.create (subscriber) =>
      for meta in @searcher.getRecent()
        subscriber.onNext meta
      subscriber.onCompleted()

  search: (query) ->
    Rx.Observable.create (subscriber) =>
      for meta in @searcher.search(query)
        subscriber.onNext(meta)
      subscriber.onCompleted()

module.exports = Storage
