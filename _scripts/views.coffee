class document.gignal.views.Event extends Backbone.View

  el: '#gignal-widget'
  columnWidth: 230
  isotoptions:
    itemSelector: '.gignal-outerbox'
    layoutMode: 'masonry'
    sortAscending: false
    sortBy: 'saved_on'
    getSortData:
      saved_on: (el) ->
        parseInt(el.data('saved_on'))

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
  initialize: ->
    @listenTo @model, 'change', @render
  render: =>
    @$el.data 'saved_on', @model.get('saved_on')
    # set width
    @$el.css 'width', document.gignal.widget.columnWidth
    # owner?
    if @model.get 'admin_entry'
      @$el.addClass 'gignal-owner'
    # render
    @$el.html Templates.uni.render @model.getData(),
      footer: Templates.footer
    return @
