module.exports = exports = privateAuth = (req, res, next) ->
  if req.cookies.showmepreview
    next()
  else
    if req.param('showmepreview') is 'please'
      res.cookie 'showmepreview', '1', maxAge: 3600000
      next()
    else
      res.redirect 'http://cobig2.fc.ul.pt'
