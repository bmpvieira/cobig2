# Declare app level module which depends on filters, and services
angular
  .module('app', ['ngSanitize', 'appGlobals', 'appServices', 'appDirectives'])
  .config(['$routeProvider', '$locationProvider',
    ($routeProvider, $locationProvider) ->

      $routeProvider.when '/:path'
        controller: 'ContentCtrl'
        template: '<div ng-include="templateUrl">Loading...</div>'

      #$routeProvider.otherwise redirectTo: '/404'
      $locationProvider.html5Mode true
  ])
  .run(['$rootScope', '$route', 'Menu', 'Views'
    ($scope, $route, Menu, Views) ->
      # Get menu from remote json file with REST api
      Menu()

      # Extract views templates from menu for routes
      $scope.$on 'menuLoaded', ->
        Views($scope.menu)

      # On first load, route doesn't have Views loaded yet, so reload is needed
      $scope.$on 'viewsLoaded', ->
        $route.reload()

      # When rendering is mostly finished
      $scope.$on '$includeContentLoaded', ->
        # initialize navbar hiding when menu clicked for mobile view
        $('.nav-collapse').collapse()
        $('.nav-collapse').collapse('hide')
  ])
