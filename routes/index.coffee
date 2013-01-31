module.exports = exports = routes =
  index: (req, res) ->
    res.render 'layout'
  templates: (req, res) ->
    res.render "templates/#{req.params.name}"
  partials: (req, res) ->
    res.render "partials/#{req.params.name}"