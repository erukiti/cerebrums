assert = require 'power-assert'
sinon = require 'sinon'

Rx = require 'rx'

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

    rxfs = {readFile: -> null}
    stub = sinon.stub(rxfs, 'readFile')
    stub.withArgs('/path/blob/1234').returns(dummyObservable)

    rawDriver = new RawDriver(rxfs, {basePath: '/path'})
    assert rawDriver.readBlob('1234') == dummyObservable

    assert stub.calledOnce

  it '#readPointer', ->
    dummyObservable = {}

    rxfs = {readFile: -> null}
    stub = sinon.stub(rxfs, 'readFile')
    stub.withArgs("/path/pointer/1234").returns(dummyObservable)

    rawDriver = new RawDriver(rxfs, {basePath: '/path'})
    assert rawDriver.readPointer('1234') == dummyObservable

    assert stub.calledOnce

  it '#getAllPointer', ->
    dummyObservable = {}
    dummyFunc = -> null
    rxfs = {readDir: dummyFunc}
    stubReaddir = sinon.stub(rxfs, 'readDir')
    stubReaddir.withArgs('/path/pointer').returns(Rx.Observable.just(['/path/pointer/1111']))

    rawDriver = new RawDriver(rxfs, {basePath: '/path'})
    rawDriver.getAllPointer().toArray().subscribe (uuids) ->
      assert.deepEqual uuids, ['1111']

    assert stubReaddir.calledOnce
