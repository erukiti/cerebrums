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

app = require 'app'
BrowserWindow = require 'browser-window'
require('crash-reporter').start()
require('electron-debug')()
# globalShortcut = require('global-shortcut')
Menu = require 'menu'
ipc = require 'ipc'
Rx = require 'rx'

windows = []

# console.log process.memoryUsage()
# console.log process.uptime()

app.on 'window-all-closed', ->
  app.quit()

browserCommand = (message) =>
  BrowserWindow.getFocusedWindow().webContents.send 'message', message

global.conf = {
  basePath: "#{app.getPath 'home'}/.cerebrums"
}

app.on 'ready', ->
  win = new BrowserWindow {width: 800, height: 600}
  win.loadUrl "file://#{__dirname}/index.html"
  # win.setTitle 'cerebrums'
  win.on 'closed', ->
    # FIXME
    # windows.remove win
    # win = null

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

