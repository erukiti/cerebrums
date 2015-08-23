ipc = require 'ipc'
uuidv4 = require 'uuid-v4'

class StorageWrapper
  constructor: ->
    @observer = Rx.Observable.create (obs) =>
      ipc.on 'storage', (packet) =>
        obs.onNext packet
    .publish()

    @observer.connect()

  open: (uuid, writeStream) ->
    ipc.send 'storage', {
      type: 'open',
      uuid: uuid
    }

    if writeStream
      writeStream.subscribe (packet) =>
        ipc.send "storage-#{uuid}", packet

    @observer
      .filter (packet) => packet.uuid == uuid

  create: (uuid, writeStream) ->
    ipc.send 'storage', {
      type: 'create',
      uuid: uuid
    }

    if writeStream
      writeStream.subscribe (packet) =>
        ipc.send "storage-#{uuid}", packet

    @observer
      .filter (packet) => packet.uuid == uuid

  search: (query) ->
    uuid = uuidv4()
    ipc.send 'storage', {
      type: 'search'
      query: query
      uuid: uuid
    }

    @observer
      .filter((packet) => packet.uuid == uuid)
      .map (packet) => packet.meta

  getRecent: ->
    uuid = uuidv4()
    ipc.send 'storage', {
      type: 'getRecent'
      uuid: uuid
    }

    @observer
      .filter((packet) => packet.uuid == uuid)
      .map (packet) => packet.meta

  tabs: (tabArray) ->
    ipc.send 'storage', {
      type: 'tabs',
      tabs: tabArray
    }
# - temp 読み取り


storage = new StorageWrapper()
console.error 'new'

module.exports = storage
