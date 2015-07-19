assert = require 'power-assert'
sinon = require 'sinon'

BWT = require '../src/bwt.coffee'

describe 'BWT', ->
  describe '.encode', ->
    result = BWT.encode("abracadabra")
    assert result.string == 'ardrcaaaabb'
    assert result.last == 3
    
    result = BWT.encode('aeadacab')
    assert result.string == 'bcdeaaaa'
    assert result.last == 4

  describe '.decode', ->
    assert BWT.decode('ard$rcaaaabb', 3) == '$abracadabra'
    # assert BWT.decode('bcdeaaaa', 4) == 'aeadacab'

  describe '.search', ->
    assert BWT.search('ard$rcaaaabb', 'bra').sort(), [1, 8]
