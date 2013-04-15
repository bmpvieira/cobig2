angular
  .module('appDirectives', [])
  .directive('appThumbnail', ['$location', '$anchorScroll'
    appThumbnailFactory = ($location, $anchorScroll) ->
      appThumbnailDefinition =
        templateUrl: 'partials/thumbnails'
        restrict: 'E'
        replace: true
        transclude: true
        scope:
          id: '@'
          title: '@'
          body: '@'
          picture: '@'
          getDetails: '&'
        link: (scope, element, attrs) ->

          button = angular.element(element.children()[0])

          button.bind 'click', thumbnailClick = ->
            getDetailsIfNeeded()
            toggleDetails()

          getDetailsIfNeeded = ->
            if not scope.details?
              scope.getDetails
                id: scope.id 
                callback: (details) ->
                  scope.details = details

          toggleDetails = ->
            detailsShow = scope.detailsShow = not scope.detailsShow
            scope.$apply()

          scope.$watch 'title', (val) ->
            if val and $location.$$hash?
              names = val.split(' ')
              username = (names[0].slice(0,1) + names[1]).toLowerCase()
              if username is $location.$$hash
                getDetailsIfNeeded()
                toggleDetails()
                $location.$$hash = scope.id
                $anchorScroll()
  ])
