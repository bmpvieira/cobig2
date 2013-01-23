angular
  .module('appServices', ['ngResource', 'appGlobals'])
  .factory 'Content', [
    '$resource'
    'Globals'
    ($resource, Globals) ->
      $resource "#{Globals.urls.contents}/:file.:ext", {}
  ]
