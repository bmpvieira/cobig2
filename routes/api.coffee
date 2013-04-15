# Serve JSON to our AngularJS client
request = require 'request'
crypto = require 'crypto'
querystring = require 'querystring'
redismod = require 'redis'
url = require 'url'
Linkedin = require '../modules/linkedin'
Dropbox = require '../modules/dropbox'

if process.env.REDISTOGO_URL
  rtg = url.parse(process.env.REDISTOGO_URL)
  redis = redismod.createClient(rtg.port, rtg.hostname)
  redis.auth rtg.auth.split(':')[1]
else
  redis = redismod.createClient()

redis.on 'error', (err) -> console.error "Error: #{err}"

MENDELEY_CONSUMER_KEY = process.env.MENDELEY_CONSUMER_KEY
MENDELEY_GROUP = process.env.MENDELEY_GROUP

FACEBOOK_APP_ID = process.env.FACEBOOK_APP_ID
FACEBOOK_APP_SECRET = process.env.FACEBOOK_APP_SECRET
FACEBOOK_REDIRECT = process.env.FACEBOOK_REDIRECT
HOST = process.env.HOST

LINKEDIN_API_KEY = process.env.LINKEDIN_API_KEY
LINKEDIN_API_SECRET =process.env.LINKEDIN_API_SECRET
LINKEDIN_COMPANY = process.env.LINKEDIN_COMPANY
LINKEDIN_FALLBACK_USER = process.env.LINKEDIN_FALLBACK_USER

linkedin = new Linkedin(
  LINKEDIN_API_KEY
  LINKEDIN_API_SECRET
  process.env.LINKEDIN_USER_TOKEN
  process.env.LINKEDIN_USER_SECRET
)

DROPBOX_APP_KEY = process.env.DROPBOX_APP_KEY
DROPBOX_APP_SECRET = process.env.DROPBOX_APP_SECRET
DROPBOX_FALLBACK_USER = process.env.DROPBOX_FALLBACK_USER

dropbox = new Dropbox(
  DROPBOX_APP_KEY
  DROPBOX_APP_SECRET
)

