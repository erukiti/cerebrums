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
sprintf = require("sprintf-js").sprintf
remote = require 'remote'

Storage = require './src/storage.coffee'
RawDriver = require './src/raw_driver.coffee'
Rxfs = require './src/rxfs.coffee'
EditorViewModel = require './editor_view_model.coffee'
AutoSaver = require './auto_saver.coffee'

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

  isDirtyObservable: ->
    Rx.Observable.just(false)

  closeOk: ->
    false

class AccessViewModel
  constructor: ->
    @uuid = "access-view"
    @html = wx.property '<access></access>'
    @search = wx.property ''
    @list = wx.list()
    @previewHtml = wx.property ''

    @open = wx.command (meta) =>
      Storage.load(meta.uuid).subscribe (packet) =>
        switch packet.type
          when 'content'
            content = new Buffer(packet.content)
            @previewHtml(marked(content.toString()))
      , (err) => wx.messageBus.sendMessage err.message, 'status-bar'

      for _meta in @list.toArray()
        if _meta == meta
          _meta.klass 'selectedAccessList'
        else
          _meta.klass 'accessList'

    @edit = wx.command (meta) =>
      wx.messageBus.sendMessage meta, 'open'

    @listAdd = wx.command (meta) =>
      dateFormat = (date) ->
        sprintf "%4d/%02d/%02d %02d:%02d:%02d", date.getFullYear(), date.getMonth() + 1, date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds()
      meta.title = 'no title' unless meta.title
      meta.createdAt = dateFormat(new Date(meta.createdAt))
      meta.updatedAt = dateFormat(new Date(meta.updatedAt))
      meta.klass = wx.property 'accessList'
      @list.push meta
    , this

    @search.changed.subscribe (query) =>
      if query
        @list.clear()
        Storage.search(query).subscribe (meta) =>
          @listAdd.execute meta
      else
        @list.clear()
        Storage.getRecent().subscribe (meta) =>
          @listAdd.execute meta

  onChanged: ->
    unless @search()
      @list.clear()
      Storage.getRecent().subscribe (meta) =>
        @listAdd.execute meta

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
    @previewHtml.changed

  titleObservable: ->
    Rx.Observable.just('access')

  isDirtyObservable: ->
    Rx.Observable.just(false)

  closeOk: ->
    true

class PaneViewModel
  constructor: (params) ->
    @tabs = wx.list()
    @views = wx.list()
    @tabView = wx.property null
    @tabChange = wx.command (tabView) =>
      for _tab in @tabs.toArray()
        if _tab.view == tabView
          _tab.klass 'tabSelected'
        else
          _tab.klass 'tab'

      @tabView(tabView)
      tabView.setHeight()
    , this

    @openedList = wx.list()
    @autoSaver = new AutoSaver()

    # FIXME: pane / view の二重配列に変更する
    @openedList.listChanged
      .filter =>
        @elem.id == 'pane0'
      .subscribe =>
        @autoSaver.tabs @openedList.toArray()

    @tabView.changed.subscribe (tabView) =>
      if tabView.onChanged
        tabView.onChanged()

    @closeView = wx.command (tabView) =>
      tabView = @tabView() unless tabView

      return unless tabView.closeOk()

      return unless tabView

      # 最後の tab の時に削除するかどうか

      i = 0
      for tab in @tabs.toArray()
        if tab.view == tabView
          @tabs.remove(tab)
          @views.remove(tabView)
          @openedList.remove(tabView.uuid)
          break
        i++

      i-- if i >= @tabs.length && i >= 0
      @tabChange.execute(@tabs.get(i).view) if @tabs.length > 0

  new: (uuid, conf) =>
    if uuid && @openedList.contains(uuid)
        view = @searchView(uuid)
      else
        switch uuid
          when 'access-view'
            view = new AccessViewModel()
          when 'preview-view'
            view = new PreviewViewModel()
          else
            view = new EditorViewModel(uuid, conf)

        uuid = view.uuid
        @addView(view)
        @openedList.push uuid

      @tabChange.execute(view)
      @setHeight()
      @setWidth()
      # Fixme: このタイミングじゃないと正しく setHeight()できない？


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
    for view in @views.toArray()
      return view if uuid == view.uuid

    null

  addView: (view) ->
    n = @tabs.length()
    tab = {
      tabTitle: wx.property(''), 
      isDirty: wx.property(''),
      view: view,
      klass: wx.property 'tab'
    }

    @tabs.push tab
    @views.push view

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
        "#{title.substr(0, 8)}…"
      else
        title
    .subscribe (title) ->
      tab.tabTitle(title)

    view.isDirtyObservable().subscribe (isDirty) =>
      if isDirty
        tab.isDirty '*'
      else
        tab.isDirty ''

    @tabChange.execute(view) if @tabView() == null

  setWidth: (width) ->
    return if !width && !@width

    if width
      @width = width
    else
      width = @width
    @elem.style.width = "#{width}px"
    @views.forEach (view) ->
      view.setWidth width

  setX: (x) ->
    @elem.style.x = x

  setY: (y) ->
    @elem.style.y = y

  setHeight: (height) ->
    return if !height && !@height

    if height
      @height = height
    else
      height = @height
    @elem.style.height = "#{height}px"
    height -= @elemTabs.offsetHeight
    # console.dir @views.toArray()
    @views.forEach (view) ->
      # console.dir view
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
    @separaters = wx.list()
    @status = wx.property 'statusbar'
    @title = wx.property 'Cerebrums'

    @panesElem = document.getElementById 'panes'
    @statusBarElem = document.getElementById 'statusbar'
    @id = wx.property 0

    # @focusedPane = 

    for n in [0...nPanes]
      @addPane()

    wx.messageBus.listen('open').subscribe (meta) =>
      @panes.get(0).new(meta.uuid)

    ipc.on 'message', (ev, arg) =>
      switch ev.type
        when 'close'
          @panes.get(0).closeView.execute()
        when 'tab'
          @panes.get(0).new()
        when 'access'
          @panes.get(0).new('access-view')

    wx.messageBus.listen('status-bar').subscribe (msg) =>
      @status(msg)

  addPane: ->
    pane = new PaneViewModel()
    @panes.push pane
    n = @panesElem.children.length - 2
    @panesElem.children[n].id = "pane#{n}"
    pane.setId n
    pane.setElement @panesElem.children[n]
    # setHeight
    @separaters.push @panesElem.children[n + 1]

  addView: (viewModel, n) ->
    @panes.get(n).addView(viewModel)
    # Elem, height, width などを設定する

  setHeight: (height) ->
    @panesElem.style.height = "#{height - @statusBarElem.offsetHeight}px"
    @panes.forEach (pane) =>
      pane.setHeight height - @statusBarElem.offsetHeight
      pane.setY 0

  setWidth: (width) ->
    @panesElem.style.width = "#{width}px"
    paneWidth = Math.floor(width / @panes.length())
    x = 0
    for n in [0...@panes.length()]
      w = Math.min(paneWidth, width)
      @panes.get(n).setWidth w
      @panes.get(n).setX x

      if n < @panes.length() - 1
        @separaters.get(n).style.width = "1px"
        @separaters.get(n).style.x = x + w
        w += 1
      else
        @separaters.get(n).style.width = "0"
      width -= w
      x += w


  getView: (n) ->
    @panes.get(n).getView()

