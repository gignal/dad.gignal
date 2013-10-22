document.gignal =
  views: {}


class Post extends Backbone.Model

  idAttribute: 'stream_id'
  re_links: /((http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?)/g

  getData: =>
    text = @get 'text'
    text = text.replace @re_links, '<a href="$1" target="_blank">link</a>'
    text = null if text.indexOf(' ') is -1
    username = @get 'username'
    username = null if username.indexOf(' ') isnt -1
    switch @get 'service'
      when 'Twitter'
        direct = 'http://twitter.com/' + username + '/status/' + @get 'original_id'
      when 'Facebook'
        direct = 'http://facebook.com/' + @get 'original_id'
      else
        direct = '#'
    data =
      message: text
      username: username
      name: @get 'name'
      since: humaneDate @get 'creation'
      service: @get 'service'
      user_image: @get 'user_image'
      photo: @get 'large_photo'
      direct: direct
    return data


class Stream extends Backbone.Collection

  model: Post

  url: ->
    eventid = $('#gignal-widget').data('eventid')
    if getParameterByName 'eventid'
      eventid = getParameterByName 'eventid'
    return '//api.gignal.com/fetch/' + eventid + '?callback=?'

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
    switch model.get 'type'
      when 'text'
        view = new document.gignal.views.TextBox
          model: model
      when 'photo'
        view = new document.gignal.views.PhotoBox
          model: model
    document.gignal.widget.$el.isotope 'insert', view.render().$el
    document.gignal.widget.refresh()


  parse: (response) ->
    return response.stream

  comparator: (item) ->
    return - item.get 'saved_on'

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
        model.set 'since', humaneDate(model.get('creation'))
    , sleep
