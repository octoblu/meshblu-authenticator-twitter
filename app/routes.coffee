passport = require 'passport'

class Router
  constructor: (@app) ->

  register: =>
    @app.get '/', (request, response) =>
      response.render('index')

    @app.get '/login', passport.authenticate('twitter')

    @app.get '/api/auth/callback',
      passport.authenticate('twitter', { failureRedirect: '/login' }),
      (request, response) =>
        response.redirect('/')

module.exports = Router
