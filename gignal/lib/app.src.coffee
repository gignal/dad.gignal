document.gignal =
  views: {}


class Post extends Backbone.Model

  idAttribute: 'objectId'
  re_links: /((http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?)/g
  
  defaults:
    text: ''

  getData: =>
    text = @get 'text'
    text = text.replace @re_links, '<a href="$1" target="_blank">link</a>'
    text = null if text.indexOf(' ') is -1
    username = @get 'username'
    username = null if username.indexOf(' ') isnt -1
    direct = @get 'link'

    shareFB = "javascript: getUrl(\"http://www.facebook.com/sharer.php?u=" + encodeURIComponent(direct) + "\")"
    shareTT = "javascript: getUrl(\"http://twitter.com/share?text=" + encodeURIComponent(direct) + "&url="+ encodeURIComponent(text) + "\")"
    
    keyFB = '128990610442'
    # postFB = "javascript: getUrl(\"https://www.facebook.com/dialog/feed?app_id="+keyFB+"&display=popup&link=" + encodeURIComponent(direct) + "&picture=" + encodeURIComponent('http://www.gignal.com/images/g@2x.png') + "&name=" + encodeURIComponent('Gignal') + "&description=" + encodeURIComponent('Gignal amplifies the voice of your audience') + "&redirect_uri=" + encodeURIComponent('http://www.gignal.com') + "\")"
    postFB = "javascript: getUrl(\"https://www.facebook.com/dialog/feed?app_id=" + keyFB + "&display=popup&link=" + encodeURIComponent(direct) + "&picture=" + encodeURIComponent(@get('large_photo')) + "&redirect_uri=" + encodeURIComponent('http://www.gignal.com/') + "\")"
    # convert time to local tz
    # created = (new Date(@get('created'))).getTime() / 1000
    # created = @get 'created_on'
    # created_local = if offset >= 0 then created - offset else created + offset
    # @set 'created_local', new Date(created_local * 1000)
    @set 'created', new Date(@get('created_on') * 1000)
    # prepare data
    data =
      message: text
      username: username
      name: @get 'name'
      since: humaneDate @get 'created'
      link: direct
      service: @get 'service'
      user_image: @get 'user_image'
      photo: if @get('large_photo') isnt '' then @get('large_photo') else false
      direct: direct
      shareFB: shareFB
      shareTT: shareTT
      postFB: postFB
      Twitter: @get 'original_id' if @get('service') is 'twitter'
      Facebook: @get 'original_id' if @get('service') is 'facebook'
      Instagram: @get 'original_id' if @get('service') is 'instagram'
    return data


class Stream extends Backbone.Collection

  model: Post

  url: ->
    eventid = $('#gignal-widget').data('eventid')
    if getParameterByName 'eventid'
      eventid = getParameterByName 'eventid'
    if not eventid
      console.error 'Please set URI parameter eventid'
      return false
    # return '//api.gignal.com/fetch/' + eventid + '?callback=?'
    return '//gignal.parseapp.com/feed/' + eventid + '?callback=?'
    # return '//api.gignal.com/feed/' + eventid + '?callback=?'

  calling: false
  parameters:
    limit: 25
    offset: 0
    sinceTime: 0

  initialize: ->
    @on 'add', @inset
    @update()
    @setIntervalUpdate()
    @updateTimes()

  inset: (model) =>
    view = new document.gignal.views.UniBox
      model: model
    document.gignal.widget.$el.isotope 'insert', view.render().$el
    document.gignal.widget.refresh()


  parse: (response) ->
    return response.stream

  comparator: (item) ->
    return - item.get 'created_on'

  isScrolledIntoView: (elem) ->
    docViewTop = $(window).scrollTop()
    docViewBottom = docViewTop + $(window).height()
    elemTop = $(elem).offset().top
    elemBottom = elemTop + $(elem).height()
    return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop))

  update: (@append) =>
    return if @calling
    return if not @append and not @isScrolledIntoView '#gignal-stream header'
    @calling = true
    if not @append
      sinceTime = _.max(@pluck('saved_on'))
      if not _.isFinite sinceTime
        sinceTime = null
      offset = 0
    else
      sinceTime = _.min(@pluck('saved_on'))
      offset = @parameters.offset += @parameters.limit
    @fetch
      remove: false
      cache: true
      timeout: 15000
      jsonpCallback: 'callme'
      data:
        limit: @parameters.limit
        offset: offset if offset
        sinceTime: sinceTime if _.isFinite sinceTime
      success: =>
        @calling = false
      error: (c, response) =>
        @calling = false


  setIntervalUpdate: ->
    sleep = 10000
    # floor by 5sec then add 5sec
    now = +new Date()
    start = (sleep * (Math.floor(now / sleep))) + sleep - now
    setTimeout ->
      sleep = 10000
      setInterval document.gignal.stream.update, sleep
    , start

  updateTimes: ->
    sleep = 30000
    setInterval ->
      document.gignal.stream.each (model) ->
        model.set 'since', humaneDate(model.get('created'))
    , sleep

class document.gignal.views.Event extends Backbone.View

  el: '#gignal-widget'
  columnWidth: 230
  isotoptions:
    itemSelector: '.gignal-outerbox'
    layoutMode: 'masonry'
    sortAscending: false
    sortBy: 'created_on'
    getSortData:
      created_on: (el) ->
        parseInt(el.data('created_on'))

  initialize: ->
    # set Isotope masonry columnWidth
    radix = 10
    magic = 15
    mainWidth = @$el.innerWidth()
    columnsAsInt = parseInt(mainWidth / @columnWidth, radix)
    @columnWidth = @columnWidth + (parseInt((mainWidth - (columnsAsInt * @columnWidth)) / columnsAsInt, radix) - magic)
    # init Isotope
    @$el.isotope @isotoptions

  refresh: =>
    @$el.imagesLoaded =>
      @$el.isotope @isotoptions


class document.gignal.views.UniBox extends Backbone.View
  tagName: 'div'
  className: 'gignal-outerbox'
  events:
    'click .gignal-image': 'showBigImg'
  initialize: ->
    @listenTo @model, 'change', @render
  render: =>
    # @$el.find('.gignal-image').magnificPopup()
    @$el.data 'created_on', @model.get('created_on')
    # set width
    @$el.css 'width', document.gignal.widget.columnWidth
    # owner?
    if @model.get 'admin_entry'
      @$el.addClass 'gignal-owner'
    # render
    @$el.html Templates.uni.render @model.getData(),
      footer: Templates.footer
    return @
  showBigImg: ->
    $.magnificPopup.open
      type: 'image'
      closeOnContentClick: true
      items:
        src: @model.get 'large_photo'
    

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
