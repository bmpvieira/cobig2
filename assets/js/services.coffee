angular
  .module('appServices', ['ngResource', 'appGlobals'])
  .factory('Content', ['$resource', 'Globals'
    ($resource, Globals) ->
      # Get content from Github REST api
      $resource "#{Globals.urls.contents}/:file.:ext", {}
  ])
  .factory('API', ['$resource',
    ($resource, Globals) ->
      # Get data from server REST api
      $resource 'api/:path/:subpath', {}
  ])
  .factory('Menu', ['$rootScope', 'Content'
    ($scope, Content) ->
      return ->
        # Get navigation menu items from json file on Github
        Content.get {file: 'menu', ext: 'json'}, (menu) ->
          $scope.menu = JSON.parse(Base64.decode(menu.content)).menu
          $scope.$broadcast 'menuLoaded'
  ])
  .factory('Views', ['$rootScope'
    ($scope) ->
      (menu) ->
        # Save items with special views for later use in routes
        views = {}
        for item in menu
          if item.dropdown?
            for subitem in item.dropdown
              views[subitem.href.split('/')[1]] = subitem.view if subitem.view?
          views[item.href.split('/')[1]] = item.view if item.view?
        $scope.views = views
        $scope.views_keys = (key for key of views)
        $scope.$broadcast 'viewsLoaded'
  ])
