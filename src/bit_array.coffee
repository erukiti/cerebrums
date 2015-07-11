class BitArray
  constructor: (size) ->
    @buf = new Buffer(Math.floor(size / 8) + 1)
    @buf.fill(0)
    @size = size
    @lergeCount = new Uint32Array(Math.floor(size / 8 / 64 + 1 + 1))
    @smallCount = new Uint16Array(Math.floor(size / 8 / 8 + 1 + 1))
    @dirty = false

  toString: () ->
    s = ''

    size = @size
    for byte in @buf
      bitmask = 0x80
      while bitmask > 0
        if byte & bitmask
          s += '1'
        else
          s += '0'
        bitmask >>>= 1
        size--
        return s if size <= 0
    s

  get: (pos) ->
    n = @buf[Math.floor(pos / 8)]
    n & (128 >> (pos % 8)) ? 1 : 0

  set0: (pos) ->
    n = @buf[Math.floor(pos / 8)]
    n &= 255 ^ (128 >> (pos % 8))
    @buf.writeUInt8(n, Math.floor(pos / 8))
    @dirty = true

  set1: (pos) ->
    # console.log "set1: #{pos}/#{@size}"
    n = @buf[Math.floor(pos / 8)]
    n |= 128 >> (pos % 8)
    @buf.writeUInt8(n, Math.floor(pos / 8))
    @dirty = true

  _popcount_1byte = (n) ->
    # console.log "popcount:#{n.toString(2)}"
    n = ((n & 0xaa) >>> 1) + (n & 0x55)
    n = ((n & 0xcc) >>> 2) + (n & 0x33)
    n = ((n & 0xf0) >>> 4) + (n & 0x0f)
    n

  _popcount_4byte = (buf, p) ->
    n = buf.readUInt32LE(p)
    n = ((n & 0xaaaaaaaa) >>> 1)  + (n & 0x55555555)
    n = ((n & 0xcccccccc) >>> 2)  + (n & 0x33333333)
    n = ((n & 0xf0f0f0f0) >>> 4)  + (n & 0x0f0f0f0f)
    n = ((n & 0xff00ff00) >>> 8)  + (n & 0x00ff00ff)
    n = ((n & 0xffff0000) >>> 16) + (n & 0x0000ffff)
    n

  build: ->
    popCount = 0
    ptr = 0

    while ptr <= Math.floor(@size / 8)
      lergeCount = popCount
      @lergeCount[Math.floor(ptr / 64)] = lergeCount
      @smallCount[Math.floor(ptr / 8)] = 0

      break unless ptr + 8 <= Math.floor(@size / 8)
      # console.log "ptr8"
      popCount += _popcount_4byte(@buf, ptr)
      popCount += _popcount_4byte(@buf, ptr + 4)

      @smallCount[Math.floor(ptr / 8) + 1] = popCount - lergeCount

      ptr += 8
      break unless ptr + 8 <= Math.floor(@size / 8)
      # console.log "ptr16"
      popCount += _popcount_4byte(@buf, ptr)
      popCount += _popcount_4byte(@buf, ptr + 4)
      @smallCount[Math.floor(ptr / 8) + 1] = popCount - lergeCount

      ptr += 8
      break unless ptr + 8 <= Math.floor(@size / 8)

      popCount += _popcount_4byte(@buf, ptr)
      popCount += _popcount_4byte(@buf, ptr + 4)
      @smallCount[Math.floor(ptr / 8) + 1] = popCount - lergeCount

      ptr += 8
      break unless ptr + 8 <= Math.floor(@size / 8)

      popCount += _popcount_4byte(@buf, ptr)
      popCount += _popcount_4byte(@buf, ptr + 4)
      @smallCount[Math.floor(ptr / 8) + 1] = popCount - lergeCount

      ptr += 8
      break unless ptr + 8 <= Math.floor(@size / 8)

      popCount += _popcount_4byte(@buf, ptr)
      popCount += _popcount_4byte(@buf, ptr + 4)
      @smallCount[Math.floor(ptr / 8) + 1] = popCount - lergeCount

      ptr += 8
      break unless ptr + 8 <= Math.floor(@size / 8)

      popCount += _popcount_4byte(@buf, ptr)
      popCount += _popcount_4byte(@buf, ptr + 4)
      @smallCount[Math.floor(ptr / 8) + 1] = popCount - lergeCount

      ptr += 8
      break unless ptr + 8 <= Math.floor(@size / 8)

      popCount += _popcount_4byte(@buf, ptr)
      popCount += _popcount_4byte(@buf, ptr + 4)
      @smallCount[Math.floor(ptr / 8) + 1] = popCount - lergeCount

      ptr += 8
      break unless ptr + 8 <= Math.floor(@size / 8)

      popCount += _popcount_4byte(@buf, ptr)
      popCount += _popcount_4byte(@buf, ptr + 4)

      ptr += 8

    @dirty = false

  rank0: (pos) ->
    # console.log "rank0:#{pos}"
    return 0 if pos == 0
    @build() if @dirty

    pos--
    popCount = Math.floor(pos / 8 / 64) * 8 * 64 - 
               @lergeCount[Math.floor(pos / 8 / 64)] + 
               Math.floor(pos / 8 / 8) % 8 * 8 * 8 - 
               @smallCount[Math.floor(pos / 8 / 8)]

    popCount += 8 - _popcount_1byte(@buf[Math.floor(pos / 8 / 8) * 8 + 0]) if Math.floor(pos / 8) % 8 > 0
    popCount += 8 - _popcount_1byte(@buf[Math.floor(pos / 8 / 8) * 8 + 1]) if Math.floor(pos / 8) % 8 > 1
    popCount += 8 - _popcount_1byte(@buf[Math.floor(pos / 8 / 8) * 8 + 2]) if Math.floor(pos / 8) % 8 > 2
    popCount += 8 - _popcount_1byte(@buf[Math.floor(pos / 8 / 8) * 8 + 3]) if Math.floor(pos / 8) % 8 > 3
    popCount += 8 - _popcount_1byte(@buf[Math.floor(pos / 8 / 8) * 8 + 4]) if Math.floor(pos / 8) % 8 > 4
    popCount += 8 - _popcount_1byte(@buf[Math.floor(pos / 8 / 8) * 8 + 5]) if Math.floor(pos / 8) % 8 > 5
    popCount += 8 - _popcount_1byte(@buf[Math.floor(pos / 8 / 8) * 8 + 6]) if Math.floor(pos / 8) % 8 > 6


    bitmask = ((255 << 8) >>> (pos % 8 + 1))
    popCount += pos % 8 + 1 - _popcount_1byte(@buf[Math.floor(pos / 8)] & bitmask)
    popCount


  rank1: (pos) ->
    # console.log "rank1:#{pos}"
    return 0 if pos == 0
    @build() if @dirty

    pos--
    lergePos = Math.floor(pos / 8 / 64)
    smallPos = Math.floor(pos / 8 / 8)
    bufPos = Math.floor(pos / 8)

    popCount = @lergeCount[lergePos] + 
               @smallCount[smallPos]

    popCount += _popcount_1byte(@buf[Math.floor(bufPos / 8) * 8 + 0]) if bufPos % 8 > 0
    popCount += _popcount_1byte(@buf[Math.floor(bufPos / 8) * 8 + 1]) if bufPos % 8 > 1
    popCount += _popcount_1byte(@buf[Math.floor(bufPos / 8) * 8 + 2]) if bufPos % 8 > 2
    popCount += _popcount_1byte(@buf[Math.floor(bufPos / 8) * 8 + 3]) if bufPos % 8 > 3
    popCount += _popcount_1byte(@buf[Math.floor(bufPos / 8) * 8 + 4]) if bufPos % 8 > 4
    popCount += _popcount_1byte(@buf[Math.floor(bufPos / 8) * 8 + 5]) if bufPos % 8 > 5
    popCount += _popcount_1byte(@buf[Math.floor(bufPos / 8) * 8 + 6]) if bufPos % 8 > 6

    bitmask = ((255 << 8) >>> (pos % 8 + 1))
    popCount += _popcount_1byte(@buf[Math.floor(pos / 8)] & bitmask)

    popCount

  rank: (pos, bit) ->
    if bit
      rank1(pos)
    else
      rank0(pos)

  select: (ind, bit) ->
    # console.log "select #{ind}, #{bit}"
    left = 0
    right = Math.floor(@size / 8 / 64)
    if left == right
      right++
    # console.dir @lergeCount
    # console.log "lerge: #{left}, #{right}"

    while left < right
      ptr = Math.floor((left + right) / 2)
      if bit
        rank = @lergeCount[ptr]
      else
        rank = ptr * 8 * 64 - @lergeCount[ptr]

      if ind <= rank
        right = ptr
      else
        left = ptr + 1
    right--
    if bit
      ind -= @lergeCount[right]
    else
      ind -= right * 8 * 64 - @lergeCount[right]

    posSmall = right * 8 + Math.floor(@size / 8 / 8) % 8
    while posSmall >= right * 8
      if bit
        rank = @smallCount[posSmall]
      else
        rank = (posSmall % 8) * 8 * 8 - @smallCount[posSmall]

      if ind > rank
        ind -= rank
        break

      posSmall--

    if posSmall < right * 8
      posSmall = right * 8

    pos = posSmall * 8

    # console.log "-- #{ind}, #{pos}"
    cnt = 0
    while ind > 0 && pos * 8 < @size
      n = @buf[pos]
      bitmask = 0x80
      cnt = 0
      # console.log n.toString(2)
      while bitmask > 0
        # console.log "*#{ind}, #{cnt}"
        # console.dir (n & bitmask).toString(2)
        if (bit && n & bitmask) || (!bit && (n & bitmask) == 0)
          ind--
        break if ind == 0
        bitmask >>>= 1
        cnt++
      break if ind == 0
      pos++

    pos * 8 + cnt

  select0: (ind) ->
    @select(ind, 0)

  select1: (ind) ->
    @select(ind, 1)

module.exports = BitArray
