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
    if @model.get('type') is 'photo'
      $('<img/>').attr('src', @model.get('large_photo'))
      .load =>
        $(this).remove()
        @$('.gignal-image').css 'background-image', 'url(' + @model.get('large_photo') + ')'
        @$('.gignal-image').removeClass 'gignal-image-loading'
      .error =>
        document.gignal.widget.$el.isotope 'remove', @$el
  render: =>
    @$el.data 'created', @model.get('created')
    # set width
    @$el.css 'width', document.gignal.widget.columnWidth
    # owner?
    if @model.get 'admin_entry'
      @$el.addClass 'gignal-owner'
    # render
    @$el.html Templates.uni.render @model.getData(),
      footer: Templates.footer
    return @
  embedly: (link, callback) ->
    key = '962eaf4c483a49ffbd435c8c61498ed9'
    url = 'https://api.embed.ly/1/oembed?key=' + key + '&url=' + link + '&autoplay=true&videosrc=true&frame=true&secure=true'
    $.getJSON url, (data) ->
      src = if data.html? then data.html else data.url
      callback null, src
  showVideo: ->
    @embedly @model.get('link'), (err, html) ->
      $.magnificPopup.open
        type: 'iframe'
        items:
          src: html
  showBigImg: ->
    if @model.get('type') is 'video'
      return @showVideo()
    $.magnificPopup.open
      type: 'image'
      closeOnContentClick: true
      items:
        src: @model.get 'large_photo'
    
