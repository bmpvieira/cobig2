angular
  .module('appDirectives', [])
  .directive('appCenter', ['$timeout', '$window', 'Globals'
    appCenterFactory = ($timeout, $window, Globals) ->
      # This directive tries to center an element relative to the browser's window
      # when the element is mostly centered, it will addClass display to reveal it
      # it will also center when twitter's bootstrap is in mobile view, but only horizontaly
      appCenterDefinition =
        scope: true
        link: (scope, element, attrs) ->

          window = angular.element($window)
          navbarHeight = Globals.bootstrap.navbarHeight
          collapse = Globals.bootstrap.collapse

          elementCenter = (element) ->
            if window.width() < collapse # twitter bootstrap collapsed for mobile
              left = 0
              top = 0
              if (window.width() - element.outerWidth()) > 100 # elt too small to fill
                # center element with margin
                marginLeft = Math.floor((window.width() - element.outerWidth()) / 2)
              else
                marginLeft = 'auto'
              element.css
                position: 'relative'
                left: left
                top: top
                'margin-left': marginLeft
              left = marginLeft # to return a value and trigger $watch when needed
            else # not mobile view
              left = Math.floor((window.width() - element.outerWidth()) / 2)
              top = Math.floor((window.height() - element.outerHeight()) / 2)
              top = navbarHeight if top < navbarHeight # compensate for top navbar
              element.css
                position: 'absolute'
                left: left
                top: top
                'margin-left': 0
            [left, top]

          scope.lastCenter = elementCenter(element)

          currentCenter = ->
            newCenter = elementCenter(element)
            if not angular.equals(scope.lastCenter, newCenter)
              newCenter
            else
              element.addClass 'display' # reveals content using CSS
              scope.lastCenter

          updateCenter = ->
            # Timeout is to avoid iteration limits when content is still rendering
            # first timeout is short to avoid seeing content jumping
            $timeout ->
              scope.lastCenter = currentCenter()
            , 300
            # sometimes timeout is too short and content stays uncentered
            $timeout ->
              scope.lastCenter = currentCenter()
            , 2000

          scope.$watch 'lastCenter', updateCenter
          window.bind 'resize', updateCenter
  ])
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
            element.removeClass if detailsShow then 'details-hidden' else 'details-shown'
            element.addClass if detailsShow then 'details-shown' else 'details-hidden'
  )
