getParameterByName = (name) ->
  name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
  regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
  results = regex.exec(location.search)
  (if not results? then '' else decodeURIComponent(results[1].replace(/\+/g, ' ')))

getUrl = (url) ->
  window.open url, "feedDialog", "toolbar=0,status=0,width=626,height=370"

jQuery ($) ->

  $.ajaxSetup
    cache: true

  Backbone.$ = $

  document.gignal.widget = new document.gignal.views.Event()
  document.gignal.stream = new Stream()

  $(window).on 'scrollBottom', offsetY: -100, ->
    document.gignal.stream.update true


jQuery(document).ready ->

  #$("#gignal-stream").find('.gignal-tool')#.click ->
  console.log $("#gignal-stream").find('.gignal-outerbox')

  # .hover ->
  #   $(this).children('div').css "display", "block"
  #   console.log 'ok'
  # , ->
  #   $(this).children('div').css "display", "none"

  # $.ajaxSetup cache: true
  # $.getScript "//connect.facebook.net/en_UK/all.js", ->
  #   FB.init appId: "YOUR_APP_ID"
  #   $("#loginbutton,#feedbutton").removeAttr "disabled"
  #   FB.getLoginStatus updateStatusCallback