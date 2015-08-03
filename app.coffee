app = require 'app'
BrowserWindow = require 'browser-window'
require('crash-reporter').start();
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
          accelerator: 'Command+T'
          click: ->
            browserCommand {type: 'tab'}
        },
        {
          label: 'Open'
          accelerator: 'Command+O'
          click: ->
            browserCommand {type: 'access'}
        },
        {
          label: 'Save'
          accelerator: 'Command+S'
          click: ->
            browserCommand {type: 'save'}
        },
        {
          label: 'Close'
          accelerator: 'Command+W'
          click: ->
            browserCommand {type: 'close'}
        }
      ]
    }
  ]
  Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate))

