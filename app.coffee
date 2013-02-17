# Module dependencies
express = require 'express'
yaml = require 'js-yaml'
assets = require 'connect-assets'

RedisStore = require("connect-redis")(express)

routes = require './routes'
api = require './routes/api'
config = require './config.yaml'

privateAuth = require './modules/privateAuth'

app = module.exports = express()

# Configuration
app.locals config
app.configure ->
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  # Sessions
  app.use express.cookieParser()
  app.use express.session store: new RedisStore, secret: 'secret trolololo'
  # Assets
  app.use assets()
  app.use express.static "#{__dirname}/public"

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  app.use express.errorHandler()

app.configure 'staging', ->
  app.use privateAuth

# Routes
app.get '/', routes.index
app.get '/templates/:name', routes.templates
app.get '/partials/:name', routes.partials

# JSON API
app.get '/api/linkedin/members', api.linkedin.members
app.get '/api/linkedin/members/:user', api.linkedin.members
app.get '/api/linkedin/authenticate/request/:user', api.linkedin.authenticate.request
app.get '/api/linkedin/authenticate/get', api.linkedin.authenticate.get
app.get '/api/facebook/authenticate/request/:user', api.facebook.authenticate.request
app.get '/api/facebook/authenticate/get', api.facebook.authenticate.get
app.get '/api/facebook/photos/:album', api.facebook.photos
app.get '/api/mendeley/papers', api.mendeley.papers

# redirect all others to the index (HTML5 history)
app.get '*', routes.index unless app.get 'env' is 'staging'

# error handler
app.use (err, req, res, next) ->
  console.error err
  res.json err

# Start server
port = process.argv[2] or process.env.PORT or 3000;
app.listen port, ->
  console.log "Express server listening on port %d in %s mode", @address().port, app.settings.env
