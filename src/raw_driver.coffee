class RawDriver
  constructor: (rxfs) ->
    @rxfs = rxfs

  blobWrite: (path, file) ->
    @rxfs.writeFile(path, file)





module.exports = RawDriver
