# LinkedIn API authenticated access with oauth
OAuth = require('oauth').OAuth
module.exports = exports =
  class Linkedin
    constructor: (@_apiKey, @_apiSecret, @_userToken, @_userKey) ->
      @consumer = new OAuth(
        'https://api.linkedin.com/uas/oauth/requestToken?scope=r_fullprofile+r_emailaddress+r_contactinfo'
        'https://api.linkedin.com/uas/oauth/accessToken'
        @_apiKey
        @_apiSecret
        '1.0'
        null
        'HMAC-SHA1')
    get: (url, next) ->
      @consumer.getProtectedResource url, 'GET', @_userToken, @_userKey, (err, data) ->
        return next err if err
        next null, data
    auth: (next) ->
      @consumer.getOAuthRequestToken (err, token, secret, results) ->
        return next err if err
        next null, token, secret, "#{results.xoauth_request_auth_url}?oauth_token=#{token}"
    getauth: (token, secret, verifier, next) ->
      @consumer.getOAuthAccessToken token, secret, verifier, next
