angular
  .module('appGlobals', ['ngResource'])
  .factory 'Globals', ->
    urls:
      contents: 'https://api.github.com/repos/bmpvieira/cobig2_website/contents'
