_ = require('lodash')
path = require('path')
db = require('../models')
passport = require('../helpers/passport')
Busboy = require('busboy')

settingsController =
  get: (req, res)->
    res.render 'settings',
      layout: 'panel'
      message: req.flash 'message'

  sendError: (req, res, text='Error', type='danger')->
    req.flash 'message',
      text: text
      type: type
    res.redirect('/panel/settings')

  post: (req, res)->
    if req.body.password
      settingsController.updatePassword(req, res, req.body.password)
    else
      settingsController.sendError(req, res, 'No password specified')

  updatePassword: (req, res, password)->
    sendError = (text, type) ->
      settingsController.sendError(req, res, text, type)

    if req.user
      req.user.updatePassword(password)
        .then ->
          sendError('Password successfully updated', 'success')
        .error ->
          sendError('Updating password failed')
    else
      sendError('Something is wrong with user session')

module.exports = settingsController
