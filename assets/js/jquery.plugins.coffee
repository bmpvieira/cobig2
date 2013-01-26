# Function to center content
$.contentCenter = ->
  left = ($(window).width() - $('.content').outerWidth()) / 2
  top = ($(window).height() - $('.content').outerHeight()) / 2
  top = 100 if top < 100
  if $(window).width() < 979
    position = 'relative'
    top = 0
    left = 0
  else
    position = 'absolute'
  $('.content').css
    position: position
    left: left
    top: top
  left + top
# Add function to resize events
$(window).resize ->
  $.contentCenter()
