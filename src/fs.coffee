sha256 = require 'sha256'

class FS
  constructor: (rawDriver) ->
    @rawDriver = rawDriver

  create: (content, func) ->
    hash = sha256(content)
    @rawDriver.blobWrite hash, content, (err) ->
      if (err)
        func(err)
        return

      # @rawDriver.metaWrite 





module.exports = FS
