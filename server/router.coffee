Post = require('./controller/post')
Panel = require('./controller/panel')
Auth = require('./controller/auth')
passport = require('./helpers/passport')

module.exports =
  bindRoutes: (app)->
    app.get '/', Post.getIndex
    app.get '/post/:date', Post.getDate

    app.get '/login', Auth.getLogin
    app.post '/auth/local', Auth.postLogin
    app.get '/logout', Auth.getLogout

    app.get '/panel', passport.requireAuth, Panel.get
    app.post '/panel/pictures/upload', passport.requireAuth, Panel.pictureUpload
