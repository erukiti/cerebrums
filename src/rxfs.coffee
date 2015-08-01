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
