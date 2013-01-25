# src: http://tutorialzine.com/2010/03/centering-div-vertically-and-horizontally/
$.contentCenter = ->
  left = ($(window).width() - $('.content').outerWidth()) / 2
  top = ($(window).height() - $('.content').outerHeight()) / 2
  $('.content').css
    position: 'absolute'
    left: left
    top: top
  left + top
$(window).resize ->
  $.contentCenter()

