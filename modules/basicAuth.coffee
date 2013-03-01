yaml = require 'js-yaml'
config = require '../config.yaml'

module.exports = exports = privateAuth = (req, res, next) ->
  if req.cookies.unlock
    next()
  else
    if req.query.unlock is 'true'
      res.cookie 'unlock', '1', maxAge: 3600000
      next()
    else
      res.redirect "//#{config.hosts.production}"
