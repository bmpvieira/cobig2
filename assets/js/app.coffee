# Declare app level module which depends on filters, and services
angular
  .module("app", ['ngSanitize', 'appGlobals', 'appServices', 'appDirectives'])
  .config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->

    $routeProvider.when '/:path',
      templateUrl: 'partials/markdown'
      controller: 'ContentCtrl'

    $routeProvider.otherwise redirectTo: '/home'
    $locationProvider.html5Mode true
  ]
