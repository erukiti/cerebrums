BitArray = require './bit_array.coffee'

class WaveletMatrix
  countBits = (n) ->
    bits = 32
    bitmask = 0x80000000
    while bitmask > 0
      if n & bitmask
        return bits
      bitmask >>>= 1
      bits--
    0

  getChar = (elem) ->
    if typeof elem == 'string'
      elem.charCodeAt(0) 
    else
      elem

  constructor: (str, bits) ->
    unless bits
      c1 = 0
      for c in str
        c1 |= getChar(c)

      bits = countBits(c1)

    @bitStreams = Array(bits)
    @c0size = Array(bits)
    cnt = 0
    bitmask = 1 << (bits - 1)
    while bitmask > 0
      index = 0
      @bitStreams[cnt] = new BitArray(str.length)
      c0 = []
      c1 = []
      for c in str
        if getChar(c) & bitmask
          c1.push c
          @bitStreams[cnt].set1(index)
        else
          c0.push c
          @bitStreams[cnt].set0(index)
        index++

      @c0size[cnt] = c0.length
      str = c0.concat(c1)
      cnt++

      bitmask >>>= 1

    for bitStream in @bitStreams
      console.dir bitStream.toString()
    for n in @c0size
      console.log n

module.exports = WaveletMatrix
