var Post, Stream, barOut, barOver, getParameterByName, getUrl, myBirdOut, myBirdOver, myFaceOut, myFaceOver,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

document.gignal = {
  views: {}
};

Post = (function(superClass) {
  extend(Post, superClass);

  function Post() {
    this.getData = bind(this.getData, this);
    return Post.__super__.constructor.apply(this, arguments);
  }

  Post.prototype.idAttribute = 'objectId';

  Post.prototype.re_links = /((http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?)/g;

  Post.prototype.defaults = {
    text: '',
    username: ''
  };

  Post.prototype.getData = function() {
    var data, direct, keyFB, postFB, shareFB, shareTT, text, username;
    text = this.get('text');
    text = text.replace(this.re_links, '<a href="$1" target="_blank">link</a>');
    if (text.indexOf(' ') === -1) {
      text = null;
    }
    username = this.get('username');
    if (username.indexOf(' ') !== -1) {
      username = null;
    }
    direct = this.get('link');
    shareFB = 'javascript:getUrl("http://www.facebook.com/sharer.php?u=' + encodeURIComponent(direct) + '");';
    shareTT = 'javascript:getUrl("http://twitter.com/share?text=' + encodeURIComponent(direct) + '&url=' + encodeURIComponent(text) + '");';
    keyFB = '128990610442';
    postFB = 'javascript:getUrl("https://www.facebook.com/dialog/feed?app_id=' + keyFB + '&display=popup&link=' + encodeURIComponent(direct) + '&picture=' + encodeURIComponent(this.get('large_photo')) + '&redirect_uri=' + encodeURIComponent('http://www.gignal.com/') + '");';
    this.set('created', new Date(this.get('created_on') * 1000));
    data = {
      message: text,
      username: username,
      name: this.get('name'),
      since: humaneDate(this.get('created')),
      link: direct,
      service: this.get('service'),
      user_image: this.get('user_image'),
      photo: this.get('large_photo') !== '' ? this.get('large_photo') : false,
      direct: direct,
      shareFB: shareFB,
      shareTT: shareTT,
      postFB: postFB,
      Twitter: this.get('service') === 'twitter' ? this.get('original_id') : void 0,
      Facebook: this.get('service') === 'facebook' ? this.get('original_id') : void 0,
      Instagram: this.get('service') === 'instagram' ? this.get('original_id') : void 0
    };
    return data;
  };

  return Post;

})(Backbone.Model);

Stream = (function(superClass) {
  extend(Stream, superClass);

  function Stream() {
    this.update = bind(this.update, this);
    this.inset = bind(this.inset, this);
    return Stream.__super__.constructor.apply(this, arguments);
  }

  Stream.prototype.model = Post;

  Stream.prototype.url = function() {
    var eventid;
    eventid = document.gignal.eventid;
    return '//d2yrqknqjcrf8n.cloudfront.net/feed/' + eventid + '?callback=?';
  };

  Stream.prototype.calling = false;

  Stream.prototype.parameters = {
    limit: 30,
    offset: 0,
    sinceTime: 0
  };

  Stream.prototype.initialize = function() {
    this.on('add', this.inset);
    this.update();
    return this.updateTimes();
  };

  Stream.prototype.inset = function(model) {
    var view;
    view = new document.gignal.views.UniBox({
      model: model
    });
    return document.gignal.widget.$el.isotope('insert', view.render().$el);
  };

  Stream.prototype.parse = function(response) {
    return response.stream;
  };

  Stream.prototype.comparator = function(item) {
    return -item.get('created_on');
  };

  Stream.prototype.isScrolledIntoView = function(elem) {
    var docViewBottom, docViewTop, elemBottom, elemTop;
    docViewTop = $(window).scrollTop();
    docViewBottom = docViewTop + $(window).height();
    elemTop = $(elem).offset().top;
    elemBottom = elemTop + $(elem).height();
    return (elemBottom <= docViewBottom) && (elemTop >= docViewTop);
  };

  Stream.prototype.update = function(append) {
    var offset, sinceTime;
    this.append = append;
    if (this.calling) {
      return;
    }
    if (!this.append && !this.isScrolledIntoView('#gignal-stream header')) {
      return;
    }
    this.calling = true;
    if (!this.append) {
      sinceTime = _.max(this.pluck('saved_on'));
      if (!_.isFinite(sinceTime)) {
        sinceTime = null;
      }
      offset = 0;
    } else {
      sinceTime = _.min(this.pluck('saved_on'));
      offset = this.parameters.offset += this.parameters.limit;
    }
    return this.fetch({
      remove: false,
      timeout: 15000,
      jsonpCallback: 'callme',
      data: {
        limit: this.parameters.limit,
        offset: offset ? offset : void 0,
        sinceTime: _.isFinite(sinceTime) ? sinceTime : void 0
      },
      success: (function(_this) {
        return function() {
          return _this.calling = false;
        };
      })(this),
      error: (function(_this) {
        return function() {
          return _this.calling = false;
        };
      })(this)
    });
  };

  Stream.prototype.setIntervalUpdate = function() {
    var now, sleep, start;
    sleep = 10000;
    now = +new Date();
    start = (sleep * (Math.floor(now / sleep))) + sleep - now;
    return setTimeout(function() {
      sleep = 10000;
      return setInterval(document.gignal.stream.update, sleep);
    }, start);
  };

  Stream.prototype.updateTimes = function() {
    var sleep;
    sleep = 30000;
    return setInterval(function() {
      return $('.gignal-outerbox').each(function() {
        return $(this).find('.since').html(humaneDate($(this).data('created')));
      });
    }, sleep);
  };

  return Stream;

})(Backbone.Collection);

document.gignal.views.Event = (function(superClass) {
  extend(Event, superClass);

  function Event() {
    this.refresh = bind(this.refresh, this);
    return Event.__super__.constructor.apply(this, arguments);
  }

  Event.prototype.el = '#gignal-widget';

  Event.prototype.columnWidth = 230;

  Event.prototype.isotoptions = {
    itemSelector: '.gignal-outerbox',
    layoutMode: 'masonry',
    sortAscending: false,
    sortBy: 'created_on',
    getSortData: {
      created_on: function(el) {
        return parseInt(el.data('created_on'));
      }
    }
  };

  Event.prototype.initialize = function() {
    var columnsAsInt, magic, mainWidth, radix;
    radix = 10;
    magic = 15;
    mainWidth = this.$el.innerWidth();
    if (document.gignal.columns) {
      columnsAsInt = document.gignal.columns;
    } else {
      columnsAsInt = parseInt(mainWidth / this.columnWidth, radix);
    }
    this.columnWidth = this.columnWidth + (parseInt((mainWidth - (columnsAsInt * this.columnWidth)) / columnsAsInt, radix) - magic);
    return this.$el.isotope(this.isotoptions);
  };

  Event.prototype.refresh = function() {
    return this.$el.imagesLoaded((function(_this) {
      return function() {
        return _this.$el.isotope(_this.isotoptions);
      };
    })(this));
  };

  return Event;

})(Backbone.View);

document.gignal.views.UniBox = (function(superClass) {
  extend(UniBox, superClass);

  function UniBox() {
    this.render = bind(this.render, this);
    return UniBox.__super__.constructor.apply(this, arguments);
  }

  UniBox.prototype.tagName = 'div';

  UniBox.prototype.className = 'gignal-outerbox';

  UniBox.prototype.events = {
    'click .gignal-image': 'showBigImg'
  };

  UniBox.prototype.initialize = function() {
    var filter, photoType;
    this.listenTo(this.model, 'change', this.render);
    photoType = 'large_photo';
    if (this.model.get(photoType)) {
      $('<img/>').attr('src', this.model.get(photoType)).load((function(_this) {
        return function() {
          $(_this).remove();
          _this.$('.gignal-image').css('background-image', 'url("' + _this.model.get(photoType) + '")');
          return _this.$('.gignal-image').removeClass('gignal-image-loading');
        };
      })(this)).error((function(_this) {
        return function() {
          return document.gignal.widget.$el.isotope('remove', _this.$el);
        };
      })(this));
      if ($.browser && $.browser.msie) {
        filter = 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src="' + this.model.get(photoType) + '",sizingMethod="scale");';
        this.$('.gignal-image').css('filter', filter);
        return this.$('.gignal-image').css('-ms-filter', '\'' + filter + '\'');
      }
    }
  };

  UniBox.prototype.render = function() {
    this.$el.data('created', this.model.get('created'));
    this.$el.data('created_on', this.model.get('created_on'));
    this.$el.css('width', document.gignal.widget.columnWidth);
    if (this.model.get('admin_entry')) {
      this.$el.addClass('gignal-owner');
    }
    this.$el.html(Templates.uni.render(this.model.getData(), {
      footer: Templates.footer
    }));
    if (!document.gignal.footer) {
      this.$('.gignal-toolbox').hide();
    }
    return this;
  };

  UniBox.prototype.embedly = function(link, callback) {
    var key, url;
    key = '3ce4f3260f2d41788751d9d3f43dcab2';
    url = '//api.embed.ly/1/oembed?key=' + key + '&url=' + link;
    return $.getJSON(url, function(data) {
      return callback(null, data.html);
    });
  };

  UniBox.prototype.showVideo = function() {
    return $.magnificPopup.open({
      items: {
        type: 'ajax',
        src: this.model.get('link')
      }
    });
  };

  UniBox.prototype.showBigImg = function() {
    if (this.model.get('type') === 'video') {
      return this.showVideo();
    }
    return $.magnificPopup.open({
      type: 'image',
      closeOnContentClick: true,
      items: {
        src: this.model.get('large_photo')
      }
    });
  };

  return UniBox;

})(Backbone.View);

