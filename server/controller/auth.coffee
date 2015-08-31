passport = require('../helpers/passport')

authController =
  getLogin: (req, res)->
    # res.send 'ok'
    if req.user
      # already logged in
      res.redirect('/panel')
    else
      # not logged in
      res.render 'login',
        layout: 'panel'
        message: req.flash 'message'

  postLogin: (req, res, next)->
    # ask passport to authenticate
    passport.authenticate('local', (err, user, info) ->

      # if error happens
      return next(err) if err
      unless user
        req.flash 'message',
          text: info.message
          type: 'danger'
        return res.redirect('/login')

      # if everything's OK
      req.logIn user, (err) ->
        if err
          req.flash 'message',
            text: 'Error'
            type: 'danger'
          return next(err)

        # set the message
        req.flash 'message',
          text: 'Successful authentication'
          type: 'success'
        res.redirect '/panel'

      return
    ) req, res, next

  getLogout: (req, res)->
    if req.isAuthenticated()
      req.logout()

    res.redirect('/login')

module.exports = authController
