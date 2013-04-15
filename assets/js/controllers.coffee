# Controllers
angular
  .module('app')
  .controller('AppCtrl', ['$rootScope', 'Content'
    ($scope, Content) ->
      # Filters for menu items
      $scope.hasDropdown = (item) ->
        'undefined' isnt typeof item.dropdown ? true : false
      $scope.hasntDropdown = (item) ->
        'undefined' is typeof item.dropdown ? true : false
  ])
  .controller('ContentCtrl', ['$scope', '$routeParams', '$location', 'Content', 'API'
    ($scope, $routeParams, $location, Content, API) ->
      if $scope.views?
        if $routeParams.path in $scope.views_keys # view has specific template
          view = $scope.views[$routeParams.path]
          # Thumbnails
          if 'thumbnails' is view
            $scope.templateUrl = 'templates/members'
            $scope.getDetails = (id, callback) ->
              if id?
                API.get {service: 'linkedin', object: 'members', param: id}, (results) =>
                  details = {}
                  details.fields = [
                    title: 'Summary', body: results.data.summary
                  ]
                  details.links = []
                  if results.data.emailAddress?
                    email = "mailto:#{results.data.emailAddress}"
                    details.links.push icon: 'envelope-alt', url: email
                  if results.data.publicProfileUrl?
                    linkedin = "#{results.data.publicProfileUrl}"
                    details.links.push icon: 'linkedin', url: linkedin
                  if results.data.primaryTwitterAccount?.providerAccountName?
                    twitter = "//twitter.com/#{results.data.primaryTwitterAccount.providerAccountName}"
                    details.links.push icon: 'twitter', url: twitter
                  callback details

            API.get {service: 'linkedin', object: 'members'}, (members) ->
              $scope.thumbnails = members.data
              $scope.$emit 'controllerDone'

          # Papers
          else if 'papers' is view
            $scope.templateUrl = 'templates/papers'
            API.get {service: 'mendeley', object: 'papers'}, (papers) ->
              $scope.papers = papers.documents
              $scope.$emit 'controllerDone'

          # Photos
          else if 'photos' is view
            $scope.templateUrl = 'templates/photos'
            album = $scope.args[$routeParams.path]
            API.get {service: 'facebook', object: 'photos', param: album}, (photos) ->
              $scope.photos = photos.data
              $scope.$emit 'controllerDone'

        # Authentication
        else if 'authenticate' is $routeParams.path
          $scope.templateUrl = 'templates/authenticate'
          $scope.getDetails = (id, callback) ->
            API.get {service: 'facebook', object: 'authenticate\\/request', param: id}, (data) ->
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

        # Content
        else # defaults view to markdown
          $scope.templateUrl = 'templates/markdown'
          # Get content from markdown files
          $routeParams.path = 'home' if $routeParams.path is ''
          Content.get {file: $routeParams.path, ext: 'md'}, (content) ->
            # $scope.content = marked Base64.decode content.content # when from GitHub
            $scope.content = marked content.data
            $scope.$emit 'controllerDone'
  ])
