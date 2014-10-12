db = require('../models')
passport = require('../helpers/passport')

panelController =
  get: (req, res)->
    res.send 'panel ok'

module.exports = panelController
