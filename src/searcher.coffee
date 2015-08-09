FmIndex = require './fm_index.coffee'

_ = require 'underscore'

class Searcher
  constructor: (docs) ->
    @docsText = {}
    @docsTitle = {}

    for doc in docs
      @docsText[doc.meta.uuid] = {uuid: doc.meta.uuid, text: doc.text}
      @docsTitle[doc.meta.uuid] = {uuid: doc.meta.uuid, text: doc.meta.title}

    console.time('searcher index create')
    @fmIndexText = new FmIndex(_.map(@docsText, (docs) -> docs))
    @fmIndexTitle = new FmIndex(_.map(@docsTitle, (docs) -> docs))
    console.timeEnd('searcher index create')

  add: (meta, text) ->
    @docsText[meta.uuid] = {uuid: meta.uuid, text: text}
    @docsText[meta.uuid] = {uuid: meta.uuid, text: meta.title}

    console.time('searcher index create')
    @fmIndexText = new FmIndex(_.map(@docsText, (docs) -> docs))
    @fmIndexTitle = new FmIndex(_.map(@docsTitle, (docs) -> docs))
    console.timeEnd('searcher index create')

  search: (q) ->
    results = {}
    for result in @fmIndexText.search(q, 50).results
      results[result.uuid] = result.uuid
    for result in @fmIndexTitle.search(q, 50).results
      results[result.uuid] = result.uuid

    _.map(results, (uuid) -> uuid).sort()

module.exports = Searcher
