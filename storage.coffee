ipc = require 'ipc'
uuidv4 = require 'uuid-v4'
_ = require 'underscore'

class StorageWrapper
  constructor: ->
    @observer = Rx.Observable.create (obs) =>
      ipc.on 'storage', (packet) =>
        obs.onNext packet
    .publish()

    @observer.connect()

    @intercept = []

  open: (uuid, writeStream) ->
    ipc.send 'storage', {
      type: 'open',
      uuid: uuid
    }

    if writeStream
      writeStream.subscribe (packet) =>
        if packet.type == 'change' || packet.type == 'save'
          # console.warn "temp save #{uuid}"
          localStorage.setItem uuid, JSON.stringify(packet)

        ipc.send "storage-#{uuid}", packet

    @observer
      .filter (packet) => packet.uuid == uuid
      .flatMap (packet) =>
        switch packet.type
          when 'meta'
            if @intercept[uuid]
              # console.log "temp load meta: #{uuid}"
              packet = {type: 'meta', meta: @intercept[uuid].meta}
            Rx.Observable.just packet
          when 'content'
            if @intercept[uuid]
              # console.log "temp load content: #{uuid}"
              packet = {type: 'content', content: @intercept[uuid].content}
              delete @intercept[uuid]
            Rx.Observable.just packet
          when 'notfound'
            if @intercept[uuid]
              # console.log "temp load (notfound): #{uuid}"
              Rx.Observable.from [{type: 'meta', meta: @intercept[uuid].meta}, {type: 'content', content: @intercept[uuid].content}]
            else
              Rx.Observable.just packet
          else
            Rx.Observable.just packet

  create: (uuid, writeStream) ->
    ipc.send 'storage', {
      type: 'create',
      uuid: uuid
    }

    if writeStream
      writeStream.subscribe (packet) =>
        if packet.type == 'change' || packet.type == 'save'
          # console.warn "temp save #{uuid}"
          localStorage.setItem uuid, JSON.stringify(packet)

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
    localStorage.setItem 'tabs', JSON.stringify(tabArray)

    for i in [0...localStorage.length]
      uuid = localStorage.key(i)
      if uuid != 'tabs' && !_.contains(tabArray, uuid)
        localStorage.removeItem(uuid)

  restore: ->
    tabs = JSON.parse(localStorage.getItem('tabs')) || []
    @intercept = []
    for uuid in tabs
      @intercept[uuid] = JSON.parse(localStorage.getItem(uuid))
    console.log @intercept.length == 0
    tabs = [null] if @intercept.length == 0
    tabs


storage = new StorageWrapper()

module.exports = storage
