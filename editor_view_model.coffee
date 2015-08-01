marked = require 'marked'
remote = require 'remote'

class EditorViewModel
  constructor: (uuid) ->
    @title = wx.property ''
    @text = wx.property ''
    @isDirty = wx.property false
    @html = wx.property '<editor></editor>'

    @meta = {}
    @content = ''

    # _save = Rx.Observable.create (obs) =>
    #   @title.changed.subscribe (title) =>
    #     @meta['title'] = title
    #     @isDirty(true)

    #     obs.onNext
    #       type: 'change'
    #       meta: @meta
    #       content: @content
        
    #   @text.changed.subscribe (text) =>
    #     @content = text
    #     @isDirty(true)

    #     obs.onNext
    #       type: 'change'
    #       meta: @meta
    #       content: @content
    _save = undefined

    storageObs = if uuid
      remote.require('./storage.coffee').open(uuid, _save)
    else
      remote.require('./storage.coffee').create(_save)

    storageObs.subscribe (packet) =>
      switch packet.type
        when 'meta'
          @meta = packet
          delete @meta['type']
          @title(packet.title)
        when 'content'
          @content = packet.content.toString()
          @text(@content)

  setHeight: (height) ->
    @height = height
    @elem.style.height = "#{height}px"

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
    @text.changed.map (text) ->
      marked(text)

  titleObservable: ->
    @title.changed.merge(Rx.Observable.just(''))

module.exports = EditorViewModel
