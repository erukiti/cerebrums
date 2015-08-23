FmIndex = require './fm_index.coffee'

_ = require 'underscore'

class Searcher
  constructor: (docs) ->
    @docsText = {}
    @docsTitle = {}
    @docsUpdatedAt = {}
    @docsTags = {}
    @docsStar = {}

    for doc in docs
      @docsText[doc.meta.uuid] = {uuid: doc.meta.uuid, text: doc.text}
      @docsTitle[doc.meta.uuid] = {uuid: doc.meta.uuid, text: doc.meta.title}
      @docsTags[doc.meta.uuid] = {uuid: doc.meta.uuid, text: doc.meta.tags}
      @docsStar[doc.meta.uuid] = {uuid: doc.meta.uuid, text: doc.meta.star}
      @docsUpdatedAt[doc.meta.uuid] = {meta: doc.meta}

    console.time('searcher index create')
    @fmIndexText = new FmIndex(_.map(@docsText, (docs) -> docs))
    @fmIndexTitle = new FmIndex(_.map(@docsTitle, (docs) -> docs))
    @fmIndexTags = new FmIndex(_.map(@docsTags, (docs) -> docs))
    @fmIndexStar = new FmIndex(_.map(@docsStar, (docs) -> docs))
    console.timeEnd('searcher index create')

  add: (meta, text) ->
    @docsText[meta.uuid] = {uuid: meta.uuid, text: text}
    @docsText[meta.uuid] = {uuid: meta.uuid, text: meta.title}
    @docsTags[meta.uuid] = {uuid: meta.uuid, text: meta.tags}
    @docsStar[meta.uuid] = {uuid: meta.uuid, text: meta.star}
    @docsUpdatedAt[meta.uuid] = {meta:meta}

    console.time('searcher index create')
    @fmIndexText = new FmIndex(_.map(@docsText, (docs) -> docs))
    @fmIndexTitle = new FmIndex(_.map(@docsTitle, (docs) -> docs))
    @fmIndexTags = new FmIndex(_.map(@docsTags, (docs) -> docs))
    @fmIndexStar = new FmIndex(_.map(@docsStar, (docs) -> docs))
    console.timeEnd('searcher index create')

  search: (queryString) ->
    results = []
    for q in queryString.trim().split(' ')
      if q.substr(0, 5) == 'tags:'
        isTags = true
        isStar = false
        isTitle = false
        isText = false
        q = q.substr(5)
      else if q.substr(0, 5) == 'star:'
        isTags = false
        isStar = true
        isTitle = false
        isText = false
        q = '1'
      else if q.substr(0, 6) == 'title:'     
        isTags = false
        isStar = false
        isTitle = true
        isText = false
        q = q.substr(6)
      else if q.substr(0,5) == 'text:'
        isTags = false
        isStar = false
        isTitle = false
        isText = true
        q = q.substr(5)
      else
        isTags = true
        isStar = true
        isTitle = true
        isText = true

      continue if q == ''

      result = []
      if isTags
        for res in @fmIndexTags.search(q, 50).results
          result.push res.uuid
      if isStar
        for res in @fmIndexStar.search(q, 50).results
          result.push res.uuid
      if isTitle
        for res in @fmIndexTitle.search(q, 50).results
          result.push res.uuid
      if isText
        for res in @fmIndexText.search(q, 50).results
          result.push res.uuid
      results.push result

    results = _.reduce results, (memo, result) =>
      if memo
        _.intersection(memo, result)
      else
        result
    , null

    _.map(_.map(results, (uuid) => uuid).sort(), (uuid) => @docsUpdatedAt[uuid].meta)

  getRecent: ->
    _.map(_.sortBy(_.map(@docsUpdatedAt, (doc) -> doc), (doc) -> -doc.meta.updatedAt), (doc) -> doc.meta)

module.exports = Searcher
