express = require 'express'
morgan = require 'morgan'
bodyParser = require 'body-parser'
errorHandler = require 'errorhandler'
Router = require './app/routes'
debug = require('debug')('meshblu-twitter-authenticator:index')

port = process.env.MESHBLU_TWITTER_AUTHENTICATOR_PORT ? 8007

app = express()
app.use morgan('dev')
app.use errorHandler()
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)

app.engine 'html', require('ejs').renderFile

app.set 'view engine', 'html'

app.set 'views', __dirname + '/app/views'

app.listen port, =>
  debug "Meshblu Twitter Authenticator..."
  debug "Listening at localhost:#{port}"

  router = new Router(app)
  router.register()
