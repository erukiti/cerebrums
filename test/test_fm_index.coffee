assert = require 'power-assert'
sinon = require 'sinon'

FmIndex = require '../src/fm_index.coffee'

BWT = require '../src/bwt.coffee'

describe 'FmIndex', ->
  it '', ->
    fmIndex = new FmIndex([{text: "abracadabra"}])
    console.dir fmIndex.search("a")
    # console.dir fmIndex.decode()
  # 2, 3, 4, 2, 5, 2, 6, 2, 3, 4, 2, 1, 0
  # s = [ 1, 2, 4, 6, 0, 4, 5, 2, 2, 3, 3, 2, 2 ]
  # last = 4

