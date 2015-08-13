db = require('../models')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy

# Serialize sessions
passport.serializeUser (user, done)->
  done(null, user.id)

# Deserialize user
passport.deserializeUser (id, done)->
  db.User.find({where: {id: id}})
    .then  (user)->
      done(null, user)
    .catch (err)->
      done(err, null)

# Use local strategy
passport.use new LocalStrategy
    usernameField: 'email'
    passwordField: 'password'
  ,
  (email, password, done)->
    db.User.find({where: {email: email }})
      .then (user)->
        if not user
          done(null, false, { message: 'Unknown user' })
        else if not user.authenticate(password)
          done(null, false, { message: 'Invalid password'})
        else
          done(null, user)
      .catch (err)->
        done(err)

passport.requireAuth = (req, res, next)->
  return next() if req.isAuthenticated()

  req.session.messages = 'You need to login to view this page'
  res.redirect('/login')

module.exports = passport
