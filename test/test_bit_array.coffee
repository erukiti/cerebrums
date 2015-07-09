assert = require 'power-assert'
sinon = require 'sinon'

BitArray = require '../src/bit_array.coffee'

generate = (size, source) ->
  generateBit = (pos) =>
    if source
      source[pos + 2] == '1' ? 1 : 0
    else
      Math.floor(Math.random() * 2)

  result =
    bitArray: new BitArray(size)
    rank0: new Array(size + 1)
    rank1: new Array(size + 1)
  
  rank0 = 0
  rank1 = 0
  result.rank0[0] = 0
  result.rank1[0] = 0
  for i in [0...size]
    if generateBit(i)
      result.bitArray.set1(i)
      rank1++
    else
      result.bitArray.set0(i)
      rank0++
    result.rank0[i + 1] = rank0
    result.rank1[i + 1] = rank1

  result.bitArray.build()
  result

test = (size, expected) ->
  for i in [0..size]
    assert expected.bitArray.rank0(i) == expected.rank0[i]
    assert expected.bitArray.rank1(i) == expected.rank1[i]

  i = 1
  while i < expected.rank0[size]
    assert expected.rank0[expected.bitArray.select0(i) + 1] == i
    i++

  i = 1
  while i < expected.rank1[size]
    assert expected.rank1[expected.bitArray.select1(i) + 1] == i
    i++

describe 'BitArray', ->
  it 'size = 3', ->
    size = 3
    test(size, generate(size, '0b000'))
    test(size, generate(size, '0b001'))
    test(size, generate(size, '0b010'))
    test(size, generate(size, '0b011'))
    test(size, generate(size, '0b100'))
    test(size, generate(size, '0b101'))
    test(size, generate(size, '0b110'))
    test(size, generate(size, '0b111'))

  it 'size = 8', ->
    size = 8
    test(size, generate(size), '0b11111111')
    test(size, generate(size), '0b10000000')
    test(size, generate(size), '0b01000000')
    test(size, generate(size), '0b00100000')
    test(size, generate(size), '0b00010000')
    test(size, generate(size), '0b00001000')
    test(size, generate(size), '0b00000100')
    test(size, generate(size), '0b00000010')
    test(size, generate(size), '0b00000001')
    test(size, generate(size), '0b00000000')

  it 'size = 9', ->
    size = 9
    test(size, generate(size))

  it 'size = 17, 25, 33, 41, 49, 57', ->
    test(17, generate(17))
    test(25, generate(25))
    test(33, generate(33))
    test(41, generate(41))
    test(49, generate(49))
    test(57, generate(57))

  it 'size = 73', ->
    size = 73
    test(size, generate(size))

  it 'size = 129, 193, 257, 321, 385, 469', ->
    test(129, generate(129))
    test(193, generate(193))
    test(257, generate(257))
    test(321, generate(321))
    test(385, generate(385))
    test(449, generate(449))

  it 'size = 513', ->
    test(513, generate(513))

  it 'size = 1537', ->
    test(1537, generate(1537))

  it 'size = 30000', ->
    test(30000, generate(30000))
