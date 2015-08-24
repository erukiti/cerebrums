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

FmIndex = require '../src/fm_index.coffee'

describe 'FmIndex', ->
  it '', ->
    fmIndex = new FmIndex([
      {uuid: "hoge1", text: "abracadabra"},
      {uuid: "lorem", text: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."},
      {uuid: "nihongo", text: "ほげ♡"},
    ])
    # console.dir fmIndex.search("psum")

    # console.dir fmIndex.search("a", 10)

    # console.dir fmIndex.search("ほ")
    # console.dir fmIndex.search("♡")

