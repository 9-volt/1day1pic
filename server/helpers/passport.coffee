db = require('../models')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy

# Serialize sessions
passport.serializeUser (user, done)->
  done(null, user.id)

# Deserialize user
passport.deserializeUser (id, done)->
  db.User.find({where: {id: id}})
    .success  (user)->
      done(null, user)
    .error (err)->
      done(err, null)

# Use local strategy
passport.use new LocalStrategy
    usernameField: 'email'
    passwordField: 'password'
  ,
  (email, password, done)->
    db.User.find({where: {email: email }})
      .success (user)->
        if not user
          done(null, false, { message: 'Unknown user' })
        else if not user.authenticate(password)
          done(null, false, { message: 'Invalid password'})
        else
          done(null, user)
      .error (err)->
        done(err)

# passport.requireAuth = (req, res, next)->
#   # check if the user is logged in
#   if not req.isAuthenticated()
#     req.session.messages = 'You need to login to view this page'
#     res.redirect('/login')

#   next()

module.exports = passport
