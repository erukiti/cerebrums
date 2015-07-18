WaveletMatrix = require './wavelet_matrix.coffee'

class BWT
  lf = (wm, ind, c, length) =>
    wm.rank(ind, c) + wm.rankLessThan(length, c)

  @encode = (s) ->
    ary = [0..s.length].sort (a, b) =>
       while true
        return -1 if a == s.length
        return 1 if b == s.length
        return -1 if s.charCodeAt(a) < s.charCodeAt(b)
        return 1 if s.charCodeAt(a) > s.charCodeAt(b)
        a++
        b++

    # console.dir ary
    result = ''
    ind = 0
    last = null
    for a in ary
      if a == 0
        last = ind
      else
        result += s[a - 1]
      ind++

    {
      string: result
      last: last
    }

  @decode = (s, last) ->

    # console.log "decode: #{s}"

    wm = new WaveletMatrix(s)
    ind = last
    result = ''
    i = 0
    while i < s.length
      # console.log "loop: #{ind} #{lf(wm, ind, s[ind])}"
      ind = lf(wm, ind, s[ind], s.length)
      result = "#{s[ind]}#{result}"
      i++

    result

  @search = (s, q) ->
    console.log "search: #{q}"

    wm = new WaveletMatrix(s)
    start = 0
    end = s.length

    i = q.length - 1
    while i >= 0
      c = q[i]
      start = lf(wm, start, c, s.length)
      end = lf(wm, end, c, s.length)
      return [] if start >= end
      i--

    for ind in [start...end]
      pos = 0
      while s[ind] != '$'
        ind = lf(wm, ind, s[ind], s.length)
        pos++
      pos

module.exports = BWT
