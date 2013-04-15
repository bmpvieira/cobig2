angular
  .module('appServices', ['ngResource', 'appGlobals'])
  .factory('ContentGithub', ['$resource', 'Globals'
    ($resource, Globals) ->
      # Get content from Github REST api
      $resource "#{Globals.urls.contents}/:file.:ext", {}
  ])
  .factory('Content', ['$http'
    ($http) ->
      get: (options, callback) ->
        # Get content from Dropbox using server REST api
        $http.get("/api/dropbox/files/content/#{options.file}.#{options.ext}").then callback
  ])
  .factory('API', ['$resource',
    ($resource, Globals) ->
      # Get data from server REST api
      $resource 'api/:service/:object/:param', {}
  ])
  .factory('MenuFromGithub', ['$rootScope', 'Content'
    ($scope, Content) ->
      ->
        # Get navigation menu items from json file on Github
        Content.get {file: 'menu', ext: 'json'}, (menu) ->
          $scope.menu = JSON.parse(Base64.decode(menu.content)).menu
          $scope.$broadcast 'menuLoaded'
  ])
  .factory('Menu', ['$rootScope', 'Content'
    ($scope, Content) ->
      ->
        # Get navigation menu items from json file on Dropbox
        Content.get {file: 'menu', ext: 'json'}, (res) ->
          $scope.menu = res.data.menu
          $scope.$broadcast 'menuLoaded'
  ])
  .factory('Views', ['$rootScope'
    ($scope) ->
      (menu) ->
        # Save items with special views for later use in routes
        views = {}
        args = {}
        for item in menu
          if item.dropdown?
            for subitem in item.dropdown
              path = subitem.href.split('/')[1]
              views[subitem.href.split('/')[1]] = subitem.view if subitem.view?
              args[subitem.href.split('/')[1]] = subitem.args if subitem.args?
          views[item.href.split('/')[1]] = item.view if item.view?
          args[item.href.split('/')[1]] = item.args if item.args?
        $scope.views = views
        $scope.views_keys = (key for key of views)
        $scope.args = args
        $scope.$broadcast 'viewsLoaded'
  ])