getParameterByName = function(name) {
  var regex, results;
  name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
  regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
  results = regex.exec(location.search);
  if (results == null) {
    return '';
  } else {
    return decodeURIComponent(results[1].replace(/\+/g, ' '));
  }
};

getUrl = function(url) {
  return window.open(url, "feedDialog", "toolbar=0,status=0,width=626,height=370");
};

myBirdOver = function(the) {
  return the.style.backgroundImage = "url('//gignal.github.io/widget/gignal/images/twitter_blue.png')";
};

myBirdOut = function(the) {
  return the.style.backgroundImage = "url('//gignal.github.io/widget/gignal/images/twitter_gray.png')";
};

myFaceOver = function(the) {
  return the.style.backgroundImage = "url('//gignal.github.io/widget/gignal/images/facebook_blue.png')";
};

myFaceOut = function(the) {
  return the.style.backgroundImage = "url('//gignal.github.io/widget/gignal/images/facebook_gray.png')";
};

barOver = function(the) {
  the.children[0].style.display = "block";
  return the.children[1].style.display = "block";
};

barOut = function(the) {
  the.children[0].style.display = "none";
  return the.children[1].style.display = "none";
};

jQuery(function($) {
  $.ajaxSetup({
    cache: true
  });
  Backbone.$ = $;
  document.gignal.eventid = $('#gignal-widget').data('eventid');
  if (getParameterByName('eventid')) {
    document.gignal.eventid = getParameterByName('eventid');
  }
  if (!document.gignal.eventid) {
    console.error('Please set URI parameter eventid');
    return;
  }
  document.gignal.columns = parseInt(getParameterByName('cols'));
  document.gignal.footer = getParameterByName('footer') === 'false' ? false : true;
  document.gignal.fontsize = parseFloat(getParameterByName('fontsize'));
  document.gignal.widget = new document.gignal.views.Event();
  document.gignal.stream = new Stream();
  io.connect('ws://gsocket.herokuapp.com:80/' + document.gignal.eventid, {
    transports: ['websocket']
  }).on('refresh', document.gignal.stream.update);
  if (document.gignal.fontsize) {
    $('body').css('font-size', document.gignal.fontsize + 'em');
  }
  return $(window).on('scrollBottom', {
    offsetY: -500
  }, function() {
    return document.gignal.stream.update(true);
  });
});
