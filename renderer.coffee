marked = require 'marked'
ipc = require 'ipc'

Storage = require './src/storage.coffee'
RawDriver = require './src/raw_driver.coffee'
Rxfs = require './src/rxfs.coffee'

class MainViewModel
  constructor: ->
    @is_editor = wx.property true
    @title = wx.property ''
    @editor = wx.property ''
    @viewer = wx.whenAny(this.editor, (editor) ->
      marked(editor)
    ).toProperty()
    @recent = wx.list()
    @save = wx.property false

class MainModel
  constructor: (viewModel, uuid) ->
    @viewModel = viewModel
    @meta = {}
    @content = ''

    conf = {
      basePath: '/Users/erukiti/.cerebrums'
    }
    storage = new Storage(new RawDriver(new Rxfs(), conf))

    _save = Rx.Observable.create (obs) =>
      @viewModel.title.changed.subscribe (title) =>
        @meta['title'] = title
        @viewModel.save(false)

        obs.onNext
          type: 'change'
          meta: @meta
          content: @content

      @viewModel.editor.changed.subscribe (text) =>
        @content = text
        @viewModel.save(false)

        obs.onNext
          type: 'change'
          meta: @meta
          content: @content

      @viewModel.save.changed.filter((b) => b).subscribe () =>
        obs.onNext
          type: 'save'
          meta: @meta
          content: @content

    # Rx.Observable.fromEvent(document.querySelector('#editor'), 'keyPress').subscribe (ev) ->
    #   console.dir ev

    obs = if uuid
      storage.open(uuid, _save)
    else
      storage.create(_save)

    obs.subscribe (packet) =>
      switch packet.type
        when 'meta'
          @meta = packet.meta
          @viewModel.title = @meta.title
        when 'content'
          @content = packet.content
          @viewModel.editor = @content

    @viewModel.recent.clear()
    storage.getRecent().subscribe (meta) =>
      @viewModel.recent.push meta

mainViewModel = new MainViewModel()
mainModel = new MainModel(mainViewModel)

wx.applyBindings(mainViewModel)

ipc.on 'message', (ev, arg)->
  switch ev
    when 'open'
      mainViewModel.is_editor(false)
    when 'save'
      mainViewModel.save(true)
