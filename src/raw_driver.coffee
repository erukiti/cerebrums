Rx = require 'rx'

class RawDriver
  constructor: (rxfs, conf) ->
    @rxfs = rxfs
    @conf = conf

  writeBlob: (hash, file) =>
    path = "#{@conf.basePath}/blob/#{hash}"
    console.log "writeBlob: #{path}"
    @rxfs.writeFile(path, file)

  writePointer: (uuid, file) =>
    path = "#{@conf.basePath}/pointer/#{uuid}"
    console.log "writePointer: #{path}"
    @rxfs.writeFile(path, file)

  readBlob: (hash) =>
    path = "#{@conf.basePath}/blob/#{hash}"
    console.log "readBlob: #{path}"
    @rxfs.readFile(path)

  readPointer: (uuid) =>
    path = "#{@conf.basePath}/pointer/#{uuid}"
    console.log "readPointer: #{path}"
    @rxfs.readFile(path)

  getRecent: =>
    Rx.Observable.create (obs) =>
      @rxfs.readDir("#{@conf.basePath}/pointer").subscribe((dirs) =>
        dirs = for dir in dirs
          dir.substr("#{@conf.basePath}/pointer/".length)
        obs.onNext(dirs)
        obs.onCompleted()
      , (err) =>
        if err.code == 'ENOENT'
          obs.onCompleted()
        else
          obs.onError(err)
      )

module.exports = RawDriver
