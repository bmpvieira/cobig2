# Serve JSON to our AngularJS client
request = require 'request'
crypto = require 'crypto'
querystring = require 'querystring'
redismod = require 'redis'
url = require 'url'
Linkedin = require '../modules/linkedin'

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

module.exports = exports =
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
    members: (req, res, next) ->
      if req.params.user?
        authUser = req.params.user
        url = "http://api.linkedin.com/v1/people/id=#{req.params.user}" +
          ":(email-address,summary,public-profile-url,primary-twitter-account)" +
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
            if err.statusCode is 401 and not req.params.user?
              # if fallback_user auth failed, try with linkedin app tokens
              # this could be default if app tokens wheren't invalidated
              # so often. TODO: Find why those invalidations happen
              linkedin.get url, (err, data) ->
                return next err if err
                try
                  JSONdata = JSON.parse data
                catch error
                  next error
                res.json data: JSONdata.people.values
            else
              return next err if err
          else
            try
              JSONdata = JSON.parse data
            catch error
              next error
            if req.params.user?
              res.json data: JSONdata
            else
              res.json data: JSONdata.people.values
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
