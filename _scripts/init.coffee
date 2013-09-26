jQuery ($) ->

  $.ajaxSetup
    cache: true

  Backbone.$ = $

  document.gignal.widget = new document.gignal.views.Event()

  document.gignal.stream = new Stream [],
    #url: 'http://api.gignal.com/event/api/uuid/' + $('#gignal-widget').data('eventid') + '?callback=?'
    #url: 'http://localhost:3000/fetch/' + $('#gignal-widget').data('eventid') + '?callback=?'
    url: 'http://gignal-api.elasticbeanstalk.com/fetch/' + $('#gignal-widget').data('eventid') + '?callback=?'


  $(window).on 'scrollBottom', offsetY: -100, ->
    document.gignal.stream.update true
