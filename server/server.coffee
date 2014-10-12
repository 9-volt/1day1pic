# Express
express = require('express')
cors = require('cors')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
methodOverride = require('method-override')
session = require('express-session')
exphbs  = require('express-handlebars')
db = require('./models')
passport = require('./helpers/passport')

# Configs
config = require('./../config.json')[process.env.APP_ENV]

# Server instance
server = null

# Modules
Router = require('./router')

app = express()
# View engine
app.set('views', __dirname + '/views/');
app.engine '.hbs', exphbs
  defaultLayout: 'main'
  helpers: require('./helpers/handlebars-helpers')
  layoutsDir: 'server/views/layouts/'
  partialsDir: 'server/views/partials/'
  extname: '.hbs'
app.set 'view engine', '.hbs'
# Parsers
app.use(cors())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: true}))
app.use(cookieParser())
app.use(methodOverride())
# Sessions
app.use(session({secret: config.sessionSecret}))
# passport initialization
app.use(passport.initialize())
app.use(passport.session())
# Router
Router.bindRoutes(app)
# Public
app.use(express.static(__dirname + '/../public'))

# Startup database connection and start app
db
  .sequelize
  .sync
    force: false
  .complete (err)->
    if err
      throw err[0]
    else
      server = app.listen(config.sitePort)
      console.log 'App started on port ' + config.sitePort

module.exports =
  stop: ()->
    server.close()
