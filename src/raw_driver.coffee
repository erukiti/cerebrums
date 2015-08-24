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

Rx = require 'rx'

class RawDriver
  constructor: (rxfs, conf) ->
    @rxfs = rxfs
    @conf = conf

  writeTemp: (filename, file) =>
    path = "#{@conf.basePath}/temp/#{filename}"
    # console.dir "writeTemp: #{path}"
    @rxfs.writeFile(path, file)

  writeBlob: (hash, file) =>
    path = "#{@conf.basePath}/blob/#{hash}"
    # console.log "writeBlob: #{path}"
    @rxfs.writeFile(path, file)

  writePointer: (uuid, file) =>
    path = "#{@conf.basePath}/pointer/#{uuid}"
    # console.log "writePointer: #{path}"
    @rxfs.writeFile(path, file)

  readTemp: (filename) =>
    path = "#{@conf.basePath}/temp/#{filename}"
    @rxfs.readFile(path)

  readBlob: (hash) =>
    path = "#{@conf.basePath}/blob/#{hash}"
    # console.log "readBlob: #{path}"
    @rxfs.readFile(path)

  readPointer: (uuid) =>
    path = "#{@conf.basePath}/pointer/#{uuid}"
    # console.log "readPointer: #{path}"
    @rxfs.readFile(path)

  getAllPointer: =>
    Rx.Observable.create (obs) =>
      @rxfs.readDir("#{@conf.basePath}/pointer").subscribe((dirs) =>
        for dir in dirs
          obs.onNext(dir.substr("#{@conf.basePath}/pointer/".length))
        obs.onCompleted()
      , (err) =>
        if err.code == 'ENOENT'
          obs.onCompleted()
        else
          obs.onError(err)
      )

module.exports = RawDriver
