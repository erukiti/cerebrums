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

_ = require 'lodash'
fs = require 'fs'
path = require 'path'
Rx = require 'rx'

class Rxfs
  constructor: ->
    @mode = parseInt('0777', 8) & (~process.umask())

  _mkdirp = (dirPath, cb) =>
    fs.mkdir dirPath, @mode, (err) =>
      return cb(null) unless err
      switch err.code
        when 'ENOENT'
          _mkdirp path.dirname(dirPath), (err2) =>
            if err2
              cb(err2)
            else
              _mkdirp dirPath, cb
        else
          fs.stat dirPath, (err2, stat) =>
            if err2 || !stat.isDirectory()
              cb(err)
            else
              cb(null)

  _setFullPath = (a, b) => "#{a}/#{b}"

  readDir: (dirPath) ->
    Rx.Observable.create (obs) =>
      fs.readdir dirPath, (err, files) =>
        if err
          obs.onError(err)
        else
          files = _.map(files, _.partial(_setFullPath, dirPath))
          obs.onNext(files)
          obs.onCompleted()

  readFile: (filePath) ->
    Rx.Observable.create (obs) =>
      fs.readFile filePath, (err, content) =>
        if err
          obs.onError(err)
        else
          obs.onNext(content)
          obs.onCompleted()

  writeFile: (filePath, content) ->
    filePath = path.resolve(filePath)
    Rx.Observable.create (obs) =>
      _mkdirp path.dirname(filePath), (err) =>
        if err
          obs.onError(err)
        else
          fs.writeFile filePath, content, (err2) =>
            if err2
              obs.onError(err2)
            else
              obs.onNext('wrote')
              obs.onCompleted

module.exports = Rxfs
