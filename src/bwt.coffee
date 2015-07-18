WaveletMatrix = require './wavelet_matrix.coffee'

class BWT
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
    lf = (wm, ind, c) =>
      wm.rank(ind, c) + wm.rankLessThan(s.length, c)

    # console.log "decode: #{s}"

    wm = new WaveletMatrix(s)
    ind = last
    result = ''
    i = 0
    while i < s.length
      # console.log "loop: #{ind} #{lf(wm, ind, s[ind])}"
      ind = lf(wm, ind, s[ind])
      result = "#{s[ind]}#{result}"
      i++

    result

module.exports = BWT
