app = require 'app'
BrowserWindow = require 'browser-window'
require('crash-reporter').start()
require('electron-debug')()
# globalShortcut = require('global-shortcut')
Menu = require 'menu'
ipc = require 'ipc'

windows = []

app.on 'window-all-closed', ->
  app.quit()

browserCommand = (message) =>
  BrowserWindow.getFocusedWindow().webContents.send 'message', message

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

