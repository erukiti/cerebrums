

sha256 = require 'sha256'
uuidv4 = require 'uuid-v4'

class Storage
  constructor: (rawDriver) ->
    @rawDriver = rawDriver

  create: (content, func) ->
    dataHash = sha256(content)
    @rawDriver.writeBlob(dataHash, content).flatMap (x) =>
      meta = {
        sha256: dataHash
      }
      metaJson = JSON.stringify(meta)
      metaHash = sha256(metaJson)
      @rawDriver.writeBlob(metaHash, metaJson).flatMap (x) =>
        uuid = uuidv4()
        @rawDriver.writePointer(uuid, metaHash)

  read: (uuid) ->
    @rawDriver.readPointer(uuid).flatMap (metaHash) =>
      @rawDriver.readBlob(metaHash).flatMap (metaJson) =>
        meta = JSON.parse(metaJson)
        @rawDriver.readBlob(meta.sha256)

  update: (uuid, content) ->
    @rawDriver.readPointer(uuid).flatMap (metaHash) =>
      @rawDriver.readBlob(metaHash).flatMap (metaJson) =>
        meta = JSON.parse(metaJson)
        dataHash = sha256(content)
        @rawDriver.writeBlob(dataHash, content).flatMap (x) =>
          meta.sha256 = dataHash
          metaJson = JSON.stringify(meta)
          metaHash = sha256(metaJson)
          @rawDriver.writeBlob(metaHash, metaJson).flatMap (x) =>
            @rawDriver.writePointer(uuid, metaHash)

module.exports = Storage
