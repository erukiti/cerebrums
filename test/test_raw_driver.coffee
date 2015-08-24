# Copyright 2015 SASAKI, Shunsuke. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
