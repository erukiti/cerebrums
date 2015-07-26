marked = require 'marked'
ipc = require 'ipc'

Storage = require './src/storage.coffee'
RawDriver = require './src/raw_driver.coffee'
Rxfs = require './src/rxfs.coffee'

matched = location.search.match(/uuid=([^&]*)/)
uuid = matched && decodeURIComponent(matched[1])

document.getElementById('titleEditor1').focus()

layout = ->
  statusbar = document.getElementById 'statusbar'
  main = document.getElementById 'main'
  pane1 = document.getElementById 'pane1'
  pane2 = document.getElementById 'pane2'
  tabs1 = document.getElementById 'tabs1'
  tabs2 = document.getElementById 'tabs2'
  titleEditor1 = document.getElementById 'titleEditor1'
  editor1 = document.getElementById 'editor1'

  main.style.height = "#{window.innerHeight - statusbar.offsetHeight}px"

  pane1.style.height = "#{main.offsetHeight - tabs1.offsetHeight}px"
  pane2.style.height = "#{main.offsetHeight - tabs2.offsetHeight}px"

  editor1.style.height = "#{pane1.offsetHeight - titleEditor1.offsetHeight}px"

layout()

class MainViewModel
  constructor: ->
    @is_editor = wx.property true
    @title = wx.property ''
    @editor = wx.property ''
    @viewer = wx.whenAny(this.editor, (editor) ->
      marked(editor)
    ).toProperty()
    @status = wx.property 'status'
    @recent = wx.list()
    @save = wx.property true
    @open = wx.command (param) ->
      ipc.send('open', param.uuid)

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

    obs = if uuid
      storage.open(uuid, _save)
    else
      storage.create(_save)

    obs.subscribe (packet) =>
      switch packet.type
        when 'meta'
          @meta = packet
          delete @meta['type']
          @viewModel.title(@meta.title)
        when 'content'
          @content = packet.content.toString()
          @viewModel.editor(@content)

    @viewModel.recent.clear()
    storage.getRecent().subscribe (meta) =>
      # console.dir meta
      @viewModel.recent.push meta

mainViewModel = new MainViewModel()
mainModel = new MainModel(mainViewModel, uuid)

wx.applyBindings(mainViewModel)

ipc.on 'message', (ev, arg)->
  switch ev
    when 'open'
      if mainViewModel.is_editor()
        mainViewModel.is_editor(false)
      else
        mainViewModel.is_editor(true)
    when 'save'
      mainViewModel.save(true)
