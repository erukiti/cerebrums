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

  _getChar = (elem) ->
    if typeof elem == 'string'
      elem.charCodeAt(0) 
    else
      elem

  constructor: (str, bits) ->
    unless bits
      c1 = 0
      for c in str
        c1 |= _getChar(c)

      bits = countBits(c1)

    @bits = bits
    @bitStreams = Array(bits)
    @c0size = Array(bits)
    @starts = Array(2 << (bits - 1))
    cnt = 0
    bitmask = 1 << (bits - 1)
    while bitmask > 0
      index = 0
      @bitStreams[cnt] = new BitArray(str.length)
      c0 = []
      c1 = []
      for c in str
        if _getChar(c) & bitmask
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

    n = -1
    i = 0
    for c in str
      if n != c
        @starts[c] = i
        n = c
      i++

    # for bitStream in @bitStreams
    #   console.dir bitStream.toString()
    # for n in @c0size
    #   console.log n

  rank: (ind, c) ->
    return 0 if ind == 0
    if typeof c == 'string'
      c = c.charCodeAt(0)

    return 0 if @starts[c] == undefined

    # c が bits の範囲かどうかチェック
    bits = @bits

    cnt = 0
    bitmask = 1 << (bits - 1)
    while bitmask > 0
      if c & bitmask
        ind = @c0size[cnt] + @bitStreams[cnt].rank1(ind)
      else
        ind = @bitStreams[cnt].rank0(ind)
      cnt++
      bitmask >>>= 1
      # console.log ind
      # return 0 if ind == 0

    # console.log "#{c}, #{@starts[c]}, #{ind}"

    ind - @starts[c]

# select: () ->

  get: (ind) ->
    bits = @bits
    cnt = 0
    c = 0
    bitmask = 1 << (bits - 1)
    while bitmask > 0
      if @bitStreams[cnt].get(ind)
        c |= bitmask
        ind = @c0size[cnt] + @bitStreams[cnt].rank1(ind)
      else
        ind = @bitStreams[cnt].rank0(ind)
      cnt++
      bitmask >>>= 1

    c

module.exports = WaveletMatrix
