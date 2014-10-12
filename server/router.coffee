Post = require('./controller/post')
Panel = require('./controller/panel')
passport = require('./helpers/passport')

module.exports =
  bindRoutes: (app)->
    app.get '/', Post.getIndex
    app.get '/post/:date', Post.getDate

    app.get '/login', Panel.getLogin
    app.post '/auth/local', Panel.postLogin
    app.get '/logout', Panel.getLogout
    app.get '/panel', passport.requireAuth, Panel.get
