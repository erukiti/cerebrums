class File
  constructor: (uuid) ->
    @uuid = uuid ? uuid : null
    @meta = {}
    @content = null

module.exports = File
