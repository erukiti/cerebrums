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

    w = writeObservable
      .filter((packet) => packet.type == 'change')
      .distinctUntilChanged()
    w.buffer(w.throttle(1000))
      .filter (list) =>
        # work a round. でもこれがなぜ発生するかわからない
        list.length > 0
      .map (list) => 
        list[list.length - 1]
      .subscribe (packet) =>
        packed = msgpack.encode({meta: packet.meta, content: packet.content})
        rawDriver.writeTemp(uuid, packed).subscribe (x) =>
          # console.log("temp saved #{uuid}")
          ;
        , (err) => console.error err

    writeObservable.filter((packet) => packet.type == 'save').subscribe((packet) =>
      content = new Buffer(packet.content)
      contentHash = sha256(content)
      rawDriver.writeBlob(contentHash, content).subscribe((x) =>
        meta = packet.meta
        meta.sha256 = contentHash
        meta.size = content.length
        meta.createdAt = (new Date()).toISOString() unless prevHash
        meta.updatedAt = (new Date()).toISOString()
        meta.prevSha256 = prevHash if prevHash
        meta.uuid = uuid
        meta.version = 1
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

    writeObservable
      .subscribe (packet) =>
        if packet.type == 'close'
          subscriber.onCompleted()
      , (err) => console.error (err)
      , => subscriber.onCompleted()

  create: (uuid, writeObservable) ->
    Rx.Observable.create (subscriber) =>
      console.log "create: #{uuid}"
      writeObservable = writeObservable.publish()
      writeObservable.connect()

      subscriber.onNext {type: 'uuid', uuid: uuid}
      @_write(@rawDriver, uuid, writeObservable, subscriber)

  open: (uuid, writeObservable) ->
    Rx.Observable.create (subscriber) =>
      console.log "open: #{uuid}"
      writeObservable = writeObservable.publish()
      writeObservable.connect()

      @rawDriver.readPointer(uuid).subscribe (metaHash) =>
        @rawDriver.readBlob(metaHash).subscribe (metaMsgpack) =>
          meta = msgpack.decode(metaMsgpack)
          contentHash = meta.sha256
          delete meta.sha256
          subscriber.onNext {type: 'meta', meta: meta}

          @rawDriver.readBlob(contentHash).subscribe (content) =>
            subscriber.onNext({type: 'content', content: content})
          , (err) => subscriber.onError(err)

          @_write(@rawDriver, uuid, writeObservable, subscriber, contentHash)

        , (err) => subscriber.onError(err)
      , (err) =>
        if err.code == 'ENOENT'
          subscriber.onNext {type: 'notfound'}
        else
          subscriber.onError(err)


  tabs: (obs) ->
    obs.subscribe (list) =>
      packed = msgpack.encode(list)
      @rawDriver.writeTemp('tabs', packed).subscribe (x) =>
        ;
      , (err) => console.error err

  readTabs: ->
    @rawDriver.readTemp('tabs').map (packed) =>
      msgpack.decode(packed)

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
