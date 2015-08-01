Storage = require './src/storage.coffee'
RawDriver = require './src/raw_driver.coffee'
Rxfs = require './src/rxfs.coffee'

conf = {
  basePath: '/Users/erukiti/.cerebrums'
}

module.exports = new Storage(new RawDriver(new Rxfs(), conf))

