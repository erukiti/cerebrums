assert = require 'power-assert'
sinon = require 'sinon'

FmIndex = require '../src/fm_index.coffee'

BWT = require '../src/bwt.coffee'

describe 'FmIndex', ->
  it '', ->
    fmIndex = new FmIndex([
      {uuid: "hoge1", text: "abracadabra"},
      {uuid: "lorem", text: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."},
      {uuid: "nihongo", text: "ほげ♡"},
    ])
    # console.dir fmIndex.search("Lorem ipsum")
    # console.dir fmIndex.search("orem ipsum")
    # console.dir fmIndex.search("rem ipsum")
    # console.dir fmIndex.search("em ipsum")
    # console.dir fmIndex.search("m ipsum")
    # console.dir fmIndex.search(" ipsum")
    # console.dir fmIndex.search("ipsum")
    console.dir fmIndex.search("psum")

    console.dir fmIndex.search("a", 10)

    console.dir fmIndex.search("ほ")
    console.dir fmIndex.search("♡")

    # console.dir fmIndex.decode()
  # 2, 3, 4, 2, 5, 2, 6, 2, 3, 4, 2, 1, 0
  # s = [ 1, 2, 4, 6, 0, 4, 5, 2, 2, 3, 3, 2, 2 ]
  # last = 4


  @metaArray = [];
  @wayPoint = [];

