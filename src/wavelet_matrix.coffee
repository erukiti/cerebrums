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

    # get のために、typeof str を取っておくべきか

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
      c = _getChar(c)
      if n != c
        @starts[c] = i
        n = c
      i++

    # console.log str
    # for bitStream in @bitStreams
    #   console.dir bitStream.toString()
    # for n in @c0size
    #   console.log n

  _rank: (start, ind, c) ->
    return {equal: 0, great: 0, less: 0} if ind == 0
    
    c = c.charCodeAt(0) if typeof c == 'string'

    # c が bits の範囲かどうかチェック
    bits = @bits

    cnt = 0
    great = 0
    less = 0
    bitmask = 1 << (bits - 1)
    while bitmask > 0
      # console.log "loop #{c & bitmask}, #{ind}"
      if c & bitmask
        size = ind - start
        start = @c0size[cnt] + @bitStreams[cnt].rank1(start)
        ind = @c0size[cnt] + @bitStreams[cnt].rank1(ind)
        less += size - (ind - start)
        # console.log "less += #{size - (ind - start)}"
      else
        size = ind - start
        start = @bitStreams[cnt].rank0(start)
        ind = @bitStreams[cnt].rank0(ind)
        great += size - (ind - start)
        # console.log "great += #{size - (ind - start)}"
      # console.log "ind #{ind}"
      cnt++
      bitmask >>>= 1
      # console.log ind
      # return 0 if ind == 0
#  v
# 11010101
# ...*****


    # console.log "great: #{great}"
    # console.log "less: #{less}"

    # console.log "#{c}, #{@starts[c]}, #{ind}"
    # if @starts[c] != undefined
    #   {
    #     'equal': ind - @starts[c]
    #     'great': great
    #     'less': less
    #   }
    # else
    #   {
    #     'equal': 0
    #     'great': great
    #     'less': less
    #   }

    {
      equal: ind - start
      great: great
      less: less
    }

  rank: (ind, c) ->
    @_rank(0, ind, c)['equal']

  rankLessThan: (ind, c) ->
    @_rank(0, ind, c)['less']
  
  rankGreaterThan: (ind, c) ->
    @_rank(0, ind, c)['great']

  select: (ind, c) ->
    # console.log "select(#{ind},#{c})"
    c = c.charCodeAt(0) if typeof c == 'string'

    throw new Error("not found #{c}") if @starts[c] == undefined

    # c が bits の範囲かどうかチェック

    cnt = @bits - 1
    bitmask = 1
    ind = @starts[c] + ind
    while cnt >= 0
      # console.log "loop #{c & bitmask}, #{ind} #{@c0size[cnt]}"
      if c & bitmask
        ind = @bitStreams[cnt].select1(ind - @c0size[cnt] + 1)
      else
        ind = @bitStreams[cnt].select0(ind + 1)
      cnt--
      bitmask <<= 1
    ind

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
