# Controllers
angular
  .module('app')
  .controller('AppCtrl', ['$rootScope', 'Content'
    ($scope, Content) ->
      # Helper functions to filter menu items with dropdown
      $scope.hasDropdown = (item) ->
        'undefined' isnt typeof item.dropdown ? true : false
      $scope.hasntDropdown = (item) ->
        'undefined' is typeof item.dropdown ? true : false
  ])
  .controller('ContentCtrl', ['$rootScope', '$routeParams', 'Content', 'API'
    ($scope, $routeParams, Content, API) ->
      if $scope.views?
        if $routeParams.path in $scope.views_keys
          if 'thumbnails' is $scope.views[$routeParams.path]
            $scope.templateUrl = 'partials/thumbnails'
            API.get {path: 'members'}, (members) ->
              $scope.thumbnails = members.data
              $scope.path = 'members'
              $scope.$broadcast 'controllerDone'
              $scope.details = {}
              $scope.getDetails = (id) ->
                $scope.details[id] = {} if not $scope.details[id]?
                if not $scope.details[id].isvisible? or $scope.details[id].isvisible is false
                  $scope.details[id].isvisible = true
                else
                  $scope.details[id].isvisible = false
                API.get {path: 'members', subpath: id}, (details) ->
                  $scope.details[id].data = details.data
          else if 'papers' is $scope.views[$routeParams.path]
            $scope.templateUrl = 'partials/papers'
            API.get {path: 'papers'}, (papers) ->
              $scope.papers = papers.documents
              $scope.$broadcast 'controllerDone'
        else
          $scope.templateUrl = 'partials/markdown'
          # Get content from markdown files
          $routeParams.path = 'home' if $routeParams.path is ''
          Content.get {file: $routeParams.path, ext: 'md'}, (content) ->
            $scope.content = marked Base64.decode content.content
            $scope.$broadcast 'controllerDone'
  ])
