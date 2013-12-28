getParameterByName = (name) ->
  name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
  regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
  results = regex.exec(location.search)
  (if not results? then '' else decodeURIComponent(results[1].replace(/\+/g, ' ')))

getUrl = (url) ->
  window.open url, "feedDialog", "toolbar=0,status=0,width=626,height=370"

myBirdOver = (the) ->
  the.style.backgroundImage="url('gignal/images/twitter_blue.png')"

myBirdOut = (the) ->
  the.style.backgroundImage="url('gignal/images/twitter_gray.png')"

myFaceOver = (the) ->
  the.style.backgroundImage="url('gignal/images/facebook_blue.png')"

myFaceOut = (the) ->
  the.style.backgroundImage="url('gignal/images/facebook_gray.png')"

barOver = (the) ->
  the.children[0].style.display = "block"
  the.children[1].style.display = "block"

barOut = (the) ->
  the.children[0].style.display = "none"
  the.children[1].style.display = "none"

jQuery ($) ->

  $.ajaxSetup
    cache: true

  Backbone.$ = $

  document.gignal.widget = new document.gignal.views.Event()
  document.gignal.stream = new Stream()

  $(window).on 'scrollBottom', offsetY: -100, ->
    document.gignal.stream.update true