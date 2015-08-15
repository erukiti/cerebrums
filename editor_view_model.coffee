marked = require 'marked'
ipc = require 'ipc'
remote = require 'remote'
app = remote.require 'app'
BrowserWindow = remote.require 'browser-window'
dialog = remote.require 'dialog'

storage = require('./storage.coffee')

class EditorViewModel
  constructor: (uuid) ->
    @uuid = uuid
    @title = wx.property ''
    @text = wx.property ''
    @isDirty = wx.property false
    @html = wx.property '<editor></editor>'

    @meta = {title: ''}
    @content = ''

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
        
      @text.changed.subscribe (text) =>
        @content = text
        @isDirty(true)

        obs.onNext
          type: 'change'
          meta: @meta
          content: @content

      wx.messageBus.listen('save').subscribe (uuid) =>
        console.dir uuid
        console.dir @uuid
        return if uuid != @uuid
        if @isDirty()
          obs.onNext
            type: 'save'
            meta: @meta
            content: @content
          @isDirty(false)
        else
          wx.messageBus.sendMessage 'no saved', 'status-bar'

    storageObs = if uuid
      storage.open(uuid, _save)
    else
      storage.create(_save)

    storageObs.subscribe (packet) =>
      switch packet.type
        when 'meta'
          @meta = packet
          delete @meta['type']
          @title(packet.title)
        when 'content'
          @content = packet.content.toString()
          @text(@content)
        when 'saved'
          wx.messageBus.sendMessage "saved", 'status-bar'
        when 'uuid'
          console.log packet.uuid
          @uuid = packet.uuid
        else
          console.dir packet

  setHeight: (height) ->
    unless @elemTitleEditor.offsetHeight
      # Fixme: work a round.
      console.warn "EditorViewModel#setHeight: @elemTitleEditor.offsetHeight is unknown"
      return
    @height = height
    @elem.style.height = "#{height}px"
    # console.log "EditorViewModel#setHeight: #{@elemTitleEditor.offsetHeight}"
    @elemEditor.style.height = "#{height - @elemTitleEditor.offsetHeight}px"

  setWidth: (width) ->
    @width = width
    @elem.style.width = "#{width}px"
    @elemEditor.style.width = "#{width}px"
    @elemTitleEditor.style.width = "#{width}px"

  setElement: (elem) ->
    @elem = elem.children[0]
    if @elem.children[0].className == 'titleEditor'
      @elemTitleEditor = @elem.children[0]
      @elemEditor = @elem.children[1]
    else
      @elemTitleEditor = @elem.children[1]
      @elemEditor = @elem.children[0]

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
    console.log result
    switch result
      when 0
        console.log '0'
        wx.messageBus.sendMessage @uuid, 'save'
        true
      when 1
        console.log '1'
        false
      when 2
        console.log '2'
        true

module.exports = EditorViewModel