wx.app.component 'pane',
  template: '
<div class="tabs" data-bind="foreach: tabs">
  <div data-bind="command: {command: $parent.tabChange, parameter: $data.view}, css: klass">
    <span data-bind="text: isDirty"></span><span data-bind="text: tabTitle"></span>
    <span class="fa fa-close" data-bind="command: {command: $parent.closeView, parameter: $data.view}"><span>
  </div>
</div>
<div class="views" data-bind="foreach: views">
  <div data-bind="visible: $data == $parent.tabView, html: html"></div>
</div>
'

wx.app.component 'editor',
  template: '
<span data-bind="text: star, command: clickStar"></span>
<input type="text" class="tagEditor" data-bind="textinput: @tags" placeholder="タグ">
<input type="text" class="titleEditor" data-bind="textinput: @title" placeholder="タイトル">
<textarea class="editor" data-bind="textinput: @text"></textarea>
'

wx.app.component 'access',
  template: '''
<div>
  search: <input type="text" class="search" data-bind="textinput: @search" placeholder="検索ワード">
</div>
<table>
  <tbody data-bind="foreach: list">
    <tr data-bind="event: {click: {command: $parent.open, parameter: $data}, dblclick: {command: $parent.edit, parameter: $data}}, css: klass">
      <td class="access_title">
        <span class="fa fa-edit clickable" data-bind="command: {command: $parent.edit, parameter: $data}"></span>
        <span data-bind="text: title"></span>
      </td>
    </tr>
    <tr style="text-align: right" data-bind="css: klass">
      <td class="access_info">
        <span data-bind="text: tags"></span>
        <span data-bind="visible: star == 1">★</span>
        <span data-bind="text: size"></span><span>bytes</span>
        <span data-bind="text: updatedAt"></span>
      </td>
    </tr>
  </tbody>
</table>
'''

Storage.setRawDriver new RawDriver(new Rxfs(), remote.getGlobal('conf'))

mainViewModel = new MainViewModel(0)

wx.applyBindings(mainViewModel)

mainViewModel.addPane()
mainViewModel.addPane()

autoSaver = new AutoSaver()

for restored in autoSaver.restore()
  mainViewModel.panes.get(0).new(restored.uuid, restored.packet)

mainViewModel.panes.get(1).new('preview-view')

# mainViewModel.panes.get(0).previewObservable.subscribe (html) ->
mainViewModel.panes.get(0).tabView.changed.merge(Rx.Observable.just(mainViewModel.panes.get(0).tabView())).subscribe (view) =>
  if view
    view.previewObservable().subscribe (html) =>
      mainViewModel.getView(1).renderedHtml(html)
  # if view はちょっと苦肉の策


# throttle 的な手加減した方がいいかも
Rx.Observable.fromEvent(window, 'resize').merge(Rx.Observable.just(null)).subscribe (ev) =>
  mainViewModel.setHeight(window.innerHeight)
  mainViewModel.setWidth(window.innerWidth)

Rx.Observable.fromEvent(window, 'resize').subscribe (ev) =>
  ipc.send 'window-resize', {height: window.outerHeight, width: window.outerWidth}
  # console.dir window.screenX
  # console.dir window.screenY

