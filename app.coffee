app = require 'app'
BrowserWindow = require 'browser-window'
require('crash-reporter').start();
# globalShortcut = require('global-shortcut')
Menu = require 'menu'
ipc = require 'ipc'

app.on 'window-all-closed', ->
  app.quit()

app.on 'ready', ->
  mainWindow = new BrowserWindow {width: 800, height: 600}
  mainWindow.loadUrl "file://#{__dirname}/index.html"

  mainWindow.on 'closed', ->
    mainWindow = null;

  menuTemplate = [
    {
      label: 'cerebrums'
      submenu: [
        {
          label: 'Quit'
          accelerator: 'Command+Q'
          click: ->
            app.quit()
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
            mainWindow.webContents.send 'message', 'open'
        },
        {
          label: 'Save'
          accelerator: 'Command+S'
          click: ->
            mainWindow.webContents.send 'message', 'save'
        }
      ]
    }
  ]
  Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate))

