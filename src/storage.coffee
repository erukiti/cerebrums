Rx = require 'rx'
sha256 = require 'sha256'
uuidv4 = require 'uuid-v4'
msgpack = require 'msgpack'

File = require './file.coffee'

class Storage
  constructor: (rawDriver) ->
    @rawDriver = rawDriver

  _write = (rawDriver, file, writeObservable, subscriber, prevHash) ->
    return unless writeObservable
    writeObservable.subscribe (packet) =>
      file.content = packet.content
      contentHash = sha256(file.content)
      rawDriver.writeBlob(contentHash, file.content).subscribe (x) =>
        meta = packet.meta
        meta.sha256 = contentHash
        meta.prevSha256 = prevHash if prevHash
        metaMsgpack = msgpack.pack(meta)
        metaHash = sha256(packet.content)
        rawDriver.writeBlob(metaHash, metaMsgpack).subscribe (x) =>
          rawDriver.writePointer(file.uuid, metaHash).subscribe (x) =>
            prevHash = contentHash
            subscriber.onNext({type: 'saved'})

  create: (writeObservable) ->
    Rx.Observable.create (subscriber) =>
      _write(@rawDriver, new File(uuidv4()), writeObservable, subscriber)

  open: (uuid, writeObservable) ->
    Rx.Observable.create (subscriber) =>
      @rawDriver.readPointer(uuid).subscribe (metaHash) =>
        @rawDriver.readBlob(metaHash).subscribe (metaMsgpack) =>
          meta = msgpack.unpack(metaMsgpack)
          contentHash = meta.sha256
          delete meta.sha256
          meta.type = 'meta'
          subscriber.onNext(meta)

          @rawDriver.readBlob(contentHash).subscribe (content) =>
            subscriber.onNext({type: 'content', content: content})
          , (err) => onError(err)

          _write(@rawDriver, new File(uuid), writeObservable, subscriber, contentHash)

        , (err) => onError(err)
      , (err) => onError(err)

  getRecent: ->
    

module.exports = Storage
