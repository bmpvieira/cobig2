# Module dependencies
express = require 'express'
yaml = require 'js-yaml'
assets = require 'connect-assets'

routes = require './routes'
api = require './routes/api'
config = require './config.yaml'

app = module.exports = express()

# Configuration
app.locals config
app.configure ->
  app.use assets()
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static "#{__dirname}/public"
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure "production", ->
  app.use express.errorHandler()

# Routes
app.get '/', routes.index
app.get '/partials/:name', routes.partials

# JSON API
app.get '/api/name', api.name
app.get '/api/members', api.members
app.get '/api/members/:id', api.members
app.get '/api/papers', api.papers

# redirect all others to the index (HTML5 history)
app.get '*', routes.index

# Start server
app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", @address().port, app.settings.env
