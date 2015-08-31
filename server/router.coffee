Post = require('./controller/post')
Panel = require('./controller/panel')
Settings = require('./controller/settings')
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
    app.get '/panel/settings', passport.requireAuth, Settings.get
    app.post '/panel/settings', passport.requireAuth, Settings.post
    app.post '/panel/pictures/upload', passport.requireAuth, Panel.pictureUpload
    app.get '/panel/pictures/:id/rotate', passport.requireAuth, Panel.pictureRotate
    app.get '/panel/pictures/:id/delete', passport.requireAuth, Panel.pictureDelete
