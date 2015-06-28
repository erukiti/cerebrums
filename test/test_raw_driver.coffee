assert = require 'power-assert'
sinon = require 'sinon'

RawDriver = require '../src/raw_driver.coffee'

describe 'RawDriver', ->
  it '#blobWrite', ->
    dummyObservable = {}

    rxfs = {writeFile: -> null}
    mock = sinon.mock(rxfs)
    mock.expects("writeFile").once().withExactArgs("path", "hoge").returns(dummyObservable)

    rawDriver = new RawDriver(rxfs)
    observable = rawDriver.blobWrite("path", "hoge")

    assert observable == dummyObservable

    mock.verify()

