# Dropbox API authenticated access with oauth
OAuth = require('oauth').OAuth
HOST = process.env.HOST
module.exports = exports =
  class Linkedin
    constructor: (@_apiKey, @_apiSecret, @_userToken, @_userKey) ->
      @consumer = new OAuth(
        "https://api.dropbox.com/1/oauth/request_token"
        'https://api.dropbox.com/1/oauth/access_token'
        @_apiKey
        @_apiSecret
        '1.0'
        "#{HOST}/api/dropbox/authenticate/get"
        'HMAC-SHA1')
    get: (url, next) ->
      @consumer.getProtectedResource url, 'GET', @_userToken, @_userKey, (err, data) ->
        return next err if err
        next null, data
    auth: (next) ->
      @consumer.getOAuthRequestToken (err, token, secret) ->
        return next err if err
        next null, token, secret, "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{token}&oauth_callback=#{HOST}/api/dropbox/authenticate/get"
    getauth: (token, secret, next) ->
      @consumer.getOAuthAccessToken token, secret, next
