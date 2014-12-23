(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){

},{}],2:[function(require,module,exports){

/*
 * Crafting Guide - constants.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var Duration, Event, Opacity;

exports.Duration = Duration = {};

Duration.snap = 100;

Duration.fast = Duration.snap * 2;

Duration.normal = Duration.fast * 2;

Duration.slow = Duration.normal * 2;

exports.Opacity = Opacity = {};

Opacity.hidden = 1e-6;

Opacity.shown = 1;

exports.Event = Event = {};

Event.book = {};

Event.book.load = {};

Event.book.load.started = 'book:load:started';

Event.book.load.succeeded = 'book:load:succeeded';

Event.book.load.failed = 'book:load:failed';

Event.book.load.finished = 'book:load:finished';



},{}],3:[function(require,module,exports){

/*
 * Crafting Guide - base_controller.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseController, views,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

views = require('../views');

module.exports = BaseController = (function(_super) {
  __extends(BaseController, _super);

  function BaseController(options) {
    if (options == null) {
      options = {};
    }
    this._rendered = false;
    this._parent = options.parent;
    this._children = [];
    this._loadTemplate(options.templateName);
    BaseController.__super__.constructor.call(this, options);
  }

  BaseController.prototype.addChild = function(Controller, atSelector, options) {
    var child;
    if (options == null) {
      options = {};
    }
    options.el = this.$(atSelector)[0];
    options.parent = this;
    child = new Controller(options);
    child.render();
    this._children.push(child);
    return child;
  };

  BaseController.prototype.refresh = function() {
    return logger.verbose("" + this + " refreshing");
  };

  BaseController.prototype.onWillRender = function() {};

  BaseController.prototype.onDidRender = function() {
    return this.refresh();
  };

  BaseController.prototype.render = function(options) {
    var $newEl, $oldEl, data, _ref;
    if (options == null) {
      options = {};
    }
    if (!(!this._rendered || options.force)) {
      return this;
    }
    data = ((((_ref = this.model) != null ? _ref.toHash : void 0) != null) && this.model.toHash()) || this.model || {};
    if (this._template == null) {
      logger.error("Default render called for " + this.constructor.name + " without a template");
      return this;
    }
    logger.verbose("" + this + " rendering with data: " + data);
    this.onWillRender();
    $oldEl = this.$el;
    $newEl = Backbone.$(this._template(data));
    if ($oldEl) {
      $oldEl.replaceWith($newEl);
      $newEl.addClass($oldEl.attr('class'));
    }
    this.setElement($newEl);
    this._rendered = true;
    this.onDidRender();
    return this;
  };

  BaseController.prototype.toString = function() {
    return "" + this.constructor.name + "(" + this.cid + ")";
  };

  BaseController.prototype._loadTemplate = function(templateName) {
    if (templateName != null) {
      return this._template = views[templateName];
    }
  };

  return BaseController;

})(Backbone.View);



},{"../views":17}],4:[function(require,module,exports){

/*
 * Crafting Guide - crafting_guide_controller.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseController, LandingPage, LandingPageController, RecipeCatalogController,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseController = require('./base_controller');

LandingPage = require('../models/landing_page');

RecipeCatalogController = require('./recipe_catalog_controller');

module.exports = LandingPageController = (function(_super) {
  __extends(LandingPageController, _super);

  function LandingPageController(options) {
    if (options == null) {
      options = {};
    }
    if (options.model == null) {
      options.model = new LandingPage;
    }
    options.templateName = 'landing_page';
    LandingPageController.__super__.constructor.call(this, options);
  }

  LandingPageController.prototype.onDidRender = function() {
    this.recipeBooksController = this.addChild(RecipeCatalogController, '.view__recipe_catalog');
    return LandingPageController.__super__.onDidRender.apply(this, arguments);
  };

  return LandingPageController;

})(BaseController);



},{"../models/landing_page":11,"./base_controller":3,"./recipe_catalog_controller":5}],5:[function(require,module,exports){

/*
 * Crafting Guide - recipe_catalog_controller.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseController, RecipeCatalogController,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseController = require('./base_controller');

module.exports = RecipeCatalogController = (function(_super) {
  __extends(RecipeCatalogController, _super);

  function RecipeCatalogController(options) {
    if (options == null) {
      options = {};
    }
    options.templateName = 'recipe_catalog';
    RecipeCatalogController.__super__.constructor.call(this, options);
  }

  return RecipeCatalogController;

})(BaseController);



},{"./base_controller":3}],6:[function(require,module,exports){

/*
 * Crafting Guide - router.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var CraftingGuideRouter, Duration, LandingPageController, Opacity,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Duration = require('./constants').Duration;

LandingPageController = require('./controllers/landing_page_controller');

Opacity = require('./constants').Opacity;

module.exports = CraftingGuideRouter = (function(_super) {
  __extends(CraftingGuideRouter, _super);

  function CraftingGuideRouter(options) {
    if (options == null) {
      options = {};
    }
    this._page = null;
    this._pageControllers = {};
    CraftingGuideRouter.__super__.constructor.call(this, options);
  }

  CraftingGuideRouter.prototype.routes = {
    '': 'landing'
  };

  CraftingGuideRouter.prototype.landing = function() {
    var _base;
    if ((_base = this._pageControllers).landing == null) {
      _base.landing = new LandingPageController;
    }
    return this._setPage('landing');
  };

  CraftingGuideRouter.prototype._setPage = function(controllerName) {
    var controller, show, showDuration;
    controller = this._pageControllers[controllerName];
    if (controller == null) {
      throw new Error("cannot find controller named: " + controllerName);
    }
    if (this._page === controller) {
      return;
    }
    logger.info("changing to " + controllerName + " page");
    showDuration = Duration.normal;
    show = (function(_this) {
      return function() {
        var $pageContent;
        _this._page = controller;
        controller.render();
        $pageContent = $('.page');
        $pageContent.empty();
        $pageContent.append(controller.$el);
        return controller.$el.fadeIn(showDuration);
      };
    })(this);
    if (this._mainController != null) {
      showDuration = Duration.fast;
      return this._page.$el.fadeOut(Duration.fast, show);
    } else {
      return show();
    }
  };

  return CraftingGuideRouter;

})(Backbone.Router);



},{"./constants":2,"./controllers/landing_page_controller":4}],7:[function(require,module,exports){

/*
 * Crafting Guide - logger.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var Logger;

module.exports = Logger = (function() {
  var ALL_LEVELS;

  Logger.TRACE = {
    name: 'TRACE  ',
    value: 0
  };

  Logger.DEBUG = {
    name: 'DEBUG  ',
    value: 1
  };

  Logger.VERBOSE = {
    name: 'VERBOSE',
    value: 2
  };

  Logger.INFO = {
    name: 'INFO   ',
    value: 3
  };

  Logger.WARNING = {
    name: 'WARNING',
    value: 4
  };

  Logger.ERROR = {
    name: 'ERROR  ',
    value: 5
  };

  Logger.FATAL = {
    name: 'FATAL  ',
    value: 6
  };

  ALL_LEVELS = [Logger.TRACE, Logger.DEBUG, Logger.VERBOSE, Logger.INFO, Logger.WARNING, Logger.ERROR, Logger.FATAL];

  function Logger(options) {
    if (options == null) {
      options = {};
    }
    if (options.level == null) {
      options.level = Logger.FATAL;
    }
    this.formatText = options.format != null ? options.format : "<%= timestamp %> | <%= level %> | <%= message %>";
    this.level = this._parseLevel(options);
    this._format = _.template(this.formatText);
  }

  Logger.prototype.log = function(level, message) {
    var entry, line, lines, _i, _j, _len, _len1, _results, _results1;
    if (!(level.value >= this.level.value)) {
      return;
    }
    if (_.isFunction(message)) {
      message = message();
    }
    entry = {
      timestamp: new Date(),
      level: level,
      message: message
    };
    if (entry.level == null) {
      entry.level = this.level;
    }
    lines = this._formatEntry(entry);
    if (entry.level.value < Logger.WARNING.value) {
      _results = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        _results.push(console.log(line));
      }
      return _results;
    } else {
      _results1 = [];
      for (_j = 0, _len1 = lines.length; _j < _len1; _j++) {
        line = lines[_j];
        _results1.push(console.error(line));
      }
      return _results1;
    }
  };

  Logger.prototype.trace = function(message) {
    return this.log(Logger.TRACE, message);
  };

  Logger.prototype.debug = function(message) {
    return this.log(Logger.DEBUG, message);
  };

  Logger.prototype.verbose = function(message) {
    return this.log(Logger.VERBOSE, message);
  };

  Logger.prototype.info = function(message) {
    return this.log(Logger.INFO, message);
  };

  Logger.prototype.warning = function(message) {
    return this.log(Logger.WARNING, message);
  };

  Logger.prototype.error = function(message) {
    if (message.stack != null) {
      message = "" + message.stack;
    }
    return this.log(Logger.ERROR, message);
  };

  Logger.prototype.fatal = function(message) {
    return this.log(Logger.FATAL, message);
  };

  Logger.prototype._formatEntry = function(entry, lines) {
    var line, message, result, _i, _len, _ref;
    if (lines == null) {
      lines = [];
    }
    message = entry.message.replace(/\\n/g, '\n');
    _ref = message.split('\n');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      result = [];
      result.push(this._format({
        timestamp: "" + entry.timestamp,
        level: entry.level.name,
        message: line
      }));
      lines.push(result.join(''));
    }
    return lines;
  };

  Logger.prototype._parseLevel = function(options) {
    var candidates, l, level;
    if (!_(options).has('level')) {
      return Logger.FATAL;
    }
    level = options.level;
    if (level == null) {
      candidates = [];
    } else if (_.isString(level)) {
      candidates = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = ALL_LEVELS.length; _i < _len; _i++) {
          l = ALL_LEVELS[_i];
          if (l.name.trim().toLowerCase() === level.trim().toLowerCase()) {
            _results.push(l);
          }
        }
        return _results;
      })();
    } else if (_.isNumber(level)) {
      candidates = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = ALL_LEVELS.length; _i < _len; _i++) {
          l = ALL_LEVELS[_i];
          if (l.value === level) {
            _results.push(l);
          }
        }
        return _results;
      })();
    } else if (level != null) {
      candidates = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = ALL_LEVELS.length; _i < _len; _i++) {
          l = ALL_LEVELS[_i];
          if (l === level) {
            _results.push(l);
          }
        }
        return _results;
      })();
    }
    if (!(candidates.length > 0)) {
      throw new Error("invalid level: " + level);
    }
    return candidates[0];
  };

  return Logger;

})();



},{}],8:[function(require,module,exports){
(function (global){

/*
 * Crafting Guide - main.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var CraftingGuideRouter, Logger, views;

views = require('./views');

Logger = require('./logger');

CraftingGuideRouter = require('./crafting_guide_router');

if (typeof global === 'undefined') {
  window.global = window;
}

global.views = views;

global.logger = new Logger({
  level: Logger.TRACE
});

global.router = new CraftingGuideRouter;

logger.info("CraftingGuide is ready");

Backbone.history.start({
  pushState: true
});



}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./crafting_guide_router":6,"./logger":7,"./views":17}],9:[function(require,module,exports){

/*
 * crafting_guide - base_model.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseModel,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = BaseModel = (function(_super) {
  __extends(BaseModel, _super);

  function BaseModel(attributes, options) {
    var makeGetter, makeSetter, name, _i, _len, _ref;
    if (attributes == null) {
      attributes = {};
    }
    if (options == null) {
      options = {};
    }
    BaseModel.__super__.constructor.call(this, attributes, options);
    makeGetter = function(name) {
      return function() {
        return this.get(name);
      };
    };
    makeSetter = function(name) {
      return function(value) {
        return this.set(name, value);
      };
    };
    _ref = _.keys(attributes);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      if (name === 'id') {
        continue;
      }
      Object.defineProperty(this, name, {
        get: makeGetter(name),
        set: makeSetter(name)
      });
    }
  }

  BaseModel.prototype.sync = function() {};

  BaseModel.prototype.toString = function() {
    return "" + this.constructor.name + " (" + this.cid + ")";
  };

  return BaseModel;

})(Backbone.Model);



},{}],10:[function(require,module,exports){

/*
 * Crafting Guide - item.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseModel, Item,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseModel = require('./base_model');

module.exports = Item = (function(_super) {
  __extends(Item, _super);

  function Item(attributes, options) {
    if (attributes == null) {
      attributes = {};
    }
    if (options == null) {
      options = {};
    }
    if (attributes.name == null) {
      attributes.name = '';
    }
    if (attributes.quantity == null) {
      attributes.quantity = 1;
    }
    Item.__super__.constructor.call(this, attributes, options);
  }

  return Item;

})(BaseModel);



},{"./base_model":9}],11:[function(require,module,exports){

/*
 * Crafting Guide - landing_page.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseModel, LandingPage, RecipeCatalog,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseModel = require('./base_model');

RecipeCatalog = require('./recipe_catalog');

module.exports = LandingPage = (function(_super) {
  __extends(LandingPage, _super);

  function LandingPage(attributes, options) {
    if (attributes == null) {
      attributes = {};
    }
    if (options == null) {
      options = {};
    }
    if (attributes.catalog == null) {
      attributes.catalog = new RecipeCatalog;
    }
    LandingPage.__super__.constructor.call(this, attributes, options);
  }

  return LandingPage;

})(BaseModel);



},{"./base_model":9,"./recipe_catalog":16}],12:[function(require,module,exports){

/*
 * Crafting Guide - v1.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var Item, Recipe, RecipeBook, V1;

Item = require('../item');

Recipe = require('../recipe');

RecipeBook = require('../recipe_book');

module.exports = V1 = (function() {
  function V1() {
    this._errorLocation = 'the header information';
  }

  V1.prototype.parse = function(data) {
    return this._parseRecipeBook(data);
  };

  V1.prototype._parseRecipeBook = function(data) {
    var book, index, recipeData, _i, _ref;
    if (data == null) {
      throw new Error('recipe book data is missing');
    }
    if (data.version == null) {
      throw new Error('version is required');
    }
    if (data.mod_name == null) {
      throw new Error('mod_name is required');
    }
    if (data.mod_version == null) {
      throw new Error('mod_version is required');
    }
    if (!_.isArray(data.recipes)) {
      throw new Error('recipes must be an array');
    }
    book = new RecipeBook({
      version: data.version,
      modName: data.mod_name,
      modVersion: data.mod_version
    });
    book.description = data.description || '';
    for (index = _i = 0, _ref = data.recipes.length; 0 <= _ref ? _i < _ref : _i > _ref; index = 0 <= _ref ? ++_i : --_i) {
      this._errorLocation = "recipe " + (index + 1);
      recipeData = data.recipes[index];
      book.recipes.push(this._parseRecipe(recipeData));
    }
    return book;
  };

  V1.prototype._parseRecipe = function(data, options) {
    var input, output, tools;
    if (options == null) {
      options = {};
    }
    if (data == null) {
      throw new Error("recipe data is missing for " + this._errorLocation);
    }
    if (data.output == null) {
      throw new Error("" + this._errorLocation + " is missing output");
    }
    if (data.input == null) {
      throw new Error("" + this._errorLocation + " is missing input");
    }
    output = this._parseItemList(data.output, {
      field: 'output',
      canBeEmpty: false
    });
    this._errorLocation = "recipe for output[0].name";
    if (data.tools == null) {
      data.tools = [];
    }
    input = this._parseItemList(data.input, {
      field: 'input',
      canBeEmpty: false
    });
    tools = this._parseItemList(data.tools, {
      field: 'tools',
      canBeEmpty: true
    });
    return new Recipe({
      input: input,
      output: output,
      tools: tools
    });
  };

  V1.prototype._parseItemList = function(data, options) {
    var index, itemData, result, _i, _ref;
    if (options == null) {
      options = {};
    }
    if (data == null) {
      throw new Error("" + this._errorLocation + " must have an " + options.field + " field");
    }
    if (!_.isArray(data)) {
      data = [data];
    }
    if (data.length === 0 && !options.canBeEmpty) {
      throw new Error("" + options.field + " for " + this._errorLocation + " cannot be empty");
    }
    result = [];
    for (index = _i = 0, _ref = data.length; 0 <= _ref ? _i < _ref : _i > _ref; index = 0 <= _ref ? ++_i : --_i) {
      itemData = data[index];
      result.push(this._parseItem(itemData, {
        field: options.field,
        index: index
      }));
    }
    return result;
  };

  V1.prototype._parseItem = function(data, options) {
    var errorBase;
    if (options == null) {
      options = {};
    }
    errorBase = "" + options.field + " element " + options.index + " for " + this._errorLocation;
    if (data == null) {
      throw new Error("" + errorBase + " is missing");
    }
    if (_.isString(data)) {
      data = [1, data];
    }
    if (!_.isArray(data)) {
      throw new Error("" + errorBase + " must be an array");
    }
    if (data.length === 1) {
      data.unshift(1);
    }
    if (data.length !== 2) {
      throw new Error("" + errorBase + " must have at least one element");
    }
    if (!_.isNumber(data[0])) {
      throw new Error("" + errorBase + " must start with a number");
    }
    return new Item({
      quantity: data[0],
      name: data[1]
    });
  };

  return V1;

})();



},{"../item":10,"../recipe":13,"../recipe_book":14}],13:[function(require,module,exports){

/*
 * Crafting Guide - recipe.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseModel, Recipe,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseModel = require('./base_model');

module.exports = Recipe = (function(_super) {
  __extends(Recipe, _super);

  function Recipe(attributes, options) {
    if (attributes == null) {
      attributes = {};
    }
    if (options == null) {
      options = {};
    }
    Recipe.__super__.constructor.call(this, attributes, options);
    Object.defineProperty(this, 'name', {
      get: function() {
        return this.output[0].name;
      }
    });
  }

  return Recipe;

})(BaseModel);



},{"./base_model":9}],14:[function(require,module,exports){

/*
 * Crafting Guide - recipe_book.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseModel, RecipeBook,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseModel = require('./base_model');

module.exports = RecipeBook = (function(_super) {
  __extends(RecipeBook, _super);

  function RecipeBook(attributes, options) {
    if (attributes == null) {
      attributes = {};
    }
    if (options == null) {
      options = {};
    }
    if (_.isEmpty(attributes.modName)) {
      throw new Error('modName cannot be empty');
    }
    if (_.isEmpty(attributes.modVersion)) {
      throw new Error('modVersion cannot be empty');
    }
    if (attributes.description == null) {
      attributes.description = '';
    }
    if (attributes.recipes == null) {
      attributes.recipes = [];
    }
    RecipeBook.__super__.constructor.call(this, attributes, options);
  }

  RecipeBook.prototype.getRecipes = function(name) {
    var recipe, result, _i, _len, _ref;
    result = [];
    _ref = this.recipes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      recipe = _ref[_i];
      if (recipe.name === name) {
        result.push(recipe);
      }
    }
    return result;
  };

  RecipeBook.prototype.toString = function() {
    return "RecipeBook (" + this.cid + ") { modName:" + this.modName + ", modVersion:" + this.modVersion + ", recipes:" + this.recipes.length + " items}";
  };

  return RecipeBook;

})(BaseModel);



},{"./base_model":9}],15:[function(require,module,exports){

/*
 * Crafting Guide - recipe_book_parser.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var RecipeBookParser, V1;

V1 = require('./parser_versions/v1');

module.exports = RecipeBookParser = (function() {
  function RecipeBookParser() {
    this._parsers = {
      '1': new V1
    };
  }

  RecipeBookParser.prototype.parse = function(data) {
    var parser;
    if (data == null) {
      throw new Error('recipe book data is missing');
    }
    if (data.version == null) {
      throw new Error('version is required');
    }
    parser = this._parsers["" + data.version];
    if (parser == null) {
      throw new Error("cannot parse version " + data.version + " recipe books");
    }
    return parser.parse(data);
  };

  return RecipeBookParser;

})();



},{"./parser_versions/v1":12}],16:[function(require,module,exports){

/*
 * Crafting Guide - recipe_catalog.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var BaseModel, Event, RecipeBookParser, RecipeCatalog,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseModel = require('./base_model');

Event = require('../constants').Event;

RecipeBookParser = require('./recipe_book_parser');

module.exports = RecipeCatalog = (function(_super) {
  __extends(RecipeCatalog, _super);

  function RecipeCatalog(attributes, options) {
    if (attributes == null) {
      attributes = {};
    }
    if (options == null) {
      options = {};
    }
    if (attributes.books == null) {
      attributes.books = [];
    }
    RecipeCatalog.__super__.constructor.call(this, attributes, options);
    this._parser = new RecipeBookParser;
  }

  RecipeCatalog.prototype.loadBook = function(url) {
    this.trigger(Event.book.load.started, this, url);
    return $.ajax({
      url: url,
      dataType: 'json',
      success: (function(_this) {
        return function(data, status, xhr) {
          return _this.onBookLoaded(data, status, xhr);
        };
      })(this),
      error: (function(_this) {
        return function(xhr, status, error) {
          return _this.onBookLoadFailed(error, status, xhr);
        };
      })(this)
    });
  };

  RecipeCatalog.prototype.onBookLoaded = function(data, status, xhr) {
    var e;
    try {
      this.books.push(this._parser.parse(data));
      _(this.books).sortBy('name');
      logger.info("loaded recipe book: " + book);
      this.trigger(Event.book.load.succeeded, this, book);
      return this.trigger(Event.book.load.finished, this);
    } catch (_error) {
      e = _error;
      return this.onBookLoadFailed(error, status, xhr);
    }
  };

  RecipeCatalog.prototype.onBookLoadFailed = function(error, status, xhr) {
    logger.error("failed to load recipe book: " + error);
    this.trigger(Event.book.load.failed, this, error.message);
    return this.trigger(Event.book.load.finished, this);
  };

  RecipeCatalog.prototype.toString = function() {
    return "RecipeCatalog (" + this.cid + ") {books:" + this.books.length + " items}";
  };

  return RecipeCatalog;

})(BaseModel);



},{"../constants":2,"./base_model":9,"./recipe_book_parser":15}],17:[function(require,module,exports){
var jade = jade || require('jade').runtime;

this["JST"] = this["JST"] || {};

this["JST"]["landing_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<div class=\"view__landing_page\">\n  <div class=\"view__recipe_catalog\"></div>\n  <div class=\"view__crafter\"></div>\n</div>");;return buf.join("");
};

this["JST"]["recipe_catalog"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<div class=\"view__recipe_catalog\">\n  <h2><img src=\"/images/bookshelf.png\"/>\n    <p>Recipe Catalog</p>\n  </h2>\n  <table class=\"books\">\n    <tr>\n      <td>&nbsp;</td>\n      <td>\n        <input placeholder=\"enter a URL to load another recipe book...\" class=\"recipe_book_url\"/>\n        <button class=\"recipe_book_load_button\">Load</button>\n      </td>\n    </tr>\n  </table>\n  <div class=\"load_error\">\n    <p></p>\n  </div>\n</div>");;return buf.join("");
};

this["JST"]["test"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<p>Hello world!</p>");;return buf.join("");
};

if (typeof exports === 'object' && exports) {module.exports = this["JST"];}
},{"jade":1}]},{},[8]);
