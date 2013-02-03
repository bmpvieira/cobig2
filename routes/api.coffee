# Serve JSON to our AngularJS client
request = require 'request'
crypto = require 'crypto'
querystring = require 'querystring'
redis = require('redis').createClient()
Linkedin = require '../modules/linkedin'

redis.on 'error', (err) ->
    console.log "Error: #{err}"

MENDELEY_CONSUMER_KEY = process.env.MENDELEY_CONSUMER_KEY
MENDELEY_GROUP = process.env.MENDELEY_GROUP

FACEBOOK_APP_ID = process.env.FACEBOOK_APP_ID
FACEBOOK_APP_SECRET = process.env.FACEBOOK_APP_SECRET
FACEBOOK_REDIRECT = process.env.FACEBOOK_REDIRECT
HOST = process.env.HOST

LINKEDIN_API_KEY = process.env.LINKEDIN_API_KEY
LINKEDIN_API_SECRET =process.env.LINKEDIN_API_SECRET
LINKEDIN_COMPANY = process.env.LINKEDIN_COMPANY

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
        redis.hget "linkedin:request:#{requestToken}", (err, data) ->
          return res.json err if err
          user = data.user
          requestSecret = data.requestSecret
          linkedin.getauth requestToken, requestSecret, req.query.oauth_verifier, (err, token, secret, data) ->
            redis.hmset "linkedin:#{user}",
              'token', token
              'secret', secret
              'expires', data.oauth_expires_in
            , (err) ->
              return res.json err if err
              res.json 'success'
    members: (req, res) ->
      if req.params.user?
        id = req.params.id
        # auth_linkedin = new Linkedin(
        #   LINKEDIN_API_KEY
        #   LINKEDIN_API_SECRET
        #   authorizations[id].token
        #   authorizations[id].secret
        # )
        # auth_linkedin.get 'http://api.linkedin.com/v1/people/~', (err, data) ->
        #   console.log data
        linkedin.get "http://api.linkedin.com/v1/people/id=#{req.params.user}" + 
          ":(email-address,summary,public-profile-url,primary-twitter-account)" + 
          "?format=json"
        , (err, data) ->
          return res.json err if err
          console.log JSON.parse data
          res.json data: JSON.parse data
      else
        linkedin.get "http://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,picture-url,headline),num-results)?company-name=#{LINKEDIN_COMPANY}&count=25&format=json", (err, data) =>
          return res.json err if err
          res.json data: JSON.parse(data).people.values
  mendeley:
    papers: (req, res) ->
      req.pipe(request("http://api.mendeley.com/oapi/documents/groups/#{MENDELEY_GROUP}/docs/?details=true&items=3&consumer_key=#{MENDELEY_CONSUMER_KEY}")).pipe(res)
  facebook:
    photos: (req, res) ->
      token = 'AAACORBwmBv0BAP79ncXAc4BxZAf3BrtGe2U4C1jmdLWZAl7WDmV64JxzmQDPbobufSjeTYiZASdR9kqYd9wNPXKHdEprVqSsyTPC0PutgZDZD'
      req.pipe(request("https://graph.facebook.com/#{req.params.album}/photos?access_token=#{token}")).pipe(res)
    authenticate:
      request: (req, res) ->
        crypto.randomBytes 48, (ex, buf) ->
          state = buf.toString 'hex'
          redis.set "state:#{state}", req.params.user
          res.json "https://www.facebook.com/dialog/oauth" +
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
