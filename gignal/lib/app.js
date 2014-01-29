var Post, Stream, barOut, barOver, getParameterByName, getUrl, myBirdOut, myBirdOver, myFaceOut, myFaceOver, _ref, _ref1, _ref2, _ref3,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

document.gignal = {
  views: {}
};

Post = (function(_super) {
  __extends(Post, _super);

  function Post() {
    this.getData = __bind(this.getData, this);
    _ref = Post.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Post.prototype.idAttribute = 'objectId';

  Post.prototype.re_links = /((http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?)/g;

  Post.prototype.defaults = {
    text: ''
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

Stream = (function(_super) {
  __extends(Stream, _super);

  function Stream() {
    this.update = __bind(this.update, this);
    this.inset = __bind(this.inset, this);
    _ref1 = Stream.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  Stream.prototype.model = Post;

  Stream.prototype.url = function() {
    var eventid;
    eventid = $('#gignal-widget').data('eventid');
    if (getParameterByName('eventid')) {
      eventid = getParameterByName('eventid');
    }
    if (!eventid) {
      console.error('Please set URI parameter eventid');
      return false;
    }
    return '//gignal.parseapp.com/feed/' + eventid + '?callback=?';
  };

  Stream.prototype.calling = false;

  Stream.prototype.parameters = {
    limit: 25,
    offset: 0,
    sinceTime: 0
  };

  Stream.prototype.initialize = function() {
    this.on('add', this.inset);
    this.update();
    this.setIntervalUpdate();
    return this.updateTimes();
  };

  Stream.prototype.inset = function(model) {
    var view;
    view = new document.gignal.views.UniBox({
      model: model
    });
    document.gignal.widget.$el.isotope('insert', view.render().$el);
    return document.gignal.widget.refresh();
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
    var offset, sinceTime,
      _this = this;
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
      cache: true,
      timeout: 15000,
      jsonpCallback: 'callme',
      data: {
        limit: this.parameters.limit,
        offset: offset ? offset : void 0,
        sinceTime: _.isFinite(sinceTime) ? sinceTime : void 0
      },
      success: function() {
        return _this.calling = false;
      },
      error: function(c, response) {
        return _this.calling = false;
      }
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
      return document.gignal.stream.each(function(model) {
        return model.set('since', humaneDate(model.get('created')));
      });
    }, sleep);
  };

  return Stream;

})(Backbone.Collection);

document.gignal.views.Event = (function(_super) {
  __extends(Event, _super);

  function Event() {
    this.refresh = __bind(this.refresh, this);
    _ref2 = Event.__super__.constructor.apply(this, arguments);
    return _ref2;
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
    columnsAsInt = parseInt(mainWidth / this.columnWidth, radix);
    this.columnWidth = this.columnWidth + (parseInt((mainWidth - (columnsAsInt * this.columnWidth)) / columnsAsInt, radix) - magic);
    return this.$el.isotope(this.isotoptions);
  };

  Event.prototype.refresh = function() {
    var _this = this;
    return this.$el.imagesLoaded(function() {
      return _this.$el.isotope(_this.isotoptions);
    });
  };

  return Event;

})(Backbone.View);

document.gignal.views.UniBox = (function(_super) {
  __extends(UniBox, _super);

  function UniBox() {
    this.render = __bind(this.render, this);
    _ref3 = UniBox.__super__.constructor.apply(this, arguments);
    return _ref3;
  }

  UniBox.prototype.tagName = 'div';

  UniBox.prototype.className = 'gignal-outerbox';

  UniBox.prototype.events = {
    'click .gignal-image': 'showBigImg'
  };

  UniBox.prototype.initialize = function() {
    return this.listenTo(this.model, 'change', this.render);
  };

  UniBox.prototype.render = function() {
    this.$el.data('created_on', this.model.get('created_on'));
    this.$el.css('width', document.gignal.widget.columnWidth);
    if (this.model.get('admin_entry')) {
      this.$el.addClass('gignal-owner');
    }
    this.$el.html(Templates.uni.render(this.model.getData(), {
      footer: Templates.footer
    }));
    return this;
  };

  UniBox.prototype.showBigImg = function() {
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
  return the.style.backgroundImage = "url('gignal/images/twitter_blue.png')";
};

myBirdOut = function(the) {
  return the.style.backgroundImage = "url('gignal/images/twitter_gray.png')";
};

myFaceOver = function(the) {
  return the.style.backgroundImage = "url('gignal/images/facebook_blue.png')";
};

myFaceOut = function(the) {
  return the.style.backgroundImage = "url('gignal/images/facebook_gray.png')";
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
  document.gignal.widget = new document.gignal.views.Event();
  document.gignal.stream = new Stream();
  return $(window).on('scrollBottom', {
    offsetY: -100
  }, function() {
    return document.gignal.stream.update(true);
  });
});
