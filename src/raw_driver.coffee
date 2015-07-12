class RawDriver
  constructor: (rxfs, conf) ->
    @rxfs = rxfs
    @conf = conf

  writeBlob: (hash, file) ->
    @rxfs.writeFile("#{@conf.basePath}/blob/#{hash}", file)

  writePointer: (uuid, file) ->
    @rxfs.writeFile("#{@conf.basePath}/pointer/#{uuid}", file)

  readBlob: (hash) ->
    @rxfs.readfile("#{@conf.basePath}/blob/#{hash}")

  readPointer: (uuid) ->
    @rxfs.readfile("#{@conf.basePath}/pointer/#{uuid}")

  getRecent: ->
    @rxfs.readdir("#{@conf.basePath}/pointer").map (dirs) =>
      for dir in dirs
        dir.substr("#{@conf.basePath}/pointer/".length)


module.exports = RawDriver
