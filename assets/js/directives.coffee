angular
  .module('appDirectives', [])
  .directive('appBindHtmlUnsafeReady', ->
    (scope, element, attr) ->
      element.addClass('ng-binding').data '$binding', attr.appBindHtmlUnsafeReady
      scope.$watch attr.appBindHtmlUnsafeReady, appBindHtmlUnsafeReadyWatchAction = (value) ->
        element.html value or ''
        #$('.content').css 'display', 'inline'
        $(window).resize()
        $('.content').addClass('display')
  )