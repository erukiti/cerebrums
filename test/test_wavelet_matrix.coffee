assert = require 'power-assert'
sinon = require 'sinon'

WaveletMatrix = require '../src/wavelet_matrix.coffee'

describe 'WaveletMatrix', ->
  describe '#rank', ->
    it '', ->
      wm = new WaveletMatrix([11, 0, 15, 6, 5, 2, 7, 12, 11, 0, 12, 12, 13, 4, 6, 13, 1, 11, 6, 1, 7, 10, 2, 7, 14, 11, 1, 7, 5, 4, 14, 6])
      assert wm.rank(0, 11) == 0
      assert wm.rank(1, 11) == 1

      assert wm.rank(22, 11) == 3
      assert wm.rank(26, 11) == 4
      assert wm.rank(25, 11) == 3
      assert wm.rank(22 ,0) == 2
      assert wm.rank(22, 15) == 1
      assert wm.rank(22, 6) == 3
      assert wm.rank(22, 5) == 1
      assert wm.rank(22, 2) == 1
      assert wm.rank(22, 7) == 2
      assert wm.rank(22, 12) == 3
      assert wm.rank(22, 13) == 2
      assert wm.rank(22, 4) == 1
      assert wm.rank(22, 3) == 0

    it '', ->
      wm = new WaveletMatrix('abbracadabbra')
      assert wm.rank(0, 'a') == 0
      assert wm.rank(1, 'a') == 1
      assert wm.rank(8, 'a') == 3
      assert wm.rank(8, 'b') == 2
      assert wm.rank(8, 'r') == 1

  describe '#get', ->
    it '', ->
      wm = new WaveletMatrix([11, 0, 15, 6, 5, 2, 7, 12, 11, 0, 12, 12, 13, 4, 6, 13, 1, 11, 6, 1, 7, 10, 2, 7, 14, 11, 1, 7, 5, 4, 14, 6])
      assert wm.get(0) == 11
      assert wm.get(1) == 0
      assert wm.get(2) == 15
      assert wm.get(3) == 6
      assert wm.get(4) == 5
      assert wm.get(5) == 2
      assert wm.get(6) == 7
      assert wm.get(7) == 12
      assert wm.get(8) == 11
      assert wm.get(9) == 0
      assert wm.get(22) == 2

    it '', ->
      wm = new WaveletMatrix('abbracadabbra')
      assert wm.get(0) == 'a'.charCodeAt(0)
      assert wm.get(1) == 'b'.charCodeAt(0)
      assert wm.get(2) == 'b'.charCodeAt(0)
      assert wm.get(3) == 'r'.charCodeAt(0)
      assert wm.get(4) == 'a'.charCodeAt(0)
      assert wm.get(5) == 'c'.charCodeAt(0)
      assert wm.get(6) == 'a'.charCodeAt(0)
      assert wm.get(7) == 'd'.charCodeAt(0)
      assert wm.get(8) == 'a'.charCodeAt(0)
      assert wm.get(9) == 'b'.charCodeAt(0)
      assert wm.get(10) == 'b'.charCodeAt(0)
      assert wm.get(11) == 'r'.charCodeAt(0)
      assert wm.get(12) == 'a'.charCodeAt(0)
