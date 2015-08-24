# Copyright 2015 SASAKI, Shunsuke. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
        packet.isDirty = false
        switch packet.type
          when 'meta'
            if @intercept[uuid]
              Rx.Observable.from([packet, {type: 'meta', isDirty: true, meta: @intercept[uuid].meta}])
            else
              Rx.Observable.just packet
          when 'content'
            if @intercept[uuid]
              Rx.Observable.from([packet, {type: 'content', isDirty: true, content: @intercept[uuid].content}])
              delete @intercept[uuid]
            else
              Rx.Observable.just packet
          when 'notfound'
            if @intercept[uuid]
              # console.log "temp load (notfound): #{uuid}"
              Rx.Observable.from [{type: 'meta', isDirty: true, meta: @intercept[uuid].meta}, {type: 'content', isDirty: true, content: @intercept[uuid].content}]
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
    f = false
    for uuid in tabs
      @intercept[uuid] = JSON.parse(localStorage.getItem(uuid))
      f = true
    if f
      tabs
    else
      [null]


storage = new StorageWrapper()

module.exports = storage
