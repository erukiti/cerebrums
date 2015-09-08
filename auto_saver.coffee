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

class AutoSaver
  constructor: ->
    @changeSubject = new Rx.Subject()
    w = @changeSubject.distinctUntilChanged()

    w.buffer(w.throttle(1000))
      .filter (list) =>
        # work a round. でもこれがなぜ発生するかわからない
        list.length > 0
      .map (list) => 
        list[list.length - 1]
      .subscribe (packet) =>
        localStorage.setItem packet.uuid, JSON.stringify(packet)

  change: (uuid, meta, content) ->
    packet = {uuid: uuid, meta: meta, content: content}
    @changeSubject.onNext packet

  save: (uuid, meta, content) ->
    packet = {meta: meta, content: content}
    localStorage.setItem uuid, JSON.stringify(packet)

  tabs: (lists) ->
    localStorage.setItem 'tabs', JSON.stringify(lists)

  restore: ->
    tabs = JSON.parse(localStorage.getItem('tabs')) || []
    if tabs.length == 0
      [{uuid: null, packet: null}]
    else
      for uuid in tabs
        {uuid: uuid, packet: JSON.parse(localStorage.getItem(uuid))}

module.exports = AutoSaver
