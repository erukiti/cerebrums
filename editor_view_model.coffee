marked = require 'marked'
ipc = require 'ipc'
remote = require 'remote'
app = remote.require 'app'
BrowserWindow = remote.require 'browser-window'
dialog = remote.require 'dialog'
uuidv4 = require 'uuid-v4'

storage = require('./storage.coffee')

class EditorViewModel
  constructor: (uuid) ->
    @uuid = uuid
    @title = wx.property ''
    @text = wx.property ''
    @isDirty = wx.property false
    @html = wx.property '<editor></editor>'
    @star = wx.property '☆'
    @tags = wx.property ''

    @meta = {title: '', tags: '', star: '0'}
    @content = ''

    @isDirty.changed.subscribe (isDirty) =>
      BrowserWindow.getFocusedWindow().setDocumentEdited(isDirty)

    @clickStar = wx.command () =>
      if (@star() == '☆')
        @star('★')
      else
        @star('☆')

    ipc.on 'message', (ev, arg) =>
      switch ev.type
        when 'save'
          wx.messageBus.sendMessage @uuid, 'save'

    _save = Rx.Observable.create (obs) =>
      @title.changed.subscribe (title) =>
        @meta['title'] = title
        @isDirty(true)

        obs.onNext
          type: 'change'
          meta: @meta
          content: @content
      
      @tags.changed.subscribe (tags) =>
        @meta['tags'] = tags
        @isDirty(true)

        obs.onNext
          type: 'change'
          meta: @meta
          content: @content

      @star.changed.subscribe (star) =>
        if star == '★'
          @meta['star'] = '1'
        else
          @meta['star'] = '0'
        @isDirty(true)

        obs.onNext
          type: 'change'
          meta: @meta
          content: @content

      @text.changed.subscribe (text) =>
        @content = text
        @isDirty(true)

        obs.onNext
          type: 'change'
          meta: @meta
          content: @content

      wx.messageBus.listen('save').subscribe (uuid) =>
        return if uuid != @uuid
        if @isDirty()
          obs.onNext
            type: 'save'
            meta: @meta
            content: @content
          @isDirty(false)
        else
          wx.messageBus.sendMessage 'no saved', 'status-bar'

      wx.messageBus.listen('close').subscribe (uuid) =>
        return if uuid != @uuid
        obs.onNext
          type: 'close'
        obs.onComplete()

    storageObs = if uuid
      storage.open(uuid, _save)
    else
      @uuid = uuidv4()
      storage.create(@uuid, _save)

    storageObs.subscribe (packet) =>
      switch packet.type
        when 'meta'
          @meta = packet.meta
          @title(@meta.title)
          if @meta['star'] == '1'
            @star('★')
          else
            @star('☆')
          @tags(@meta['tags'])
          @isDirty(false)

        when 'content'
          content = new Buffer(packet.content)
          @content = content.toString()
          @text(@content)
          @isDirty(false)

        when 'saved'
          wx.messageBus.sendMessage "saved", 'status-bar'

        when 'uuid'
          @uuid = packet.uuid

        else
          console.error 'unknown packet'
          console.dir packet

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
    @text.changed.merge(Rx.Observable.just(@text())).map (text) ->
      marked(text)

  titleObservable: ->
    @title.changed.merge(Rx.Observable.just(''))

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
