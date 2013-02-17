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
        if $routeParams.path in $scope.views_keys # view has specific template
          if 'thumbnails' is $scope.views[$routeParams.path]
            $scope.templateUrl = 'templates/members'
            $scope.getDetails = (id, callback) ->
              if id?
                API.get {service: 'linkedin', object: 'members', param: id}, (results) =>
                  console.log results
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
            API.get {service: 'linkedin', object: 'members'}, (members) ->
              $scope.thumbnails = members.data
              $scope.$emit 'controllerDone'
          else if 'papers' is $scope.views[$routeParams.path]
            $scope.templateUrl = 'templates/papers'
            API.get {service: 'mendeley', object: 'papers'}, (papers) ->
              $scope.papers = papers.documents
              $scope.$emit 'controllerDone'
        else if 'photos' is $routeParams.path
          $scope.templateUrl = 'templates/photos'
          API.get {service: 'facebook', object: 'photos', param: '222282514468462'}, (photos) ->
            $scope.photos = photos.data
            $scope.$emit 'controllerDone'
        else if 'authenticate' is $routeParams.path
          $scope.templateUrl = 'templates/authenticate'
          $scope.getDetails = (id, callback) ->
            console.log id
            API.get {service: 'facebook', object: 'authenticate\\/request', param: id}, (data) ->
              console.log data
              details = {}
              details.links = [
                icon: 'linkedin', url: "api/linkedin/authenticate/request/#{id}"
              ,
                icon: 'facebook', url: "api/facebook/authenticate/request/#{id}"
              ]
              callback details
          API.get {service: 'linkedin', object: 'members'}, (members) ->
            $scope.users = members.data
            $scope.$emit 'controllerDone'
        else # defaults view to markdown
          $scope.templateUrl = 'templates/markdown'
          # Get content from markdown files
          $routeParams.path = 'home' if $routeParams.path is ''
          Content.get {file: $routeParams.path, ext: 'md'}, (content) ->
            $scope.content = marked Base64.decode content.content
            $scope.$emit 'controllerDone'
  ])
