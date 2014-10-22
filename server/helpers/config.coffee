_ = require('lodash')

module.exports =
  renderOptions: (options)->
    _.merge
      pageTitle: '1day1pic'
      env: process.env.NODE_ENV
    , options
