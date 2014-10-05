# Express
express = require('express')
cors = require('cors')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
methodOverride = require('method-override')
exphbs  = require('express-handlebars')

# Configs
config = require('./../config')[process.env.APP_ENV]
port = config.port

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
# Router
Router.bindRoutes(app)
# Public
app.use(express.static(__dirname + '/../public'))

server = app.listen(port)

console.log "server started on port #{port}"

module.exports =
  stop: ()->
    server.close()
