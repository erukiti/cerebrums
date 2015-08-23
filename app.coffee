app = require 'app'
BrowserWindow = require 'browser-window'
require('crash-reporter').start()
require('electron-debug')()
# globalShortcut = require('global-shortcut')
Menu = require 'menu'
ipc = require 'ipc'
Rx = require 'rx'

Storage = require './src/storage.coffee'
RawDriver = require './src/raw_driver.coffee'
Rxfs = require './src/rxfs.coffee'

windows = []

app.on 'window-all-closed', ->
  app.quit()

browserCommand = (message) =>
  BrowserWindow.getFocusedWindow().webContents.send 'message', message

conf = {
  basePath: "#{app.getPath 'home'}/.cerebrums"
}

storage = new Storage(new RawDriver(new Rxfs(), conf))
writeObservers = []

createWriteObserver = (uuid) =>
  Rx.Observable.create (obs) =>
    ipc.on "storage-#{uuid}", (event, packet) =>
      switch packet.type
        when 'change'
          obs.onNext packet
        when 'save'
          obs.onNext packet
        when 'close'
          obs.onComplete()

ipc.on 'storage', (event, packet) =>
  switch packet.type
    when 'open'
      storage.open(packet.uuid, createWriteObserver(packet.uuid)).subscribe (_packet) =>
        _packet['uuid'] = packet.uuid
        event.sender.send 'storage', _packet

    when 'create'
      storage.create(packet.uuid, createWriteObserver(packet.uuid)).subscribe (_packet) =>
        _packet['uuid'] = packet.uuid
        event.sender.send 'storage', _packet

    when 'search'
      storage.search(packet.query).subscribe (meta) =>
        event.sender.send 'storage', 
          uuid: packet.uuid,
          meta: meta


    when 'getRecent'
      storage.getRecent().subscribe (meta) =>
        event.sender.send 'storage',
          uuid: packet.uuid,
          meta: meta

    when 'tabs'
      ;

  # event.sender.send('asynchronous-reply', 'pong');


app.on 'ready', ->
  win = new BrowserWindow {width: 800, height: 600}
  win.loadUrl "file://#{__dirname}/index.html"
  # win.setTitle 'cerebrums'
  win.on 'closed', ->
    mainWindow = null;

  windows.push win

  menuTemplate = [
    {
      label: 'cerebrums'
      submenu: [
        {
          label: 'Quit'
          accelerator: 'Command+Q'
          click: ->
            app.quit()
        },
        {
          label: 'Debug'
          accelerator: 'Command+Alt+I'
          click: ->
            BrowserWindow.getFocusedWindow().toggleDevTools()
        }
      ]
    },
    {
      label: 'File'
      submenu: [
        {
          label: 'New'
          accelerator: 'CmdOrCtrl+T'
          click: ->
            browserCommand {type: 'tab'}
        },
        {
          label: 'Open'
          accelerator: 'CmdOrCtrl+O'
          click: ->
            browserCommand {type: 'access'}
        },
        {
          label: 'Save'
          accelerator: 'CmdOrCtrl+S'
          click: ->
            browserCommand {type: 'save'}
        },
        {
          label: 'Close'
          accelerator: 'CmdOrCtrl+W'
          click: ->
            browserCommand {type: 'close'}
        }
      ]
    },
    {
      label: 'Edit',
      submenu: [
        {
          label: 'Undo',
          accelerator: 'CmdOrCtrl+Z',
          selector: 'undo:'
        },
        {
          label: 'Redo',
          accelerator: 'Shift+CmdOrCtrl+Z',
          selector: 'redo:'
        },
        {
          type: 'separator'
        },
        {
          label: 'Cut',
          accelerator: 'CmdOrCtrl+X',
          selector: 'cut:'
        },
        {
          label: 'Copy',
          accelerator: 'CmdOrCtrl+C',
          selector: 'copy:'
        },
        {
          label: 'Paste',
          accelerator: 'CmdOrCtrl+V',
          selector: 'paste:'
        },
        {
          label: 'Select All',
          accelerator: 'CmdOrCtrl+A',
          selector: 'selectAll:'
        },
      ]
    }
  ]
  Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate))

