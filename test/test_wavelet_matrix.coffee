assert = require 'power-assert'
sinon = require 'sinon'

WaveletMatrix = require '../src/wavelet_matrix.coffee'

describe 'WaveletMatrix', ->
  describe '', ->
    it '', ->
      wm = new WaveletMatrix([11, 0, 15, 6, 5, 2, 7, 12, 11, 0, 12, 12, 13, 4, 6, 13, 1, 11, 6, 1, 7, 10,    2, 7, 14, 11, 1, 7, 5, 4, 14, 6])
      # assert wm.rank(0, 11) == 0
      # assert wm.rank(1, 11) == 1

      assert wm.rank(22, 11) == 3
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

