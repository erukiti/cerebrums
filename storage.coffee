Storage = require './src/storage.coffee'
RawDriver = require './src/raw_driver.coffee'
Rxfs = require './src/rxfs.coffee'
app = require('remote').require 'app'

conf = {
  basePath: "#{app.getPath 'home'}/.cerebrums"
}

module.exports = new Storage(new RawDriver(new Rxfs(), conf))

