marked = require 'marked'
ipc = require 'ipc'

Storage = require './src/storage.coffee'
RawDriver = require './src/raw_driver.coffee'
Rxfs = require './src/rxfs.coffee'
EditorViewModel = require './editor_view_model.coffee'

# matched = location.search.match(/uuid=([^&]*)/)
# uuid = matched && decodeURIComponent(matched[1])

class PaneViewModel
  constructor: (params) ->
    @tabs = wx.list()
    @views = wx.list()
    @tabIndex = wx.property 0

  addView: (view) ->
    n = @tabs.length()
    @tabs.push {tabTitle: "tab#{n + 1}"}
    @views.push view

    @elemViews.children[n].id = "view#{n}"
    view.setId n
    view.setElement @elemViews.children[n]

  setWidth: (width) ->
    @width = width
    @views.forEach (view) ->
      view.setWidth width

  setHeight: (height) ->
    console.log height
    @elem.style.height = "#{height}px"
    @height = height
    height -= @elemTabs.offsetHeight
    @views.forEach (view) ->
      view.setHeight height

  setElement: (elem) ->
    @elem = elem

    if elem.children[0].className == 'tabs'
      @elemTabs = elem.children[0]
      @elemViews = elem.children[1]
    else
      @elemTabs = elem.children[1]
      @elemViews = elem.children[0]



  setId: (id) ->
    @id = id


class MainViewModel
  constructor: (nPanes) ->
    @panes = wx.list()
    @status = wx.property 'statusbar'

    @panesElem = document.getElementById 'panes'
    @statusBarElem = document.getElementById 'statusbar'
    @id = wx.property 0

    for n in [0...nPanes]
      @addPane()

  addPane: ->
    pane = new PaneViewModel()
    @panes.push pane
    n = @panesElem.children.length - 1
    @panesElem.children[n].id = "pane#{n}"
    pane.setId n
    pane.setElement @panesElem.children[n]
    # setHeight

  addView: (viewModel, n) ->
    @panes.get(n).addView(viewModel)

  setHeight: (height) ->
    @panesElem.style.height = "#{height - @statusBarElem.offsetHeight}px"
    @panes.forEach (pane) =>
      pane.setHeight height - @statusBarElem.offsetHeight


wx.app.component 'pane',
  template: '
<div class="tabs" data-bind="foreach: tabs">
  <div class="tab" data-bind="command: {command: $parent.tabChange, parameter: $data}, text: tabTitle"></div>
</div>
<div class="views" data-bind="foreach: views">
  <div data-bind="visible: $index == $parent.tabIndex, html: html"></div>
</div>
'

wx.app.component 'editor',
  template: '
<input type="text" class="titleEditor" data-bind="textinput: @title" placeholder="タイトル">
<textarea class="editor" data-bind="textinput: @text"></textarea>'

mainViewModel = new MainViewModel(0)

wx.applyBindings(mainViewModel)

mainViewModel.addPane()
mainViewModel.addView(new EditorViewModel(), 0)

mainViewModel.setHeight(window.innerHeight)



return

# document.getElementById('titleEditor1').focus()

layout = ->
  statusbar = document.getElementById 'statusbar'
  main = document.getElementById 'main'
  pane1 = document.getElementById 'pane1'
  pane2 = document.getElementById 'pane2'
  tabs1 = document.getElementById 'tabs1'
  tabs2 = document.getElementById 'tabs2'
  titleEditor1 = document.getElementById 'titleEditor1'
  # editor1 = document.getElementById 'editor1'

  main.style.height = "#{window.innerHeight - statusbar.offsetHeight}px"

  pane1.style.height = "#{main.offsetHeight - tabs1.offsetHeight}px"
  pane2.style.height = "#{main.offsetHeight - tabs2.offsetHeight}px"

  # editor1.style.height = "#{pane1.offsetHeight - titleEditor1.offsetHeight}px"

layout()

class MainViewModel
  constructor: ->
    @comp = new EditorViewModel()

    @tabs1_index = wx.property 1
    @tabs1 = wx.list([{tabTitle: 'エディタ', pane: 1}, {tabTitle: 'アクセス', pane: 2}])
    @title = wx.property ''
    # @editor = wx.property ''
    @viewer = wx.property ''
    # @viewer = wx.whenAny(this.editor, (editor) ->
    #   marked(editor)
    # ).toProperty()
    @status = wx.property 'status'
    @recent = wx.list()
    @save = wx.property true
    @open = wx.command (param) ->
      ipc.send('open', param.uuid)
    @tabChange = wx.command (data) =>
      @tabs1_index(Number(data.pane))
    @pressKey = (a, ev) ->
      if ev.keyCode == 9
        obj = document.getElementById('editor1')
        sPos = obj.selectionStart
        ePos = obj.selectionEnd
        @editor("#{@editor().substr(0, sPos)}\t#{@editor().substr(ePos)}")
        obj.setSelectionRange(sPos + 1, sPos + 1)
        ev.preventDefault()

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

      # @viewModel.editor.changed.subscribe (text) =>
      #   @content = text
      #   @viewModel.save(false)

      #   obs.onNext
      #     type: 'change'
      #     meta: @meta
      #     content: @content

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

wx.app.component 'editor',
  viewModel: {require: './editor_view.coffee'}
  template: {require: './editor_view.html'}

wx.applyBindings(mainViewModel)

ipc.on 'message', (ev, arg)->
  switch ev
    when 'open'
      if mainViewModel.tab1() == 1
        mainViewModel.tabs1_index(2)
      else
        mainViewModel.tabs1_index(1)
    when 'save'
      mainViewModel.save(true)
