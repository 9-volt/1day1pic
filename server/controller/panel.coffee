db = require('../models')
passport = require('../helpers/passport')

panelController =
  getLogin: (req, res)->
    # res.send 'ok'
    if req.user
      # already logged in
      res.redirect('/panel')
    else
      # not logged in, show the login form, remember to pass the message
      # for displaying when error happens
      res.render 'login',
        layout: 'panel'
        message: req.session.messages

      # and then remember to clear the message
      req.session.messages = null

  postLogin: (req, res, next)->
    # ask passport to authenticate
    passport.authenticate('local', (err, user, info) ->

      # if error happens
      return next(err) if err
      unless user
        # if authentication fail, get the error message that we set
        # from previous (info.message) step, assign it into to
        # req.session and redirect to the login page again to display
        req.session.messages = info.message
        return res.redirect('/login')

      # if everything's OK
      req.logIn user, (err) ->
        if err
          req.session.messages = 'Error'
          return next(err)

        # set the message
        req.session.messages = 'Login successfully'
        res.redirect '/panel'

      return
    ) req, res, next

  getLogout: (req, res)->
    if req.isAuthenticated()
      req.logout()

    res.redirect('/login')

  get: (req, res)->
    res.send 'panel ok'

module.exports = panelController
