#! /usr/bin/env coffee

Rx = require 'rx'

Rx.Observable.merge(
  Rx.Observable.just(10),
  Rx.Observable.just(15)
).subscribe (x) ->
  console.dir x

path = require 'path'
console.log path.resolve('/User/erukiti/.cerebrums/blob/e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855')

Error.prepareStackTrace = (e, st)->
  console.dir e
  console.dir st
  "MyStackObject";
try
  throw new Error();
catch e
  console.log(e.stack);

