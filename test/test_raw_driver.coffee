require 'source-map-support'

assert = require 'power-assert'
sinon = require 'sinon'

RawDriver = require '../src/raw_driver.coffee'

describe 'RawDriver', ->
  it '#writeBlob', ->
    dummyObservable = {}

    rxfs = {writeFile: -> null}

    stub = sinon.stub(rxfs, 'writeFile')
    stub.withArgs('/path/blob/1234', 'hoge').returns(dummyObservable)

    rawDriver = new RawDriver(rxfs, {basePath: '/path'})
    assert rawDriver.writeBlob('1234', 'hoge') == dummyObservable

    assert stub.calledOnce

    # mock.verify()

  it '#writePointer', ->
    dummyObservable = {}

    rxfs = {writeFile: -> null}
    stub = sinon.stub(rxfs, 'writeFile')
    stub.withArgs('/path/pointer/1234', 'hoge').returns(dummyObservable)

    rawDriver = new RawDriver(rxfs, {basePath: '/path'})
    assert rawDriver.writePointer('1234', 'hoge') == dummyObservable

    assert stub.calledOnce

  it '#readBlob', ->
    dummyObservable = {}

    rxfs = {readfile: -> null}
    stub = sinon.stub(rxfs, 'readfile')
    stub.withArgs('/path/blob/1234').returns(dummyObservable)

    rawDriver = new RawDriver(rxfs, {basePath: '/path'})
    assert rawDriver.readBlob('1234') == dummyObservable

    assert stub.calledOnce

  it '#readPointer', ->
    dummyObservable = {}

    rxfs = {readfile: -> null}
    stub = sinon.stub(rxfs, 'readfile')
    stub.withArgs("/path/pointer/1234").returns(dummyObservable)

    rawDriver = new RawDriver(rxfs, {basePath: '/path'})
    assert rawDriver.readPointer('1234') == dummyObservable

    assert stub.calledOnce
