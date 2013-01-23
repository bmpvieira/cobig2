# src: http://tutorialzine.com/2010/03/centering-div-vertically-and-horizontally/
$(window).resize ->
  $(".content").css
    position: "absolute"
    left: ($(window).width() - $(".content").outerWidth()) / 2
    top: ($(window).height() - $(".content").outerHeight()) / 2
