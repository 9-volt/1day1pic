Post = require('./controller/post')
Panel = require('./controller/panel')
passport = require('./helpers/passport')

ensureAuthenticated = (req, res, next)->
  return next() if req.isAuthenticated()
  res.redirect('/login')

module.exports =
  bindRoutes: (app)->
    app.get '/', Post.getIndex
    app.get '/post/:date', Post.getDate

    app.get '/login', Panel.getLogin
    app.post '/auth/local', Panel.postLogin
    app.get '/logout', Panel.getLogout
    app.get '/panel', ensureAuthenticated, Panel.get
