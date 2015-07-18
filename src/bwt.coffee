class BWT
  encode: (s) ->
    ary = [0..s.length].sort (a, b) =>
       while true
        return -1 if a == s.length
        return 1 if b == s.length
        return -1 if s.charCodeAt(a) < s.charCodeAt(b)
        return 1 if s.charCodeAt(a) > s.charCodeAt(b)
        a++
        b++

    console.dir ary
    result = ''
    for a in ary
      if a == 0
        result += '$'
      else
        result += s[a - 1]

    result

module.exports = BWT
