module.exports =
  eq: (v1, v2, options)->
    if v1 is v2
      return options.fn(this)
    else
      return options.inverse(this)
