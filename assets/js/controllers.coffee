# Controllers
angular
  .module('app')
  .controller('AppCtrl', [
    '$scope'
    'Content'
    ($scope, Content) ->
      # Get navigation menu items from json
      Content.get {file: 'menu', ext: 'json'}, (menu) ->
        $scope.menu = JSON.parse(Base64.decode(menu.content)).menu
      # Helper functions to filter menu items with dropdown
      $scope.hasDropdown = (item) ->
        'undefined' isnt typeof item.dropdown ? true : false
      $scope.hasntDropdown = (item) ->
        'undefined' is typeof item.dropdown ? true : false
  ])
  .controller('ContentCtrl', [
    '$scope'
    '$routeParams'
    'Content'
    'Globals'
    ($scope, $routeParams, Content, Globals) ->
      # Get content from markdown files
      $routeParams.path = 'home' if $routeParams.path is ''
      Content.get {file: $routeParams.path, ext: 'md'}, (content) ->
        $scope.content = marked Base64.decode content.content
  ])
