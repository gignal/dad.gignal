getParameterByName = (name) ->
  name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
  regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
  results = regex.exec(location.search)
  (if not results? then '' else decodeURIComponent(results[1].replace(/\+/g, ' ')))


getUrl = (url) ->
  window.open url, "feedDialog", "toolbar=0,status=0,width=626,height=370"

myBirdOver = (the) ->
  the.style.backgroundImage="url('//gignal.github.io/widget/gignal/images/twitter_blue.png')"

myBirdOut = (the) ->
  the.style.backgroundImage="url('//gignal.github.io/widget/gignal/images/twitter_gray.png')"

myFaceOver = (the) ->
  the.style.backgroundImage="url('//gignal.github.io/widget/gignal/images/facebook_blue.png')"

myFaceOut = (the) ->
  the.style.backgroundImage="url('//gignal.github.io/widget/gignal/images/facebook_gray.png')"

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

  document.gignal.eventid = $('#gignal-widget').data('eventid')
  if getParameterByName 'eventid'
    document.gignal.eventid = getParameterByName 'eventid'
  if not document.gignal.eventid
    console.error 'Please set URI parameter eventid'
    return

  document.gignal.columns = parseInt getParameterByName 'cols'
  document.gignal.footer = if getParameterByName('footer') is 'false' then false else true
  document.gignal.fontsize = parseFloat getParameterByName 'fontsize'
  document.gignal.widget = new document.gignal.views.Event()
  document.gignal.stream = new Stream()

  io.connect 'ws://gsocket.herokuapp.com:80/' + document.gignal.eventid,
    transports: ['websocket']
  .on 'refresh', document.gignal.stream.update

  if document.gignal.fontsize
    $('body').css 'font-size', document.gignal.fontsize + 'em'

  $(window).on 'scrollBottom', offsetY: -500, ->
    document.gignal.stream.update true
