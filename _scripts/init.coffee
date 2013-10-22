getParameterByName = (name) ->
  name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
  regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
  results = regex.exec(location.search)
  (if not results? then '' else decodeURIComponent(results[1].replace(/\+/g, ' ')))


jQuery ($) ->

  $.ajaxSetup
    cache: true

  Backbone.$ = $

  document.gignal.widget = new document.gignal.views.Event()
  document.gignal.stream = new Stream()

  $(window).on 'scrollBottom', offsetY: -100, ->
    document.gignal.stream.update true
