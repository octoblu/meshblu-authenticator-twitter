express = require 'express'
morgan = require 'morgan'
bodyParser = require 'body-parser'
errorHandler = require 'errorhandler'
cookieParser = require 'cookie-parser'
session = require 'cookie-session'
passport = require 'passport'
Router = require './app/routes'
Config = require './app/config'
MeshbluHttp = require 'meshblu-http'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
airbrake = require('airbrake').createClient process.env.AIRBRAKE_API_KEY
debug = require('debug')('meshblu-twitter-authenticator:server')

port = process.env.MESHBLU_TWITTER_AUTHENTICATOR_PORT ? 80

app = express()
app.use morgan('dev')
app.use errorHandler()
app.use meshbluHealthcheck()
app.use airbrake.expressHandler()
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)
app.use cookieParser()

app.use session
  secret: 'super awesome cool secret'
  resave: false
  saveUninitialized: true

app.use passport.initialize()
app.use passport.session()

passport.serializeUser (user, done) =>
  done null, user.id

passport.deserializeUser (user, done) =>
  done null, user

app.engine 'html', require('ejs').renderFile

app.set 'view engine', 'html'

app.set 'views', __dirname + '/app/views'

try
  meshbluJSON  = require './meshblu.json'
catch
  meshbluJSON =
    uuid:   process.env.MESHBLU_TWITTER_AUTHENTICATOR_UUID
    token:  process.env.MESHBLU_TWITTER_AUTHENTICATOR_TOKEN
    server: process.env.MESHBLU_HOST
    port:   process.env.MESHBLU_PORT
    name:   'Twitter Authenticator'

meshbluHttp = new MeshbluHttp meshbluJSON

meshbluHttp.device meshbluJSON.uuid, (error, device) ->
  if error?
    console.error error.message, error.stack
    process.exit 1

  meshbluHttp.setPrivateKey(device.privateKey) unless meshbluHttp.privateKey

config = new Config {meshbluHttp, meshbluJSON}
config.register()

router = new Router app
router.register()

app.listen port, =>
  debug "Meshblu Twitter Authenticator..."
  debug "Listening at localhost:#{port}"
