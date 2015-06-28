app = require 'app'
BrowserWindow = require 'browser-window'

app.on 'window-all-closed', ->
  app.quit()

app.on 'ready', ->
  mainWindow = new BrowserWindow {width: 800, height: 600}
  mainWindow.loadUrl "file://#{__dirname}/index.html"

  mainWindow.on 'closed', ->
    mainWindow = null;
