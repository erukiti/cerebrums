assert = require 'power-assert'
sinon = require 'sinon'

BWT = require '../src/bwt.coffee'

describe 'BWT', ->
  describe 'encode', ->
    bwt = new BWT()
    console.log bwt.encode("abracadabra")
    console.log bwt.encode 'aeadacab'
