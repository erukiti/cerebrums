app = require 'app'
BrowserWindow = require 'browser-window'
require('crash-reporter').start();
# globalShortcut = require('global-shortcut')
Menu = require 'menu'
ipc = require 'ipc'

windows = []

app.on 'window-all-closed', ->
  app.quit()

ipc.on 'open', (ev, uuid) ->
  win = new BrowserWindow {width: 800, height: 600}
  win.loadUrl "file://#{__dirname}/index.html?uuid=#{encodeURIComponent(uuid)}"

  win.on 'closed', ->
    console.log 'closed'

  windows.push win
  

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
          label: 'Open'
          accelerator: 'Command+O'
          click: ->
            BrowserWindow.getFocusedWindow().webContents.send 'message', 'open'
        },
        {
          label: 'Save'
          accelerator: 'Command+S'
          click: ->
            BrowserWindow.getFocusedWindow().webContents.send 'message', 'save'
        }
      ]
    }
  ]
  Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate))

