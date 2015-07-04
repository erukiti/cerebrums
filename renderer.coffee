marked = require 'marked'
ipc = require 'ipc'

repository = require './src/repository.coffee'

class MainViewModel
  constructor: ->
    @is_editor = wx.property true
    @title = wx.property ''
    @editor = wx.property ''
    @viewer = wx.whenAny(this.editor, (editor) ->
      marked(editor)
    ).toProperty()
    @recent = wx.list()

class MainModel
  constructor: (viewModel, uuid) ->
    @viewModel = viewModel

    repository = new Repository()

    obs = uuid ? repository.openUUID(uuid) : repository.createUUID()
    obs.subscribe (packet) ->
      switch packet.type
        when 'UUID'
          @uuid = packet.uuid
          _startSave(@uuid)
        when 'meta'
          @meta = packet.meta
          @viewModel.title = @meta.title
        when 'content'
          @content = packet.content
          @viewModel.editor = @content

    repository.getRecentByChanged().subscribe (lists) ->
      @viewModel.recent.clear()
      lists.each (meta) ->
        @viewModel.recent.push meta

    _startSave = (uuid) ->
      packet = Rx.Observable.merge(
        @viewModel.title.changed.map (title) ->
          @meta.title = title
          {
            type: 'change'
            uuid: @uuid
            meta: @meta
            content: @content
          }
        , @viewModel.editor.changed.map (text) ->
          @content = text
          {
            type: 'change'
            uuid: @uuid
            meta: @meta
            content: @content
          }
        # , Rx.Observable.fromEvent(document.querySelector('#editor'), 'keyPress').
      )
      repository.save(uuid, packet)

mainViewModel = new MainViewModel()
mainModel = new MainModel(mainViewModel)

wx.applyBindings(mainViewModel)

ipc.on 'message', (ev, arg)->
  switch ev
    when 'open' then mainViewModel.is_editor(false)
