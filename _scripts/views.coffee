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
    if @model.get('type') is 'photo' or @model.get('type') is 'video'
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
    key = '3ce4f3260f2d41788751d9d3f43dcab2'
    url = '//api.embed.ly/1/oembed?key=' + key + '&url=' + link
    $.getJSON url, (data) ->
      callback null, data.html
  showVideo: ->
    @embedly @model.get('link'), (err, html) ->
      $.magnificPopup.open
        items:
          type: 'inline'
          src: html
  showBigImg: ->
    if @model.get('type') is 'video'
      return @showVideo()
    $.magnificPopup.open
      type: 'image'
      closeOnContentClick: true
      items:
        src: @model.get 'large_photo'
    
