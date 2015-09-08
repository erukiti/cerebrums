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

marked = require 'marked'
ipc = require 'ipc'
remote = require 'remote'
app = remote.require 'app'
BrowserWindow = remote.require 'browser-window'
dialog = remote.require 'dialog'
uuidv4 = require 'uuid-v4'

Storage = require './src/storage.coffee'
AutoSaver = require './auto_saver.coffee'

class EditorViewModel
  _setMeta = (meta) ->
    @title(meta.title)
    @tags(meta.title)
    if meta.star == '1'
      @star('★')
    else
      @star('☆')

  _setOriginalMeta = (meta) ->
    @originalTitle(meta.title)
    @originalTags(meta.title)
    if meta.star == '1'
      @originalStar('★')
    else
      @originalStar('☆')

  _setContent = (content) ->
    console.log "setContent: #{content}"
    @text content.toString('utf-8')

  _setOriginalContent = (content) ->
    console.log "setOriginalContent: #{content}"
    @originalText content.toString('utf-8')

  constructor: (uuid, initPacket) ->
    if uuid
      @uuid = uuid
    else
      @uuid = uuidv4()

    @title = wx.property ''
    @text = wx.property ''
    @html = wx.property '<editor></editor>'
    @star = wx.property '☆'
    @tags = wx.property ''

    @originalTitle = wx.property ''
    @originalStar = wx.property '☆'
    @originalTags = wx.property ''
    @originalText = wx.property ''

    @isDirty = wx.whenAny @title, @text, @star, @tags, @originalTitle, @originalText, @originalStar, @originalTags, (title, text, star, tags, originalTitle, originalText, originalStar, originalTags) =>
      title != originalTitle ||
      text != originalText ||
      star != originalStar ||
      tags != originalTags
    .toProperty()
    # @isDirty.changed.subscribe (isDirty) =>
    #   BrowserWindow.getFocusedWindow().setDocumentEdited(isDirty)

    @meta = {title: '', tags: '', star: '0'}

    @storage = new Storage(@uuid)
    @autoSaver = new AutoSaver()

    @clickStar = wx.command () =>
      if (@star() == '☆')
        @star('★')
      else
        @star('☆')

    ipc.on 'message', (ev, arg) =>
      switch ev.type
        when 'save'
          wx.messageBus.sendMessage @uuid, 'save'

    @title.changed.subscribe (title) =>
      @meta['title'] = title
      @autoSaver.save @uuid, @meta, @text()
    
    @tags.changed.subscribe (tags) =>
      @meta['tags'] = tags
      @autoSaver.save @uuid, @meta, @text()

    @star.changed.subscribe (star) =>
      if star == '★'
        @meta['star'] = '1'
      else
        @meta['star'] = '0'
      @autoSaver.save @uuid, @meta, @text()

    @text.changed.subscribe (text) =>
      @autoSaver.save @uuid, @meta, text

    wx.messageBus.listen('save').subscribe (uuid) =>
      return if uuid != @uuid
      if @isDirty()
        @storage.save @meta, @text
        @autoSaver.save @uuid, @meta, @text

        @originalTitle @title()
        @originalText @text()
        @originalStar @star()
        @originalTags @tags()

      else
        wx.messageBus.sendMessage 'no saved', 'status-bar'

    if initPacket
      console.log initPacket.content
      _setMeta.call @, initPacket.meta
      _setContent.call @, initPacket.content

    @storage.observable.subscribe (packet) =>
      switch packet.type
        when 'meta'
          unless initPacket
            _setMeta.call @, packet.meta
            console.log '******'
          _setOriginalMeta.call @, packet.meta

        when 'content'
          unless initPacket
            _setContent.call @, packet.content
            console.log '******'
          _setOriginalContent.call @, packet.content

        when 'saved'
          wx.messageBus.sendMessage 'saved', 'status-bar'

        when 'error'
          wx.messageBus.sendMessage packet.error.message, 'status-bar'
          console.dir err
    @storage.load()

  setHeight: (height) ->
    if height
      @height = height
    else
      height = @height

    unless @elemTitleEditor.offsetHeight
      # Fixme: work a round.
      console.warn "EditorViewModel#setHeight: #{@uuid}, @elemTitleEditor.offsetHeight is unknown"

      return

    @elem.style.height = "#{height}px"
    # console.log "EditorViewModel#setHeight: #{@uuid}, #{@elemTitleEditor.offsetHeight}"
    height -= @elemTitleEditor.offsetHeight + @elemTagsEditor.offsetHeight

    @elemEditor.style.height = "#{height}px"

  setWidth: (width) ->
    @width = width
    @elem.style.width = "#{width}px"
    @elemEditor.style.width = "#{width}px"
    @elemTitleEditor.style.width = "#{width}px"

  setElement: (elem) ->
    @elem = elem.children[0]
    @elemTagsEditor = @elem.children[1]
    @elemTitleEditor = @elem.children[2]
    @elemEditor = @elem.children[3]

  setId: (id) ->
    @id = id

  previewObservable: ->
    Rx.Observable.create (obs) =>
      @text.changed.subscribe (text) =>
        obs.onNext marked(text)
      obs.onNext marked(@text())

  titleObservable: ->
    Rx.Observable.create (obs) =>
      @title.changed.subscribe (title) =>
        obs.onNext title
      obs.onNext @title()

  isDirtyObservable: ->
    Rx.Observable.create (obs) =>
      @isDirty.changed.subscribe (isDirty) =>
        obs.onNext isDirty
      obs.onNext @isDirty()

  closeOk: ->
    return true unless @isDirty()

    opt =
      title: 'close tab'
      type: 'warning'
      buttons: ['Save', 'Cancel', 'Don\'t save']
      message: "Do you want to save the changes?\n" + "Your changes will be lost if you don't save them."

    win = BrowserWindow.getFocusedWindow()
    result = dialog.showMessageBox win, opt
    switch result
      when 0
        wx.messageBus.sendMessage @uuid, 'save'
        wx.messageBus.sendMessage @uuid, 'close'
        true
      when 1
        false
      when 2
        wx.messageBus.sendMessage @uuid, 'close'
        true

module.exports = EditorViewModel
