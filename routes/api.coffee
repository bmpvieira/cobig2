# Serve JSON to our AngularJS client
request = require 'request'
Linkedin = require '../modules/linkedin'

LINKEDIN_API_KEY = process.env.LINKEDIN_API_KEY
LINKEDIN_API_SECRET =process.env.LINKEDIN_API_SECRET
LINKEDIN_COMPANY = process.env.LINKEDIN_COMPANY

MENDELEY_CONSUMER_KEY = process.env.MENDELEY_CONSUMER_KEY
MENDELEY_GROUP = process.env.MENDELEY_GROUP


linkedin = new Linkedin(
  LINKEDIN_API_KEY
  LINKEDIN_API_SECRET
  process.env.LINKEDIN_USER_TOKEN
  process.env.LINKEDIN_USER_SECRET
)

authorizations_requests = {}
authorizations = {}

module.exports = exports =
  authenticate: (req, res) ->
    console.log req.query
    if req.query.oauth_token #4d57eaac-0840-46f7-81a1-5d5bbada6202
      if req.query.oauth_problem is "user_refused"
        res.redirect '/'
      else
        token = req.query.oauth_token
        secret = authorizations_requests[token].secret
        id = authorizations_requests[token].id
        console.log "#{secret} #{token} #{id}"
        linkedin.getauth token, secret, req.query.oauth_verifier, (err, token, secret, data) ->
          authorizations[id] =
            token: token
            secret: secret
            expires: data.oauth_expires_in
          console.log data
          console.log authorizations
          res.json data
        # linkedin.get 
        # getOAuthAccessToken(oauth_token, oauth_token_secret
        # res.send req.query.oauth_verifier #=27590
    else
      if req.params.id?
        linkedin.auth (err, token, secret, url) ->
          authorizations_requests[token] =
            id: req.params.id
            secret: secret
          res.redirect url
      else
        res.json Error: 'No ID specified'
  members: (req, res) ->
    console.log authorizations
    if req.params.id?
      id = req.params.id
      # auth_linkedin = new Linkedin(
      #   LINKEDIN_API_KEY
      #   LINKEDIN_API_SECRET
      #   authorizations[id].token
      #   authorizations[id].secret
      # )
      # auth_linkedin.get 'http://api.linkedin.com/v1/people/~', (err, data) ->
      #   console.log data
      linkedin.get "http://api.linkedin.com/v1/people/id=#{req.params.id}:(email-address,summary,public-profile-url,primary-twitter-account)?format=json", (err, data) ->
        return res.json err if err
        console.log JSON.parse data
        res.json data: JSON.parse data
    else
      linkedin.get "http://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,picture-url,headline),num-results)?company-name=#{LINKEDIN_COMPANY}&count=25&format=json", (err, data) =>
        return res.json err if err
        res.json data: JSON.parse(data).people.values
  papers: (req, res) ->
    req.pipe(request("http://api.mendeley.com/oapi/documents/groups/#{MENDELEY_GROUP}/docs/?details=true&items=3&consumer_key=#{MENDELEY_CONSUMER_KEY}")).pipe(res)
