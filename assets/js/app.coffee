# Declare app level module which depends on filters, and services
angular
  .module('app', ['ngSanitize', 'appGlobals', 'appServices', 'appDirectives'])
  .config(['$routeProvider', '$locationProvider'
    ($routeProvider, $locationProvider) ->

      $routeProvider
        .when('/:path',
          controller: 'ContentCtrl'
          template: '<div ng-include="templateUrl">Loading...</div>'
        )

      #$routeProvider.otherwise redirectTo: '/home'
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

      # When rendering finished, try to center content and display it
      $scope.$on '$includeContentLoaded', ->
        $(window).resize() # to trigger .content re-centering
        # Content vertical and horizontal re-centering
        oldCenter = $.contentCenter()
        recenter = (interval) ->
          setTimeout =>
            newCenter = $.contentCenter()
            diff = oldCenter - newCenter
            if -0.1 > diff > 0.1
              oldCenter = newCenter
              recenter()
            else
              $('.content').addClass 'display'
          , interval
        recenter(1000)
        recenter(3000)
        # hide navbar for mobile
        $('.nav-collapse').collapse()
        $('.nav-collapse').collapse('hide')
  ])
