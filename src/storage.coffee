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

Rx = require 'rx'
sha256 = require 'sha256'
uuidv4 = require 'uuid-v4'
msgpack = require 'msgpack-js'

Searcher = require './searcher.coffee'

class Storage
  _rawDriver = null
  _searcher = new Searcher []

  @setRawDriver = (rawDriver) =>
    _rawDriver = rawDriver

    _rawDriver.getAllPointer().flatMap (uuid) =>
      _rawDriver.readPointer(uuid).flatMap (metaHash) =>
        _rawDriver.readBlob(metaHash).flatMap (metaMsgpack) =>
          meta = msgpack.decode metaMsgpack
          meta.uuid = uuid
          _rawDriver.readBlob(meta.sha256).map (content) =>
            {meta: meta, text: content.toString('utf-8')}
    .toArray()
    .subscribe (docs) =>
      _searcher = new Searcher(docs)

  @getRecent = =>
    Rx.Observable.create (obs) =>
      for meta in _searcher.getRecent()
        obs.onNext meta

  @search = (query) =>
    Rx.Observable.create (obs) =>
      for meta in _searcher.search(query)
        obs.onNext meta

  @load = (uuid) =>
    Rx.Observable.create (obs) =>
      _rawDriver.readPointer(uuid).subscribe (metaHash) =>
        _rawDriver.readBlob(metaHash).subscribe (metaMsgpack) =>
          meta = msgpack.decode metaMsgpack
          contentHash = meta.sha256
          @prevHash = meta.sha256
          delete meta.sha256
          obs.onNext {type: 'meta', meta: meta}

          _rawDriver.readBlob(contentHash).subscribe (content) =>
            obs.onNext {type: 'content', content: content}
            obs.onCompleted()
          , (err) => obs.onError err
        , (err) => obs.onError err
      , (err) =>
        if err.code == 'ENOENT'
          obs.onNext {type: 'notfound'}
          obs.onCompleted()
        else
          obs.onError err

  constructor: (uuid) ->
    @uuid = uuid
    @subject = new Rx.Subject()
    @observable = @subject.publish()
    @observable.connect()

  load: ->
    Storage.load(@uuid).subscribe (packet) =>
      @subject.onNext packet
    , (err) => @subject.onNext {type: 'error', error: err}

  save: -> (meta, content) =>
    Rx.Observable.create (obs) =>
      buf = new Buffer(content)
      contentHash = sha256 buf
      rawDriver.writeBlob(contentHash, buf).subscribe (x) =>
        meta.sha256 = contentHash
        meta.size = buf.length
        meta.createdAt = (new Date()).toISOString() unless @prevHash
        meta.updatedAt = (new Date()).toISOString()
        meta.prevSha256 = @prevHash if @prevHash
        meta.uuid = @uuid
        meta.version = 1
        metaMsgpack = msgpack.encode meta
        metaHash = sha256 metaMsgpack

        _searcher.add(meta, buf)

        rawDriver.writeBlob(metaHash, metaMsgpack).subscribe (x) =>
          rawDriver.writePointer(uuid, metaHash).subscribe (x) =>
            @prevHash = contentHash
            @subject.onNext {type: 'saved'}
          , (err) => @subject.onNext {type: 'error', error: err}
        , (err) => @subject.onNext {type: 'error', error: err}
      , (err) => @subject.onNext {type: 'error', error: err}

module.exports = Storage
