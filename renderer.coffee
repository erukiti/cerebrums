marked = require 'marked'
ipc = require 'ipc'
remote = require 'remote'

EditorViewModel = require './editor_view_model.coffee'

class PreviewViewModel
  constructor: ->
    @uuid = "preview-view"
    @html = wx.property '<div class="preview" data-bind="html: renderedHtml"></div>'
    @renderedHtml = wx.property ''

  setHeight: (height) ->
    @elem.style.height = "#{height}px"

  setWidth: (width) ->
    @elem.style.width = "#{width}px"

  setElement: (elem) ->
    @elem = elem

  setId: (id) ->
    @id = id

  previewObservable: ->
    Rx.Observable.empty()

  titleObservable: ->
    Rx.Observable.just('preview')

class AccessViewModel
  constructor: ->
    @uuid = "access-view"
    @html = wx.property '<access></access>'
    @recent = wx.list()
    remote.require('./storage.coffee').getRecent().subscribe (meta) =>
      @recent.push meta
    @open = wx.command (meta) =>
      wx.messageBus.sendMessage meta, 'open'

  setHeight: (height) ->
    @elem.style.height = "#{height}px"

  setWidth: (width) ->
    @elem.style.width = "#{width}px"

  setElement: (elem) ->
    @elem = elem

  setId: (id) ->
    @id = id

  previewObservable: ->
    # FIXME: preview に対応する
    Rx.Observable.empty()

  titleObservable: ->
    Rx.Observable.just('access')

class PaneViewModel
  constructor: (params) ->
    @tabs = wx.list()
    @views = wx.list()
    @tabView = wx.property null
    @tabChange = wx.command (tab) =>
      @tabView(tab.view)

    # @previewObservable = Rx.Observable.create (obs) =>
    #   @views.listChanged.subscribe (flags) =>
    #     console.log flags
    #     for view in @views
    #       obs.onNext(view.previewObservable())
    # .flatMap (obs) =>
    #   obs

    # @previewObservable = @tabView.changed.flatMap (view) =>
    #   console.dir "---- #{view}"
    #   view.previewObservable()

    # @previewObservable = @views.listChanged.flatMap (flags) =>
    #   @tabView.changed.flatMap (tabView) =>
    #     if tabView == view
    #       view.previewObservable()
    #     else
    #       Rx.Observable.empty()

    # @previewObservable = Rx.Observable.create (obs) =>
    #   @tabView.changed.subscribe (view) =>
    #     view.previewObservable().subscribe (html) =>
    #       obs.onNext(html)

  searchView: (uuid) ->
    console.dir uuid
    for view in @views.toArray()
      return view if uuid == view.uuid

    null

  addView: (view) ->
    n = @tabs.length()
    tab = {tabTitle: wx.property(''), view: view}

    @tabs.push tab
    @views.push view
    @tabView(view) if @tabView() == null

    @elemViews.children[n].id = "view#{n}"
    view.setId n
    view.setElement @elemViews.children[n]

    view.titleObservable().map (title) ->
      if title == ''
        'no title'
      else
        title
    .map (title) ->
      if title.length > 10
        "#{title.substr(0, 8)}..."
      else
        title
    .subscribe (title) ->
      tab.tabTitle(title)

  setWidth: (width) ->
    @width = width
    @elem.style.width = "#{width}px"
    @views.forEach (view) ->
      view.setWidth width

  setX: (x) ->
    @elem.style.x = x

  setY: (y) ->
    @elem.style.y = y

  setHeight: (height) ->
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

  getView: ->
    @tabView()

class MainViewModel
  constructor: (nPanes) ->
    @panes = wx.list()
    @status = wx.property 'statusbar'

    @panesElem = document.getElementById 'panes'
    @statusBarElem = document.getElementById 'statusbar'
    @id = wx.property 0

    @opendList = wx.list()

    # @focusedPane = 

    for n in [0...nPanes]
      @addPane()

    wx.messageBus.listen('open').subscribe (meta) =>
      if @opendList.contains(meta.uuid)
        view = @panes.get(0).searchView(meta.uuid)
        console.dir view
      else
        view = new EditorViewModel(meta.uuid)
        @addView(view, 0)
        @opendList.push meta.uuid

      @panes.get(0).tabView(view) if view

    wx.messageBus.listen('status-bar').subscribe (msg) =>
      @status(msg)

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
      pane.setY 0

  setWidth: (width) ->
    @panesElem.style.width = "#{width}px"
    for n in [0...@panes.length()]
      @panes.get(n).setWidth width / @panes.length()
      @panes.get(n).setX width / @panes.length() * n

  getView: (n) ->
    @panes.get(n).getView()

wx.app.component 'pane',
  template: '
<div class="tabs" data-bind="foreach: tabs">
  <div class="tab" data-bind="command: {command: $parent.tabChange, parameter: $data}, text: tabTitle"></div>
</div>
<div class="views" data-bind="foreach: views">
  <div data-bind="visible: $data == $parent.tabView, html: html"></div>
</div>
'

wx.app.component 'editor',
  template: '
<input type="text" class="titleEditor" data-bind="textinput: @title" placeholder="タイトル">
<textarea class="editor" data-bind="textinput: @text"></textarea>
'

wx.app.component 'access',
  template: '
<table>
  <tbody data-bind="foreach: recent">
    <tr data-bind="event: {click: {command: $parent.open, parameter: $data}}">
      <td data-bind="text: title"></td>
    </tr>
  </tbody>
</table>
'

mainViewModel = new MainViewModel(0)

wx.applyBindings(mainViewModel)

mainViewModel.addPane()
mainViewModel.addPane()
mainViewModel.addView(new EditorViewModel(), 0)
mainViewModel.addView(new AccessViewModel(), 0)
mainViewModel.addView(new PreviewViewModel(), 1)

# mainViewModel.panes.get(0).previewObservable.subscribe (html) ->
mainViewModel.panes.get(0).tabView.changed.merge(Rx.Observable.just(mainViewModel.panes.get(0).tabView())).subscribe (view) =>
  view.previewObservable().subscribe (html) =>
    mainViewModel.getView(1).renderedHtml(html)

# throttle 的な手加減した方がいいかも
Rx.Observable.fromEvent(window, 'resize').merge(Rx.Observable.just(null)).subscribe (ev) =>
  mainViewModel.setHeight(window.innerHeight)
  mainViewModel.setWidth(window.innerWidth)
