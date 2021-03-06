# Express
express = require('express')
cors = require('cors')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
methodOverride = require('method-override')
session = require('express-session')
SessionStore = require('express-mysql-session')
exphbs  = require('express-handlebars')
flash = require('connect-flash')
db = require('./models')
fs = require('fs')
passport = require('./helpers/passport')
fb = require('./helpers/fb')

process.env.NODE_ENV = process.env.NODE_ENV || 'development'

# Configs
config = require('./../config.json')[process.env.NODE_ENV]

# Server instance
server = null

# Modules
Router = require('./router')

picturesPath = __dirname + '/../public/pictures'
tmpPath = __dirname + '/../tmp'

# Check if necessary folders exist
if not fs.existsSync(picturesPath) then fs.mkdir(picturesPath)
if not fs.existsSync(tmpPath) then fs.mkdir(tmpPath)

app = require('./helpers/app')
# Folders
app.set 'settings',
  picturesFolderPath: picturesPath
  tmpFolderPath: tmpPath
  config: config
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
app.use session
  secret: config.sessionSecret
  key: 'connect.sid'
  resave: true
  saveUninitialized: true
  store: new SessionStore
    host: config.host
    port: 3306
    user: config.username
    password: config.password
    database: config.database
app.use(flash())
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
  .then (err)->
    server = app.listen(config.sitePort)
    fb.start() # Start FB posting
    console.log 'App started on port ' + config.sitePort
  .catch (err)->
    console.log err

module.exports =
  stop: ()->
    server.close()
