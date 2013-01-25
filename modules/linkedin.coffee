# LinkedIn API authenticated access with oauth
OAuth = require('oauth').OAuth
module.exports = exports =
  class Linkedin
    constructor: (@_apiKey, @_apiSecret, @_userToken, @_userKey) ->
      @consumer = new OAuth(
        'https://api.linkedin.com/uas/oauth/requestToken'
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