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
