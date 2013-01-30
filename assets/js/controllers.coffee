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
  .controller('ContentCtrl', ['$scope', '$routeParams', 'Content', 'API'
    ($scope, $routeParams, Content, API) ->
      if $scope.views?
        if $routeParams.path in $scope.views_keys
          if 'thumbnails' is $scope.views[$routeParams.path]
            $scope.templateUrl = 'partials/members'
            $scope.getDetails = (id, callback) ->
              if id?
                API.get {path: 'members', subpath: id}, (results) =>
                  details = {}
                  details.fields = [
                    title: 'Summary', body: results.data.summary
                  ]
                  details.links = [
                    icon: 'envelope-alt', url: "mailto:#{results.data.emailAddress}"
                  ,
                    icon: 'linkedin', url: "#{results.data.publicProfileUrl}"
                  ,
                    icon: 'twitter', url: "//twitter.com/#{results.data.primaryTwitterAccount.providerAccountName}"
                  ]
                  callback details
            API.get {path: 'members'}, (members) ->
              $scope.thumbnails = members.data
              $scope.path = 'members'
              $scope.$emit 'controllerDone'
          else if 'papers' is $scope.views[$routeParams.path]
            $scope.templateUrl = 'partials/papers'
            API.get {path: 'papers'}, (papers) ->
              $scope.papers = papers.documents
              $scope.$emit 'controllerDone'
        else
          $scope.templateUrl = 'partials/markdown'
          # Get content from markdown files
          $routeParams.path = 'home' if $routeParams.path is ''
          Content.get {file: $routeParams.path, ext: 'md'}, (content) ->
            $scope.content = marked Base64.decode content.content
            $scope.$emit 'controllerDone'
  ])
