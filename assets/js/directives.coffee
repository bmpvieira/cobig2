angular
  .module('appDirectives', [])
  .directive('appThumbnail',
    appThumbnailFactory = ->
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
            if not scope.details?
              scope.getDetails
                id: scope.id 
                callback: (details) ->
                  scope.details = details
            toggleDetails()
          toggleDetails = ->
            detailsShow = scope.detailsShow = not scope.detailsShow
            scope.$apply()
  )
