#! /usr/bin/env coffee

Rx = require 'rx'
rxfs = require 'rxjs-fs'

# console.dir rxfs.fs.read

rxfs.fs.readfile('dummy').subscribe(
  (x) -> console.dir x
  (err) -> console.dir err.code
  ->  console.dir 'comp'
)

# .subscribe(
#   (x) -> console.dir x
#   , (err) ->
#     console.dir "wrr"
#   , -> console.dir 'completed'
# )
