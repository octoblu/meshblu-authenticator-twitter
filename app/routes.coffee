class Router
  constructor: (@app) ->

  register: =>
    @app.get '/', (request, response) =>
      # response.json({ awesome : true });
      response.render('index')

module.exports = Router