module.exports = exports = API =
  dropbox:
    authenticate:
      request: (req, res) ->
        return res.json 'Error: no user ID specified' if not req.params.user?
        dropbox.auth (err, requestToken, requestSecret, url) ->
          return res.json err if err
          redis.hmset "dropbox:request:#{requestToken}",
            'user', req.params.user
            'secret', requestSecret
          res.redirect url
      get: (req, res) ->
        return res.json 'Error: no token' if not req.query.oauth_token?
        return res.json 'Error: user refused' if req.query.oauth_problem is "user_refused"
        requestToken = req.query.oauth_token
        user_uid = req.query.user_uid
        redis.hgetall "dropbox:request:#{requestToken}", (err, data) ->
          return res.json err if err
          user = data.user
          requestSecret = data.secret
          dropbox.getauth requestToken, requestSecret, (err, token, secret, data) ->
            return res.json err if err
            redis.hmset "dropbox:#{user}",
              'token', token
              'secret', secret
              'user_uid', data.uid
              (err) ->
                return res.json err if err
                res.json 'success'
    ls: (req, res, next) ->
      authUser = DROPBOX_FALLBACK_USER
      url = "https://api.dropbox.com/1/metadata/sandbox"
      redis.hgetall "dropbox:#{authUser}", (err, data) ->
        return next err if err
        return res.json 'autentication needed' if not data?
        auth_dropbox = new Dropbox(
          DROPBOX_APP_KEY
          DROPBOX_APP_SECRET
          data.token
          data.secret
        )
        auth_dropbox.get url, (err, data) =>
          return next err if err
          try
            JSONdata = JSON.parse data
          catch error
            next error
          res.json data: JSONdata
    get: (first, second, callback) ->
      authUser = DROPBOX_FALLBACK_USER
      url = "https://api-content.dropbox.com/1/files/sandbox/#{first}/"
      if second
        url = url.concat(second)
      redis.hgetall "dropbox:#{authUser}", (err, data) ->
        return callback err if err
        return callback 'autentication needed' if not data?
        auth_dropbox = new Dropbox(
          DROPBOX_APP_KEY
          DROPBOX_APP_SECRET
          data.token
          data.secret
        )
        auth_dropbox.get url, (err, data) =>
          callback data
    files: (req, res, next) ->
      API.dropbox.get req.params.first, req.params.second, (data) ->
        try
          JSONdata = JSON.parse data
          res.json JSONdata
        catch error
          res.send data
    media: (req, res, next) ->
      authUser = DROPBOX_FALLBACK_USER
      url = "https://api.dropbox.com/1/media/sandbox/media/#{req.params.file}"
      redis.hgetall "dropbox:#{authUser}", (err, data) ->
        return next err if err
        return res.json 'autentication needed' if not data?
        auth_dropbox = new Dropbox(
          DROPBOX_APP_KEY
          DROPBOX_APP_SECRET
          data.token
          data.secret
        )
        auth_dropbox.get url, (err, data) =>
          request(JSON.parse(data).url).pipe(res)
    files_put: (filename, content, type) ->
      authUser = DROPBOX_FALLBACK_USER
      redis.hgetall "dropbox:#{authUser}", (err, data) ->
        return console.error  err if err
        return console.error 'autentication needed' if not data?
        auth_dropbox = new Dropbox(
          DROPBOX_APP_KEY
          DROPBOX_APP_SECRET
          data.token
          data.secret
        )
        auth_dropbox.put filename, content, type, (err, data) =>
          console.error err if err
  linkedin:
    authenticate: 
      request: (req, res) ->
        return res.json 'Error: no user ID specified' if not req.params.user?
        linkedin.auth (err, requestToken, requestSecret, url) ->
          return res.json err if err
          redis.hmset "linkedin:request:#{requestToken}",
            'user', req.params.user
            'secret', requestSecret
          res.redirect url
      get: (req, res) ->
        return res.json 'Error: no token' if not req.query.oauth_token?
        return res.json 'Error: user refused' if req.query.oauth_problem is "user_refused"
        requestToken = req.query.oauth_token
        redis.hgetall "linkedin:request:#{requestToken}", (err, data) ->
          return res.json err if err
          user = data.user
          requestSecret = data.secret
          linkedin.getauth requestToken, requestSecret, req.query.oauth_verifier, (err, token, secret, data) ->
            return res.json err if err
            redis.hmset "linkedin:#{user}",
              'token', token
              'secret', secret
              'expires', data.oauth_expires_in
              (err) ->
                return res.json err if err
                res.json 'success'
    getMembersFromDropbox: (req, res, next) ->
      if req.params.user?
        API.dropbox.get req.params.folder, "#{req.params.user}.json", (data) ->
          try
            JSONdata = JSON.parse data
            res.json data: JSONdata
          catch error
            next error
      else
        API.dropbox.get req.params.folder, 'list.json', (data) ->
          try
            JSONdata = JSON.parse data
            if JSONdata.people?
              res.json data: JSONdata.people.values
            else
              res.json error: "No people: #{JSONdata}"
          catch error
            next error
    members: (req, res, next) ->
      if req.params.user?
        authUser = req.params.user
        url = "http://api.linkedin.com/v1/people/id=#{req.params.user}" +
          ":(id,first-name,last-name,email-address,summary,public-profile-url,primary-twitter-account)" +
          "?format=json"
      else
        authUser = LINKEDIN_FALLBACK_USER
        url = "http://api.linkedin.com/v1/people-search" +
          ":(people:(id,first-name,last-name,picture-url,headline),num-results)" +
          "?company-name=#{LINKEDIN_COMPANY}&count=25&format=json"
      redis.hgetall "linkedin:#{authUser}", (err, data) ->
        return next err if err
        return res.json 'autentication needed' if not data?
        auth_linkedin = new Linkedin(
          LINKEDIN_API_KEY
          LINKEDIN_API_SECRET
          data.token
          data.secret
        )
        auth_linkedin.get url, (err, data) =>
          if err?
            if err.statusCode is 401
              # get data from Dropbox archive
              req.params.folder = 'members'
              API.getMembersFromDropbox req, res, next
            else
              return next err if err
          else
            try
              JSONdata = JSON.parse data
            catch error
              next error
            if req.params.user?
              res.json data: JSONdata
              API.dropbox.files_put "members/#{JSONdata.id}_#{JSONdata.firstName}_#{JSONdata.lastName}.json", data, 'application/json'
            else
              res.json data: JSONdata.people.values
              API.dropbox.files_put "members/list.json", data, 'application/json'
  mendeley:
    papers: (req, res) ->
      req.pipe(request("http://api.mendeley.com/oapi/documents/groups/#{MENDELEY_GROUP}/docs/?details=true&consumer_key=#{MENDELEY_CONSUMER_KEY}")).pipe(res)
  facebook:
    photos: (req, res) ->
      redis.hgetall "facebook:#{LINKEDIN_FALLBACK_USER}", (err, data) ->
        return res.json err if err
        token = data.token
        request "https://graph.facebook.com/#{req.params.album}/photos?access_token=#{token}", (err, response, body) ->
          return res.json err if err
          res.json JSON.parse body
    authenticate:
      request: (req, res) ->
        crypto.randomBytes 48, (ex, buf) ->
          state = buf.toString 'hex'
          redis.set "state:#{state}", req.params.user
          res.redirect "https://www.facebook.com/dialog/oauth" +
            "?client_id=#{FACEBOOK_APP_ID}" +
            "&redirect_uri=#{HOST}#{FACEBOOK_REDIRECT}" +
            "&state=#{state}" +
            "&scope=offline_access,user_photos,friends_photos"
      get: (req, res) ->
        redis.get "state:#{req.query.state}", (err, user) ->
          return res.json err if err
          request
            url: "https://graph.facebook.com/oauth/access_token" +
              "?client_id=#{FACEBOOK_APP_ID}" +
              "&client_secret=#{FACEBOOK_APP_SECRET}" +
              "&redirect_uri=#{HOST}#{FACEBOOK_REDIRECT}" +
              "&code=#{req.query.code}"
            json: true
          , (err, response, body) ->
            return res.json err if err
            data = querystring.parse body
            redis.hmset "facebook:#{user}",
              'token', data.access_token
              'expires', data.expires
              (err) ->
                return res.json err if err
                res.json 'success'
