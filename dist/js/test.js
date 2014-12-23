(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function (sinonChai) {
    "use strict";

    // Module systems magic dance.

    /* istanbul ignore else */
    if (typeof require === "function" && typeof exports === "object" && typeof module === "object") {
        // NodeJS
        module.exports = sinonChai;
    } else if (typeof define === "function" && define.amd) {
        // AMD
        define(function () {
            return sinonChai;
        });
    } else {
        // Other environment (usually <script> tag): plug in to global chai instance directly.
        chai.use(sinonChai);
    }
}(function sinonChai(chai, utils) {
    "use strict";

    var slice = Array.prototype.slice;

    function isSpy(putativeSpy) {
        return typeof putativeSpy === "function" &&
               typeof putativeSpy.getCall === "function" &&
               typeof putativeSpy.calledWithExactly === "function";
    }

    function timesInWords(count) {
        return count === 1 ? "once" :
               count === 2 ? "twice" :
               count === 3 ? "thrice" :
               (count || 0) + " times";
    }

    function isCall(putativeCall) {
        return putativeCall && isSpy(putativeCall.proxy);
    }

    function assertCanWorkWith(assertion) {
        if (!isSpy(assertion._obj) && !isCall(assertion._obj)) {
            throw new TypeError(utils.inspect(assertion._obj) + " is not a spy or a call to a spy!");
        }
    }

    function getMessages(spy, action, nonNegatedSuffix, always, args) {
        var verbPhrase = always ? "always have " : "have ";
        nonNegatedSuffix = nonNegatedSuffix || "";
        if (isSpy(spy.proxy)) {
            spy = spy.proxy;
        }

        function printfArray(array) {
            return spy.printf.apply(spy, array);
        }

        return {
            affirmative: function () {
                return printfArray(["expected %n to " + verbPhrase + action + nonNegatedSuffix].concat(args));
            },
            negative: function () {
                return printfArray(["expected %n to not " + verbPhrase + action].concat(args));
            }
        };
    }

    function sinonProperty(name, action, nonNegatedSuffix) {
        utils.addProperty(chai.Assertion.prototype, name, function () {
            assertCanWorkWith(this);

            var messages = getMessages(this._obj, action, nonNegatedSuffix, false);
            this.assert(this._obj[name], messages.affirmative, messages.negative);
        });
    }

    function sinonPropertyAsBooleanMethod(name, action, nonNegatedSuffix) {
        utils.addMethod(chai.Assertion.prototype, name, function (arg) {
            assertCanWorkWith(this);

            var messages = getMessages(this._obj, action, nonNegatedSuffix, false, [timesInWords(arg)]);
            this.assert(this._obj[name] === arg, messages.affirmative, messages.negative);
        });
    }

    function createSinonMethodHandler(sinonName, action, nonNegatedSuffix) {
        return function () {
            assertCanWorkWith(this);

            var alwaysSinonMethod = "always" + sinonName[0].toUpperCase() + sinonName.substring(1);
            var shouldBeAlways = utils.flag(this, "always") && typeof this._obj[alwaysSinonMethod] === "function";
            var sinonMethod = shouldBeAlways ? alwaysSinonMethod : sinonName;

            var messages = getMessages(this._obj, action, nonNegatedSuffix, shouldBeAlways, slice.call(arguments));
            this.assert(this._obj[sinonMethod].apply(this._obj, arguments), messages.affirmative, messages.negative);
        };
    }

    function sinonMethodAsProperty(name, action, nonNegatedSuffix) {
        var handler = createSinonMethodHandler(name, action, nonNegatedSuffix);
        utils.addProperty(chai.Assertion.prototype, name, handler);
    }

    function exceptionalSinonMethod(chaiName, sinonName, action, nonNegatedSuffix) {
        var handler = createSinonMethodHandler(sinonName, action, nonNegatedSuffix);
        utils.addMethod(chai.Assertion.prototype, chaiName, handler);
    }

    function sinonMethod(name, action, nonNegatedSuffix) {
        exceptionalSinonMethod(name, name, action, nonNegatedSuffix);
    }

    utils.addProperty(chai.Assertion.prototype, "always", function () {
        utils.flag(this, "always", true);
    });

    sinonProperty("called", "been called", " at least once, but it was never called");
    sinonPropertyAsBooleanMethod("callCount", "been called exactly %1", ", but it was called %c%C");
    sinonProperty("calledOnce", "been called exactly once", ", but it was called %c%C");
    sinonProperty("calledTwice", "been called exactly twice", ", but it was called %c%C");
    sinonProperty("calledThrice", "been called exactly thrice", ", but it was called %c%C");
    sinonMethodAsProperty("calledWithNew", "been called with new");
    sinonMethod("calledBefore", "been called before %1");
    sinonMethod("calledAfter", "been called after %1");
    sinonMethod("calledOn", "been called with %1 as this", ", but it was called with %t instead");
    sinonMethod("calledWith", "been called with arguments %*", "%C");
    sinonMethod("calledWithExactly", "been called with exact arguments %*", "%C");
    sinonMethod("calledWithMatch", "been called with arguments matching %*", "%C");
    sinonMethod("returned", "returned %1");
    exceptionalSinonMethod("thrown", "threw", "thrown %1");
}));

},{}],2:[function(require,module,exports){

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



},{}],3:[function(require,module,exports){

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



},{"./base_model":2}],4:[function(require,module,exports){

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



},{"../item":3,"../recipe":5,"../recipe_book":6}],5:[function(require,module,exports){

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



},{"./base_model":2}],6:[function(require,module,exports){

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



},{"./base_model":2}],7:[function(require,module,exports){

/*
 * Crafting Guide - v1.test.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
var V1, parser;

V1 = require('../../src/scripts/models/parser_versions/v1');

parser = null;

describe('RecipeBookParser.V1', function() {
  before(function() {
    return parser = new V1;
  });
  describe('_parseRecipeBook', function() {
    it('requires a mod_name', function() {
      var data;
      data = {
        version: 1,
        mod_version: '1.0',
        recipes: []
      };
      return expect(function() {
        return parser._parseRecipeBook(data);
      }).to["throw"](Error, 'mod_name is required');
    });
    it('requires a mod_version', function() {
      var data;
      data = {
        version: 1,
        mod_name: 'Empty',
        recipes: []
      };
      return expect(function() {
        return parser._parseRecipeBook(data);
      }).to["throw"](Error, 'mod_version is required');
    });
    it('can parse an empty recipe book', function() {
      var book, data;
      data = {
        version: 1,
        mod_name: 'Empty',
        mod_version: '1.0',
        recipes: []
      };
      book = parser._parseRecipeBook(data);
      book.modName.should.equal('Empty');
      return book.modVersion.should.equal('1.0');
    });
    return it('can parse a non-empty recipe book', function() {
      var book, data, r;
      data = {
        version: 1,
        mod_name: 'Minecraft',
        mod_version: '1.7.10',
        recipes: [
          {
            input: 'sugar cane',
            output: 'sugar'
          }, {
            input: [[3, 'wool'], [3, 'planks']],
            tools: 'crafting table',
            output: 'bed'
          }
        ]
      };
      book = parser._parseRecipeBook(data);
      book.modName.should.equal('Minecraft');
      book.modVersion.should.equal('1.7.10');
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = book.recipes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          r = _ref[_i];
          _results.push(r.name);
        }
        return _results;
      })()).sort().should.eql(['bed', 'sugar']);
    });
  });
  describe('_parseRecipe', function() {
    it('requires output to be defined', function() {
      parser._errorLocation = 'boat';
      return expect(function() {
        return parser._parseRecipe({
          input: 'wool'
        });
      }).to["throw"](Error, 'boat is missing output');
    });
    it('requires input to be defined', function() {
      parser._errorLocation = 'boat';
      return expect(function() {
        return parser._parseRecipe({
          output: 'wool'
        });
      }).to["throw"](Error, 'boat is missing input');
    });
    it('can parse a regular recipe', function() {
      var data, i, recipe;
      data = {
        output: 'bed',
        input: [[3, 'planks'], [3, 'wool']],
        tools: 'crafting table'
      };
      recipe = parser._parseRecipe(data);
      ((function() {
        var _i, _len, _ref, _results;
        _ref = recipe.output;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.name);
        }
        return _results;
      })()).should.eql(['bed']);
      ((function() {
        var _i, _len, _ref, _results;
        _ref = recipe.input;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.name);
        }
        return _results;
      })()).sort().should.eql(['planks', 'wool']);
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = recipe.tools;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.name);
        }
        return _results;
      })()).should.eql(['crafting table']);
    });
    return it('can parse a recipe without tools', function() {
      var i, recipe;
      recipe = parser._parseRecipe({
        output: 'sugar',
        input: 'sugar cane'
      });
      ((function() {
        var _i, _len, _ref, _results;
        _ref = recipe.output;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.name);
        }
        return _results;
      })()).should.eql(['sugar']);
      ((function() {
        var _i, _len, _ref, _results;
        _ref = recipe.input;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.name);
        }
        return _results;
      })()).sort().should.eql(['sugar cane']);
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = recipe.tools;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(i.name);
        }
        return _results;
      })()).should.eql([]);
    });
  });
  describe('_parseItemList', function() {
    it('can promote a single item to a list', function() {
      var i, list;
      list = parser._parseItemList('boat');
      return ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          i = list[_i];
          _results.push(i.name);
        }
        return _results;
      })()).should.eql(['boat']);
    });
    it('can require a list to be non-empty', function() {
      var options;
      parser._errorLocation = 'boat';
      options = {
        field: 'output',
        canBeEmpty: false
      };
      return expect(function() {
        return parser._parseItemList([], options);
      }).to["throw"](Error, 'output for boat cannot be empty');
    });
    it('can allow an empty list', function() {
      var list;
      list = parser._parseItemList([], {
        canBeEmpty: true
      });
      return list.length.should.equal(0);
    });
    return it('can parse a non-empty list', function() {
      var i, list;
      list = parser._parseItemList([[3, 'plank'], [3, 'wool']]);
      return ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          i = list[_i];
          _results.push(i.name);
        }
        return _results;
      })()).sort().should.eql(['plank', 'wool']);
    });
  });
  return describe('_parseItem', function() {
    it('requires the array to have at least one element', function() {
      var options;
      parser._errorLocation = 'boat';
      options = {
        index: 1,
        field: 'output'
      };
      return expect(function() {
        return parser._parseItem([], options);
      }).to["throw"](Error, "output element 1 for boat must have at least one element");
    });
    it('can fill in a missing number', function() {
      var item, item2;
      item = parser._parseItem('boat');
      item.name.should.equal('boat');
      item.quantity.should.equal(1);
      item2 = parser._parseItem(['boat']);
      item2.name.should.equal('boat');
      return item2.quantity.should.equal(1);
    });
    it('requires the data to start with a number', function() {
      var options;
      parser._errorLocation = 'boat';
      options = {
        index: 1,
        field: 'output'
      };
      return expect(function() {
        return parser._parseItem(['2', 'book'], options);
      }).to["throw"](Error, "output element 1 for boat must start with a number");
    });
    return it('can parse a basic item', function() {
      var item;
      item = parser._parseItem([2, 'book']);
      return item.constructor.name.should.equal('Item');
    });
  });
});



},{"../../src/scripts/models/parser_versions/v1":4}],8:[function(require,module,exports){
(function (global){

/*
 * Crafting Guide - test.coffee
 *
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */
chai.use(require('sinon-chai'));

chai.config.includeStack = true;

if (typeof global === 'undefined') {
  window.global = window;
}

global.assert = chai.assert;

global.expect = chai.expect;

global.should = chai.should();

mocha.setup('bdd');

require('./parser_versions/v1.test');

mocha.checkLeaks();

mocha.run();



}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./parser_versions/v1.test":7,"sinon-chai":1}]},{},[8])
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIm5vZGVfbW9kdWxlcy9ncnVudC1icm93c2VyaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJub2RlX21vZHVsZXMvc2lub24tY2hhaS9saWIvc2lub24tY2hhaS5qcyIsIi9Vc2Vycy9hbmRyZXcvRG9jdW1lbnRzL1NvdXJjZS9jcmFmdGluZy1ndWlkZS9zcmMvc2NyaXB0cy9tb2RlbHMvYmFzZV9tb2RlbC5jb2ZmZWUiLCIvVXNlcnMvYW5kcmV3L0RvY3VtZW50cy9Tb3VyY2UvY3JhZnRpbmctZ3VpZGUvc3JjL3NjcmlwdHMvbW9kZWxzL2l0ZW0uY29mZmVlIiwiL1VzZXJzL2FuZHJldy9Eb2N1bWVudHMvU291cmNlL2NyYWZ0aW5nLWd1aWRlL3NyYy9zY3JpcHRzL21vZGVscy9wYXJzZXJfdmVyc2lvbnMvdjEuY29mZmVlIiwiL1VzZXJzL2FuZHJldy9Eb2N1bWVudHMvU291cmNlL2NyYWZ0aW5nLWd1aWRlL3NyYy9zY3JpcHRzL21vZGVscy9yZWNpcGUuY29mZmVlIiwiL1VzZXJzL2FuZHJldy9Eb2N1bWVudHMvU291cmNlL2NyYWZ0aW5nLWd1aWRlL3NyYy9zY3JpcHRzL21vZGVscy9yZWNpcGVfYm9vay5jb2ZmZWUiLCIvVXNlcnMvYW5kcmV3L0RvY3VtZW50cy9Tb3VyY2UvY3JhZnRpbmctZ3VpZGUvdGVzdC9wYXJzZXJfdmVyc2lvbnMvdjEudGVzdC5jb2ZmZWUiLCIvVXNlcnMvYW5kcmV3L0RvY3VtZW50cy9Tb3VyY2UvY3JhZnRpbmctZ3VpZGUvdGVzdC90ZXN0LmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtBQ0FBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUNuSUE7QUFBQTs7Ozs7R0FBQTtBQUFBLElBQUEsU0FBQTtFQUFBO2lTQUFBOztBQUFBLE1BU00sQ0FBQyxPQUFQLEdBQXVCO0FBRW5CLDhCQUFBLENBQUE7O0FBQWEsRUFBQSxtQkFBQyxVQUFELEVBQWdCLE9BQWhCLEdBQUE7QUFDVCxRQUFBLDRDQUFBOztNQURVLGFBQVc7S0FDckI7O01BRHlCLFVBQVE7S0FDakM7QUFBQSxJQUFBLDJDQUFNLFVBQU4sRUFBa0IsT0FBbEIsQ0FBQSxDQUFBO0FBQUEsSUFFQSxVQUFBLEdBQWEsU0FBQyxJQUFELEdBQUE7QUFBUyxhQUFPLFNBQUEsR0FBQTtlQUFHLElBQUMsQ0FBQSxHQUFELENBQUssSUFBTCxFQUFIO01BQUEsQ0FBUCxDQUFUO0lBQUEsQ0FGYixDQUFBO0FBQUEsSUFHQSxVQUFBLEdBQWEsU0FBQyxJQUFELEdBQUE7QUFBUyxhQUFPLFNBQUMsS0FBRCxHQUFBO2VBQVUsSUFBQyxDQUFBLEdBQUQsQ0FBSyxJQUFMLEVBQVcsS0FBWCxFQUFWO01BQUEsQ0FBUCxDQUFUO0lBQUEsQ0FIYixDQUFBO0FBSUE7QUFBQSxTQUFBLDJDQUFBO3NCQUFBO0FBQ0ksTUFBQSxJQUFZLElBQUEsS0FBUSxJQUFwQjtBQUFBLGlCQUFBO09BQUE7QUFBQSxNQUNBLE1BQU0sQ0FBQyxjQUFQLENBQXNCLElBQXRCLEVBQTRCLElBQTVCLEVBQWtDO0FBQUEsUUFBQSxHQUFBLEVBQUksVUFBQSxDQUFXLElBQVgsQ0FBSjtBQUFBLFFBQXNCLEdBQUEsRUFBSSxVQUFBLENBQVcsSUFBWCxDQUExQjtPQUFsQyxDQURBLENBREo7QUFBQSxLQUxTO0VBQUEsQ0FBYjs7QUFBQSxzQkFXQSxJQUFBLEdBQU0sU0FBQSxHQUFBLENBWE4sQ0FBQTs7QUFBQSxzQkFlQSxRQUFBLEdBQVUsU0FBQSxHQUFBO0FBQ04sV0FBTyxFQUFBLEdBQUcsSUFBQyxDQUFBLFdBQVcsQ0FBQyxJQUFoQixHQUFxQixJQUFyQixHQUF5QixJQUFDLENBQUEsR0FBMUIsR0FBOEIsR0FBckMsQ0FETTtFQUFBLENBZlYsQ0FBQTs7bUJBQUE7O0dBRnFDLFFBQVEsQ0FBQyxNQVRsRCxDQUFBOzs7OztBQ0FBO0FBQUE7Ozs7O0dBQUE7QUFBQSxJQUFBLGVBQUE7RUFBQTtpU0FBQTs7QUFBQSxTQU9BLEdBQVksT0FBQSxDQUFRLGNBQVIsQ0FQWixDQUFBOztBQUFBLE1BV00sQ0FBQyxPQUFQLEdBQXVCO0FBRW5CLHlCQUFBLENBQUE7O0FBQWEsRUFBQSxjQUFDLFVBQUQsRUFBZ0IsT0FBaEIsR0FBQTs7TUFBQyxhQUFXO0tBQ3JCOztNQUR5QixVQUFRO0tBQ2pDOztNQUFBLFVBQVUsQ0FBQyxPQUFZO0tBQXZCOztNQUNBLFVBQVUsQ0FBQyxXQUFZO0tBRHZCO0FBQUEsSUFFQSxzQ0FBTSxVQUFOLEVBQWtCLE9BQWxCLENBRkEsQ0FEUztFQUFBLENBQWI7O2NBQUE7O0dBRmdDLFVBWHBDLENBQUE7Ozs7O0FDQUE7QUFBQTs7Ozs7R0FBQTtBQUFBLElBQUEsNEJBQUE7O0FBQUEsSUFPQSxHQUFhLE9BQUEsQ0FBUSxTQUFSLENBUGIsQ0FBQTs7QUFBQSxNQVFBLEdBQWEsT0FBQSxDQUFRLFdBQVIsQ0FSYixDQUFBOztBQUFBLFVBU0EsR0FBYSxPQUFBLENBQVEsZ0JBQVIsQ0FUYixDQUFBOztBQUFBLE1BY00sQ0FBQyxPQUFQLEdBQXVCO0FBRU4sRUFBQSxZQUFBLEdBQUE7QUFDVCxJQUFBLElBQUMsQ0FBQSxjQUFELEdBQWtCLHdCQUFsQixDQURTO0VBQUEsQ0FBYjs7QUFBQSxlQUdBLEtBQUEsR0FBTyxTQUFDLElBQUQsR0FBQTtBQUNILFdBQU8sSUFBQyxDQUFBLGdCQUFELENBQWtCLElBQWxCLENBQVAsQ0FERztFQUFBLENBSFAsQ0FBQTs7QUFBQSxlQVFBLGdCQUFBLEdBQWtCLFNBQUMsSUFBRCxHQUFBO0FBQ2QsUUFBQSxpQ0FBQTtBQUFBLElBQUEsSUFBTyxZQUFQO0FBQWtCLFlBQVUsSUFBQSxLQUFBLENBQU0sNkJBQU4sQ0FBVixDQUFsQjtLQUFBO0FBQ0EsSUFBQSxJQUFPLG9CQUFQO0FBQTBCLFlBQVUsSUFBQSxLQUFBLENBQU0scUJBQU4sQ0FBVixDQUExQjtLQURBO0FBRUEsSUFBQSxJQUFPLHFCQUFQO0FBQTJCLFlBQVUsSUFBQSxLQUFBLENBQU0sc0JBQU4sQ0FBVixDQUEzQjtLQUZBO0FBR0EsSUFBQSxJQUFPLHdCQUFQO0FBQThCLFlBQVUsSUFBQSxLQUFBLENBQU0seUJBQU4sQ0FBVixDQUE5QjtLQUhBO0FBSUEsSUFBQSxJQUFHLENBQUEsQ0FBSyxDQUFDLE9BQUYsQ0FBVSxJQUFJLENBQUMsT0FBZixDQUFQO0FBQW9DLFlBQVUsSUFBQSxLQUFBLENBQU0sMEJBQU4sQ0FBVixDQUFwQztLQUpBO0FBQUEsSUFNQSxJQUFBLEdBQXVCLElBQUEsVUFBQSxDQUFXO0FBQUEsTUFBQSxPQUFBLEVBQVEsSUFBSSxDQUFDLE9BQWI7QUFBQSxNQUFzQixPQUFBLEVBQVEsSUFBSSxDQUFDLFFBQW5DO0FBQUEsTUFBNkMsVUFBQSxFQUFXLElBQUksQ0FBQyxXQUE3RDtLQUFYLENBTnZCLENBQUE7QUFBQSxJQU9BLElBQUksQ0FBQyxXQUFMLEdBQW1CLElBQUksQ0FBQyxXQUFMLElBQW9CLEVBUHZDLENBQUE7QUFTQSxTQUFhLDhHQUFiLEdBQUE7QUFDSSxNQUFBLElBQUMsQ0FBQSxjQUFELEdBQW1CLFNBQUEsR0FBUSxDQUFDLEtBQUEsR0FBUSxDQUFULENBQTNCLENBQUE7QUFBQSxNQUNBLFVBQUEsR0FBYSxJQUFJLENBQUMsT0FBUSxDQUFBLEtBQUEsQ0FEMUIsQ0FBQTtBQUFBLE1BRUEsSUFBSSxDQUFDLE9BQU8sQ0FBQyxJQUFiLENBQWtCLElBQUMsQ0FBQSxZQUFELENBQWMsVUFBZCxDQUFsQixDQUZBLENBREo7QUFBQSxLQVRBO0FBY0EsV0FBTyxJQUFQLENBZmM7RUFBQSxDQVJsQixDQUFBOztBQUFBLGVBeUJBLFlBQUEsR0FBYyxTQUFDLElBQUQsRUFBTyxPQUFQLEdBQUE7QUFDVixRQUFBLG9CQUFBOztNQURpQixVQUFRO0tBQ3pCO0FBQUEsSUFBQSxJQUFPLFlBQVA7QUFBa0IsWUFBVSxJQUFBLEtBQUEsQ0FBTyw2QkFBQSxHQUE2QixJQUFDLENBQUEsY0FBckMsQ0FBVixDQUFsQjtLQUFBO0FBQ0EsSUFBQSxJQUFPLG1CQUFQO0FBQXlCLFlBQVUsSUFBQSxLQUFBLENBQU0sRUFBQSxHQUFHLElBQUMsQ0FBQSxjQUFKLEdBQW1CLG9CQUF6QixDQUFWLENBQXpCO0tBREE7QUFFQSxJQUFBLElBQU8sa0JBQVA7QUFBd0IsWUFBVSxJQUFBLEtBQUEsQ0FBTSxFQUFBLEdBQUcsSUFBQyxDQUFBLGNBQUosR0FBbUIsbUJBQXpCLENBQVYsQ0FBeEI7S0FGQTtBQUFBLElBSUEsTUFBQSxHQUFTLElBQUMsQ0FBQSxjQUFELENBQWdCLElBQUksQ0FBQyxNQUFyQixFQUE2QjtBQUFBLE1BQUEsS0FBQSxFQUFNLFFBQU47QUFBQSxNQUFnQixVQUFBLEVBQVcsS0FBM0I7S0FBN0IsQ0FKVCxDQUFBO0FBQUEsSUFLQSxJQUFDLENBQUEsY0FBRCxHQUFrQiwyQkFMbEIsQ0FBQTs7TUFPQSxJQUFJLENBQUMsUUFBUztLQVBkO0FBQUEsSUFRQSxLQUFBLEdBQVMsSUFBQyxDQUFBLGNBQUQsQ0FBZ0IsSUFBSSxDQUFDLEtBQXJCLEVBQTZCO0FBQUEsTUFBQSxLQUFBLEVBQU0sT0FBTjtBQUFBLE1BQWUsVUFBQSxFQUFXLEtBQTFCO0tBQTdCLENBUlQsQ0FBQTtBQUFBLElBU0EsS0FBQSxHQUFTLElBQUMsQ0FBQSxjQUFELENBQWdCLElBQUksQ0FBQyxLQUFyQixFQUE2QjtBQUFBLE1BQUEsS0FBQSxFQUFNLE9BQU47QUFBQSxNQUFlLFVBQUEsRUFBVyxJQUExQjtLQUE3QixDQVRULENBQUE7QUFXQSxXQUFXLElBQUEsTUFBQSxDQUFPO0FBQUEsTUFBQSxLQUFBLEVBQU0sS0FBTjtBQUFBLE1BQWEsTUFBQSxFQUFPLE1BQXBCO0FBQUEsTUFBNEIsS0FBQSxFQUFNLEtBQWxDO0tBQVAsQ0FBWCxDQVpVO0VBQUEsQ0F6QmQsQ0FBQTs7QUFBQSxlQXVDQSxjQUFBLEdBQWdCLFNBQUMsSUFBRCxFQUFPLE9BQVAsR0FBQTtBQUNaLFFBQUEsaUNBQUE7O01BRG1CLFVBQVE7S0FDM0I7QUFBQSxJQUFBLElBQU8sWUFBUDtBQUFrQixZQUFVLElBQUEsS0FBQSxDQUFNLEVBQUEsR0FBRyxJQUFDLENBQUEsY0FBSixHQUFtQixnQkFBbkIsR0FBbUMsT0FBTyxDQUFDLEtBQTNDLEdBQWlELFFBQXZELENBQVYsQ0FBbEI7S0FBQTtBQUVBLElBQUEsSUFBRyxDQUFBLENBQUssQ0FBQyxPQUFGLENBQVUsSUFBVixDQUFQO0FBQTRCLE1BQUEsSUFBQSxHQUFPLENBQUMsSUFBRCxDQUFQLENBQTVCO0tBRkE7QUFHQSxJQUFBLElBQUcsSUFBSSxDQUFDLE1BQUwsS0FBZSxDQUFmLElBQXFCLENBQUEsT0FBVyxDQUFDLFVBQXBDO0FBQ0ksWUFBVSxJQUFBLEtBQUEsQ0FBTSxFQUFBLEdBQUcsT0FBTyxDQUFDLEtBQVgsR0FBaUIsT0FBakIsR0FBd0IsSUFBQyxDQUFBLGNBQXpCLEdBQXdDLGtCQUE5QyxDQUFWLENBREo7S0FIQTtBQUFBLElBTUEsTUFBQSxHQUFTLEVBTlQsQ0FBQTtBQU9BLFNBQWEsc0dBQWIsR0FBQTtBQUNJLE1BQUEsUUFBQSxHQUFXLElBQUssQ0FBQSxLQUFBLENBQWhCLENBQUE7QUFBQSxNQUNBLE1BQU0sQ0FBQyxJQUFQLENBQVksSUFBQyxDQUFBLFVBQUQsQ0FBWSxRQUFaLEVBQXNCO0FBQUEsUUFBQSxLQUFBLEVBQU0sT0FBTyxDQUFDLEtBQWQ7QUFBQSxRQUFxQixLQUFBLEVBQU0sS0FBM0I7T0FBdEIsQ0FBWixDQURBLENBREo7QUFBQSxLQVBBO0FBV0EsV0FBTyxNQUFQLENBWlk7RUFBQSxDQXZDaEIsQ0FBQTs7QUFBQSxlQXFEQSxVQUFBLEdBQVksU0FBQyxJQUFELEVBQU8sT0FBUCxHQUFBO0FBQ1IsUUFBQSxTQUFBOztNQURlLFVBQVE7S0FDdkI7QUFBQSxJQUFBLFNBQUEsR0FBWSxFQUFBLEdBQUcsT0FBTyxDQUFDLEtBQVgsR0FBaUIsV0FBakIsR0FBNEIsT0FBTyxDQUFDLEtBQXBDLEdBQTBDLE9BQTFDLEdBQWlELElBQUMsQ0FBQSxjQUE5RCxDQUFBO0FBQ0EsSUFBQSxJQUFPLFlBQVA7QUFBa0IsWUFBVSxJQUFBLEtBQUEsQ0FBTSxFQUFBLEdBQUcsU0FBSCxHQUFhLGFBQW5CLENBQVYsQ0FBbEI7S0FEQTtBQUdBLElBQUEsSUFBRyxDQUFDLENBQUMsUUFBRixDQUFXLElBQVgsQ0FBSDtBQUF5QixNQUFBLElBQUEsR0FBTyxDQUFDLENBQUQsRUFBSSxJQUFKLENBQVAsQ0FBekI7S0FIQTtBQUlBLElBQUEsSUFBRyxDQUFBLENBQUssQ0FBQyxPQUFGLENBQVUsSUFBVixDQUFQO0FBQTRCLFlBQVUsSUFBQSxLQUFBLENBQU0sRUFBQSxHQUFHLFNBQUgsR0FBYSxtQkFBbkIsQ0FBVixDQUE1QjtLQUpBO0FBTUEsSUFBQSxJQUFHLElBQUksQ0FBQyxNQUFMLEtBQWUsQ0FBbEI7QUFBeUIsTUFBQSxJQUFJLENBQUMsT0FBTCxDQUFhLENBQWIsQ0FBQSxDQUF6QjtLQU5BO0FBT0EsSUFBQSxJQUFHLElBQUksQ0FBQyxNQUFMLEtBQWlCLENBQXBCO0FBQTJCLFlBQVUsSUFBQSxLQUFBLENBQU0sRUFBQSxHQUFHLFNBQUgsR0FBYSxpQ0FBbkIsQ0FBVixDQUEzQjtLQVBBO0FBUUEsSUFBQSxJQUFHLENBQUEsQ0FBSyxDQUFDLFFBQUYsQ0FBVyxJQUFLLENBQUEsQ0FBQSxDQUFoQixDQUFQO0FBQWdDLFlBQVUsSUFBQSxLQUFBLENBQU0sRUFBQSxHQUFHLFNBQUgsR0FBYSwyQkFBbkIsQ0FBVixDQUFoQztLQVJBO0FBVUEsV0FBVyxJQUFBLElBQUEsQ0FBSztBQUFBLE1BQUEsUUFBQSxFQUFTLElBQUssQ0FBQSxDQUFBLENBQWQ7QUFBQSxNQUFrQixJQUFBLEVBQUssSUFBSyxDQUFBLENBQUEsQ0FBNUI7S0FBTCxDQUFYLENBWFE7RUFBQSxDQXJEWixDQUFBOztZQUFBOztJQWhCSixDQUFBOzs7OztBQ0FBO0FBQUE7Ozs7O0dBQUE7QUFBQSxJQUFBLGlCQUFBO0VBQUE7aVNBQUE7O0FBQUEsU0FPQSxHQUFZLE9BQUEsQ0FBUSxjQUFSLENBUFosQ0FBQTs7QUFBQSxNQVdNLENBQUMsT0FBUCxHQUF1QjtBQUVuQiwyQkFBQSxDQUFBOztBQUFhLEVBQUEsZ0JBQUMsVUFBRCxFQUFnQixPQUFoQixHQUFBOztNQUFDLGFBQVc7S0FDckI7O01BRHlCLFVBQVE7S0FDakM7QUFBQSxJQUFBLHdDQUFNLFVBQU4sRUFBa0IsT0FBbEIsQ0FBQSxDQUFBO0FBQUEsSUFFQSxNQUFNLENBQUMsY0FBUCxDQUFzQixJQUF0QixFQUE0QixNQUE1QixFQUFvQztBQUFBLE1BQUEsR0FBQSxFQUFJLFNBQUEsR0FBQTtlQUFHLElBQUMsQ0FBQSxNQUFPLENBQUEsQ0FBQSxDQUFFLENBQUMsS0FBZDtNQUFBLENBQUo7S0FBcEMsQ0FGQSxDQURTO0VBQUEsQ0FBYjs7Z0JBQUE7O0dBRmtDLFVBWHRDLENBQUE7Ozs7O0FDQUE7QUFBQTs7Ozs7R0FBQTtBQUFBLElBQUEscUJBQUE7RUFBQTtpU0FBQTs7QUFBQSxTQU9BLEdBQVksT0FBQSxDQUFRLGNBQVIsQ0FQWixDQUFBOztBQUFBLE1BV00sQ0FBQyxPQUFQLEdBQXVCO0FBRW5CLCtCQUFBLENBQUE7O0FBQWEsRUFBQSxvQkFBQyxVQUFELEVBQWdCLE9BQWhCLEdBQUE7O01BQUMsYUFBVztLQUNyQjs7TUFEeUIsVUFBUTtLQUNqQztBQUFBLElBQUEsSUFBRyxDQUFDLENBQUMsT0FBRixDQUFVLFVBQVUsQ0FBQyxPQUFyQixDQUFIO0FBQXNDLFlBQVUsSUFBQSxLQUFBLENBQU0seUJBQU4sQ0FBVixDQUF0QztLQUFBO0FBQ0EsSUFBQSxJQUFHLENBQUMsQ0FBQyxPQUFGLENBQVUsVUFBVSxDQUFDLFVBQXJCLENBQUg7QUFBeUMsWUFBVSxJQUFBLEtBQUEsQ0FBTSw0QkFBTixDQUFWLENBQXpDO0tBREE7O01BR0EsVUFBVSxDQUFDLGNBQWU7S0FIMUI7O01BSUEsVUFBVSxDQUFDLFVBQWU7S0FKMUI7QUFBQSxJQUtBLDRDQUFNLFVBQU4sRUFBa0IsT0FBbEIsQ0FMQSxDQURTO0VBQUEsQ0FBYjs7QUFBQSx1QkFVQSxVQUFBLEdBQVksU0FBQyxJQUFELEdBQUE7QUFDUixRQUFBLDhCQUFBO0FBQUEsSUFBQSxNQUFBLEdBQVMsRUFBVCxDQUFBO0FBQ0E7QUFBQSxTQUFBLDJDQUFBO3dCQUFBO0FBQ0ksTUFBQSxJQUFHLE1BQU0sQ0FBQyxJQUFQLEtBQWUsSUFBbEI7QUFDSSxRQUFBLE1BQU0sQ0FBQyxJQUFQLENBQVksTUFBWixDQUFBLENBREo7T0FESjtBQUFBLEtBREE7QUFLQSxXQUFPLE1BQVAsQ0FOUTtFQUFBLENBVlosQ0FBQTs7QUFBQSx1QkFvQkEsUUFBQSxHQUFVLFNBQUEsR0FBQTtBQUNOLFdBQVEsY0FBQSxHQUFjLElBQUMsQ0FBQSxHQUFmLEdBQW1CLGNBQW5CLEdBQ00sSUFBQyxDQUFBLE9BRFAsR0FDZSxlQURmLEdBRVMsSUFBQyxDQUFBLFVBRlYsR0FFcUIsWUFGckIsR0FHTSxJQUFDLENBQUEsT0FBTyxDQUFDLE1BSGYsR0FHc0IsU0FIOUIsQ0FETTtFQUFBLENBcEJWLENBQUE7O29CQUFBOztHQUZzQyxVQVgxQyxDQUFBOzs7OztBQ0FBO0FBQUE7Ozs7O0dBQUE7QUFBQSxJQUFBLFVBQUE7O0FBQUEsRUFPQSxHQUFLLE9BQUEsQ0FBUSw2Q0FBUixDQVBMLENBQUE7O0FBQUEsTUFXQSxHQUFTLElBWFQsQ0FBQTs7QUFBQSxRQWVBLENBQVMscUJBQVQsRUFBZ0MsU0FBQSxHQUFBO0FBRTVCLEVBQUEsTUFBQSxDQUFPLFNBQUEsR0FBQTtXQUFHLE1BQUEsR0FBUyxHQUFBLENBQUEsR0FBWjtFQUFBLENBQVAsQ0FBQSxDQUFBO0FBQUEsRUFFQSxRQUFBLENBQVMsa0JBQVQsRUFBNkIsU0FBQSxHQUFBO0FBRXpCLElBQUEsRUFBQSxDQUFHLHFCQUFILEVBQTBCLFNBQUEsR0FBQTtBQUN0QixVQUFBLElBQUE7QUFBQSxNQUFBLElBQUEsR0FBTztBQUFBLFFBQUEsT0FBQSxFQUFRLENBQVI7QUFBQSxRQUFXLFdBQUEsRUFBWSxLQUF2QjtBQUFBLFFBQThCLE9BQUEsRUFBUSxFQUF0QztPQUFQLENBQUE7YUFDQSxNQUFBLENBQU8sU0FBQSxHQUFBO2VBQUcsTUFBTSxDQUFDLGdCQUFQLENBQXdCLElBQXhCLEVBQUg7TUFBQSxDQUFQLENBQXVDLENBQUMsRUFBRSxDQUFDLE9BQUQsQ0FBMUMsQ0FBaUQsS0FBakQsRUFBd0Qsc0JBQXhELEVBRnNCO0lBQUEsQ0FBMUIsQ0FBQSxDQUFBO0FBQUEsSUFJQSxFQUFBLENBQUcsd0JBQUgsRUFBNkIsU0FBQSxHQUFBO0FBQ3pCLFVBQUEsSUFBQTtBQUFBLE1BQUEsSUFBQSxHQUFPO0FBQUEsUUFBQSxPQUFBLEVBQVEsQ0FBUjtBQUFBLFFBQVcsUUFBQSxFQUFTLE9BQXBCO0FBQUEsUUFBNkIsT0FBQSxFQUFRLEVBQXJDO09BQVAsQ0FBQTthQUNBLE1BQUEsQ0FBTyxTQUFBLEdBQUE7ZUFBRyxNQUFNLENBQUMsZ0JBQVAsQ0FBd0IsSUFBeEIsRUFBSDtNQUFBLENBQVAsQ0FBdUMsQ0FBQyxFQUFFLENBQUMsT0FBRCxDQUExQyxDQUFpRCxLQUFqRCxFQUF3RCx5QkFBeEQsRUFGeUI7SUFBQSxDQUE3QixDQUpBLENBQUE7QUFBQSxJQVFBLEVBQUEsQ0FBRyxnQ0FBSCxFQUFxQyxTQUFBLEdBQUE7QUFDakMsVUFBQSxVQUFBO0FBQUEsTUFBQSxJQUFBLEdBQ0k7QUFBQSxRQUFBLE9BQUEsRUFBUyxDQUFUO0FBQUEsUUFDQSxRQUFBLEVBQVUsT0FEVjtBQUFBLFFBRUEsV0FBQSxFQUFhLEtBRmI7QUFBQSxRQUdBLE9BQUEsRUFBUyxFQUhUO09BREosQ0FBQTtBQUFBLE1BS0EsSUFBQSxHQUFPLE1BQU0sQ0FBQyxnQkFBUCxDQUF3QixJQUF4QixDQUxQLENBQUE7QUFBQSxNQU1BLElBQUksQ0FBQyxPQUFPLENBQUMsTUFBTSxDQUFDLEtBQXBCLENBQTBCLE9BQTFCLENBTkEsQ0FBQTthQU9BLElBQUksQ0FBQyxVQUFVLENBQUMsTUFBTSxDQUFDLEtBQXZCLENBQTZCLEtBQTdCLEVBUmlDO0lBQUEsQ0FBckMsQ0FSQSxDQUFBO1dBa0JBLEVBQUEsQ0FBRyxtQ0FBSCxFQUF3QyxTQUFBLEdBQUE7QUFDcEMsVUFBQSxhQUFBO0FBQUEsTUFBQSxJQUFBLEdBQ0k7QUFBQSxRQUFBLE9BQUEsRUFBUyxDQUFUO0FBQUEsUUFDQSxRQUFBLEVBQVUsV0FEVjtBQUFBLFFBRUEsV0FBQSxFQUFhLFFBRmI7QUFBQSxRQUdBLE9BQUEsRUFBUztVQUNMO0FBQUEsWUFBRSxLQUFBLEVBQU0sWUFBUjtBQUFBLFlBQXNCLE1BQUEsRUFBTyxPQUE3QjtXQURLLEVBRUw7QUFBQSxZQUFFLEtBQUEsRUFBTSxDQUFDLENBQUMsQ0FBRCxFQUFJLE1BQUosQ0FBRCxFQUFjLENBQUMsQ0FBRCxFQUFJLFFBQUosQ0FBZCxDQUFSO0FBQUEsWUFBc0MsS0FBQSxFQUFNLGdCQUE1QztBQUFBLFlBQThELE1BQUEsRUFBTyxLQUFyRTtXQUZLO1NBSFQ7T0FESixDQUFBO0FBQUEsTUFRQSxJQUFBLEdBQU8sTUFBTSxDQUFDLGdCQUFQLENBQXdCLElBQXhCLENBUlAsQ0FBQTtBQUFBLE1BU0EsSUFBSSxDQUFDLE9BQU8sQ0FBQyxNQUFNLENBQUMsS0FBcEIsQ0FBMEIsV0FBMUIsQ0FUQSxDQUFBO0FBQUEsTUFVQSxJQUFJLENBQUMsVUFBVSxDQUFDLE1BQU0sQ0FBQyxLQUF2QixDQUE2QixRQUE3QixDQVZBLENBQUE7YUFXQTs7QUFBQztBQUFBO2FBQUEsMkNBQUE7dUJBQUE7QUFBQSx3QkFBQSxDQUFDLENBQUMsS0FBRixDQUFBO0FBQUE7O1VBQUQsQ0FBOEIsQ0FBQyxJQUEvQixDQUFBLENBQXFDLENBQUMsTUFBTSxDQUFDLEdBQTdDLENBQWlELENBQUMsS0FBRCxFQUFRLE9BQVIsQ0FBakQsRUFab0M7SUFBQSxDQUF4QyxFQXBCeUI7RUFBQSxDQUE3QixDQUZBLENBQUE7QUFBQSxFQW9DQSxRQUFBLENBQVMsY0FBVCxFQUF5QixTQUFBLEdBQUE7QUFFckIsSUFBQSxFQUFBLENBQUcsK0JBQUgsRUFBb0MsU0FBQSxHQUFBO0FBQ2hDLE1BQUEsTUFBTSxDQUFDLGNBQVAsR0FBd0IsTUFBeEIsQ0FBQTthQUNBLE1BQUEsQ0FBTyxTQUFBLEdBQUE7ZUFBRyxNQUFNLENBQUMsWUFBUCxDQUFvQjtBQUFBLFVBQUEsS0FBQSxFQUFNLE1BQU47U0FBcEIsRUFBSDtNQUFBLENBQVAsQ0FBMkMsQ0FBQyxFQUFFLENBQUMsT0FBRCxDQUE5QyxDQUFxRCxLQUFyRCxFQUE0RCx3QkFBNUQsRUFGZ0M7SUFBQSxDQUFwQyxDQUFBLENBQUE7QUFBQSxJQUlBLEVBQUEsQ0FBRyw4QkFBSCxFQUFtQyxTQUFBLEdBQUE7QUFDL0IsTUFBQSxNQUFNLENBQUMsY0FBUCxHQUF3QixNQUF4QixDQUFBO2FBQ0EsTUFBQSxDQUFPLFNBQUEsR0FBQTtlQUFHLE1BQU0sQ0FBQyxZQUFQLENBQW9CO0FBQUEsVUFBQSxNQUFBLEVBQU8sTUFBUDtTQUFwQixFQUFIO01BQUEsQ0FBUCxDQUE0QyxDQUFDLEVBQUUsQ0FBQyxPQUFELENBQS9DLENBQXNELEtBQXRELEVBQTZELHVCQUE3RCxFQUYrQjtJQUFBLENBQW5DLENBSkEsQ0FBQTtBQUFBLElBUUEsRUFBQSxDQUFHLDRCQUFILEVBQWlDLFNBQUEsR0FBQTtBQUM3QixVQUFBLGVBQUE7QUFBQSxNQUFBLElBQUEsR0FDSTtBQUFBLFFBQUEsTUFBQSxFQUFRLEtBQVI7QUFBQSxRQUNBLEtBQUEsRUFBTyxDQUFDLENBQUMsQ0FBRCxFQUFJLFFBQUosQ0FBRCxFQUFnQixDQUFDLENBQUQsRUFBSSxNQUFKLENBQWhCLENBRFA7QUFBQSxRQUVBLEtBQUEsRUFBTyxnQkFGUDtPQURKLENBQUE7QUFBQSxNQUlBLE1BQUEsR0FBUyxNQUFNLENBQUMsWUFBUCxDQUFvQixJQUFwQixDQUpULENBQUE7QUFBQSxNQUtBOztBQUFDO0FBQUE7YUFBQSwyQ0FBQTt1QkFBQTtBQUFBLHdCQUFBLENBQUMsQ0FBQyxLQUFGLENBQUE7QUFBQTs7VUFBRCxDQUErQixDQUFDLE1BQU0sQ0FBQyxHQUF2QyxDQUEyQyxDQUFDLEtBQUQsQ0FBM0MsQ0FMQSxDQUFBO0FBQUEsTUFNQTs7QUFBQztBQUFBO2FBQUEsMkNBQUE7dUJBQUE7QUFBQSx3QkFBQSxDQUFDLENBQUMsS0FBRixDQUFBO0FBQUE7O1VBQUQsQ0FBOEIsQ0FBQyxJQUEvQixDQUFBLENBQXFDLENBQUMsTUFBTSxDQUFDLEdBQTdDLENBQWlELENBQUMsUUFBRCxFQUFXLE1BQVgsQ0FBakQsQ0FOQSxDQUFBO2FBT0E7O0FBQUM7QUFBQTthQUFBLDJDQUFBO3VCQUFBO0FBQUEsd0JBQUEsQ0FBQyxDQUFDLEtBQUYsQ0FBQTtBQUFBOztVQUFELENBQThCLENBQUMsTUFBTSxDQUFDLEdBQXRDLENBQTBDLENBQUMsZ0JBQUQsQ0FBMUMsRUFSNkI7SUFBQSxDQUFqQyxDQVJBLENBQUE7V0FrQkEsRUFBQSxDQUFHLGtDQUFILEVBQXVDLFNBQUEsR0FBQTtBQUNuQyxVQUFBLFNBQUE7QUFBQSxNQUFBLE1BQUEsR0FBUyxNQUFNLENBQUMsWUFBUCxDQUFvQjtBQUFBLFFBQUEsTUFBQSxFQUFPLE9BQVA7QUFBQSxRQUFnQixLQUFBLEVBQU0sWUFBdEI7T0FBcEIsQ0FBVCxDQUFBO0FBQUEsTUFDQTs7QUFBQztBQUFBO2FBQUEsMkNBQUE7dUJBQUE7QUFBQSx3QkFBQSxDQUFDLENBQUMsS0FBRixDQUFBO0FBQUE7O1VBQUQsQ0FBK0IsQ0FBQyxNQUFNLENBQUMsR0FBdkMsQ0FBMkMsQ0FBQyxPQUFELENBQTNDLENBREEsQ0FBQTtBQUFBLE1BRUE7O0FBQUM7QUFBQTthQUFBLDJDQUFBO3VCQUFBO0FBQUEsd0JBQUEsQ0FBQyxDQUFDLEtBQUYsQ0FBQTtBQUFBOztVQUFELENBQThCLENBQUMsSUFBL0IsQ0FBQSxDQUFxQyxDQUFDLE1BQU0sQ0FBQyxHQUE3QyxDQUFpRCxDQUFDLFlBQUQsQ0FBakQsQ0FGQSxDQUFBO2FBR0E7O0FBQUM7QUFBQTthQUFBLDJDQUFBO3VCQUFBO0FBQUEsd0JBQUEsQ0FBQyxDQUFDLEtBQUYsQ0FBQTtBQUFBOztVQUFELENBQThCLENBQUMsTUFBTSxDQUFDLEdBQXRDLENBQTBDLEVBQTFDLEVBSm1DO0lBQUEsQ0FBdkMsRUFwQnFCO0VBQUEsQ0FBekIsQ0FwQ0EsQ0FBQTtBQUFBLEVBOERBLFFBQUEsQ0FBUyxnQkFBVCxFQUEyQixTQUFBLEdBQUE7QUFFdkIsSUFBQSxFQUFBLENBQUcscUNBQUgsRUFBMEMsU0FBQSxHQUFBO0FBQ3RDLFVBQUEsT0FBQTtBQUFBLE1BQUEsSUFBQSxHQUFPLE1BQU0sQ0FBQyxjQUFQLENBQXNCLE1BQXRCLENBQVAsQ0FBQTthQUNBOztBQUFDO2FBQUEsMkNBQUE7dUJBQUE7QUFBQSx3QkFBQSxDQUFDLENBQUMsS0FBRixDQUFBO0FBQUE7O1VBQUQsQ0FBc0IsQ0FBQyxNQUFNLENBQUMsR0FBOUIsQ0FBa0MsQ0FBQyxNQUFELENBQWxDLEVBRnNDO0lBQUEsQ0FBMUMsQ0FBQSxDQUFBO0FBQUEsSUFJQSxFQUFBLENBQUcsb0NBQUgsRUFBeUMsU0FBQSxHQUFBO0FBQ3JDLFVBQUEsT0FBQTtBQUFBLE1BQUEsTUFBTSxDQUFDLGNBQVAsR0FBd0IsTUFBeEIsQ0FBQTtBQUFBLE1BQ0EsT0FBQSxHQUFVO0FBQUEsUUFBQSxLQUFBLEVBQU0sUUFBTjtBQUFBLFFBQWdCLFVBQUEsRUFBVyxLQUEzQjtPQURWLENBQUE7YUFFQSxNQUFBLENBQU8sU0FBQSxHQUFBO2VBQUcsTUFBTSxDQUFDLGNBQVAsQ0FBc0IsRUFBdEIsRUFBMEIsT0FBMUIsRUFBSDtNQUFBLENBQVAsQ0FBNEMsQ0FBQyxFQUFFLENBQUMsT0FBRCxDQUEvQyxDQUFzRCxLQUF0RCxFQUE2RCxpQ0FBN0QsRUFIcUM7SUFBQSxDQUF6QyxDQUpBLENBQUE7QUFBQSxJQVNBLEVBQUEsQ0FBRyx5QkFBSCxFQUE4QixTQUFBLEdBQUE7QUFDMUIsVUFBQSxJQUFBO0FBQUEsTUFBQSxJQUFBLEdBQU8sTUFBTSxDQUFDLGNBQVAsQ0FBc0IsRUFBdEIsRUFBMEI7QUFBQSxRQUFBLFVBQUEsRUFBVyxJQUFYO09BQTFCLENBQVAsQ0FBQTthQUNBLElBQUksQ0FBQyxNQUFNLENBQUMsTUFBTSxDQUFDLEtBQW5CLENBQXlCLENBQXpCLEVBRjBCO0lBQUEsQ0FBOUIsQ0FUQSxDQUFBO1dBYUEsRUFBQSxDQUFHLDRCQUFILEVBQWlDLFNBQUEsR0FBQTtBQUM3QixVQUFBLE9BQUE7QUFBQSxNQUFBLElBQUEsR0FBTyxNQUFNLENBQUMsY0FBUCxDQUFzQixDQUFDLENBQUMsQ0FBRCxFQUFJLE9BQUosQ0FBRCxFQUFlLENBQUMsQ0FBRCxFQUFJLE1BQUosQ0FBZixDQUF0QixDQUFQLENBQUE7YUFDQTs7QUFBQzthQUFBLDJDQUFBO3VCQUFBO0FBQUEsd0JBQUEsQ0FBQyxDQUFDLEtBQUYsQ0FBQTtBQUFBOztVQUFELENBQXNCLENBQUMsSUFBdkIsQ0FBQSxDQUE2QixDQUFDLE1BQU0sQ0FBQyxHQUFyQyxDQUF5QyxDQUFDLE9BQUQsRUFBVSxNQUFWLENBQXpDLEVBRjZCO0lBQUEsQ0FBakMsRUFmdUI7RUFBQSxDQUEzQixDQTlEQSxDQUFBO1NBaUZBLFFBQUEsQ0FBUyxZQUFULEVBQXVCLFNBQUEsR0FBQTtBQUVuQixJQUFBLEVBQUEsQ0FBRyxpREFBSCxFQUFzRCxTQUFBLEdBQUE7QUFDbEQsVUFBQSxPQUFBO0FBQUEsTUFBQSxNQUFNLENBQUMsY0FBUCxHQUF3QixNQUF4QixDQUFBO0FBQUEsTUFDQSxPQUFBLEdBQVU7QUFBQSxRQUFBLEtBQUEsRUFBTSxDQUFOO0FBQUEsUUFBUyxLQUFBLEVBQU0sUUFBZjtPQURWLENBQUE7YUFFQSxNQUFBLENBQU8sU0FBQSxHQUFBO2VBQUcsTUFBTSxDQUFDLFVBQVAsQ0FBa0IsRUFBbEIsRUFBc0IsT0FBdEIsRUFBSDtNQUFBLENBQVAsQ0FBeUMsQ0FBQyxFQUFFLENBQUMsT0FBRCxDQUE1QyxDQUFtRCxLQUFuRCxFQUNJLDBEQURKLEVBSGtEO0lBQUEsQ0FBdEQsQ0FBQSxDQUFBO0FBQUEsSUFNQSxFQUFBLENBQUcsOEJBQUgsRUFBbUMsU0FBQSxHQUFBO0FBQy9CLFVBQUEsV0FBQTtBQUFBLE1BQUEsSUFBQSxHQUFPLE1BQU0sQ0FBQyxVQUFQLENBQWtCLE1BQWxCLENBQVAsQ0FBQTtBQUFBLE1BQ0EsSUFBSSxDQUFDLElBQUksQ0FBQyxNQUFNLENBQUMsS0FBakIsQ0FBdUIsTUFBdkIsQ0FEQSxDQUFBO0FBQUEsTUFFQSxJQUFJLENBQUMsUUFBUSxDQUFDLE1BQU0sQ0FBQyxLQUFyQixDQUEyQixDQUEzQixDQUZBLENBQUE7QUFBQSxNQUlBLEtBQUEsR0FBUSxNQUFNLENBQUMsVUFBUCxDQUFrQixDQUFDLE1BQUQsQ0FBbEIsQ0FKUixDQUFBO0FBQUEsTUFLQSxLQUFLLENBQUMsSUFBSSxDQUFDLE1BQU0sQ0FBQyxLQUFsQixDQUF3QixNQUF4QixDQUxBLENBQUE7YUFNQSxLQUFLLENBQUMsUUFBUSxDQUFDLE1BQU0sQ0FBQyxLQUF0QixDQUE0QixDQUE1QixFQVArQjtJQUFBLENBQW5DLENBTkEsQ0FBQTtBQUFBLElBZUEsRUFBQSxDQUFHLDBDQUFILEVBQStDLFNBQUEsR0FBQTtBQUMzQyxVQUFBLE9BQUE7QUFBQSxNQUFBLE1BQU0sQ0FBQyxjQUFQLEdBQXdCLE1BQXhCLENBQUE7QUFBQSxNQUNBLE9BQUEsR0FBVTtBQUFBLFFBQUEsS0FBQSxFQUFNLENBQU47QUFBQSxRQUFTLEtBQUEsRUFBTSxRQUFmO09BRFYsQ0FBQTthQUVBLE1BQUEsQ0FBTyxTQUFBLEdBQUE7ZUFBRyxNQUFNLENBQUMsVUFBUCxDQUFrQixDQUFDLEdBQUQsRUFBTSxNQUFOLENBQWxCLEVBQWlDLE9BQWpDLEVBQUg7TUFBQSxDQUFQLENBQW9ELENBQUMsRUFBRSxDQUFDLE9BQUQsQ0FBdkQsQ0FBOEQsS0FBOUQsRUFDSSxvREFESixFQUgyQztJQUFBLENBQS9DLENBZkEsQ0FBQTtXQXFCQSxFQUFBLENBQUcsd0JBQUgsRUFBNkIsU0FBQSxHQUFBO0FBQ3pCLFVBQUEsSUFBQTtBQUFBLE1BQUEsSUFBQSxHQUFPLE1BQU0sQ0FBQyxVQUFQLENBQWtCLENBQUMsQ0FBRCxFQUFJLE1BQUosQ0FBbEIsQ0FBUCxDQUFBO2FBQ0EsSUFBSSxDQUFDLFdBQVcsQ0FBQyxJQUFJLENBQUMsTUFBTSxDQUFDLEtBQTdCLENBQW1DLE1BQW5DLEVBRnlCO0lBQUEsQ0FBN0IsRUF2Qm1CO0VBQUEsQ0FBdkIsRUFuRjRCO0FBQUEsQ0FBaEMsQ0FmQSxDQUFBOzs7OztBQ0FBO0FBQUE7Ozs7O0dBQUE7QUFBQSxJQVNJLENBQUMsR0FBTCxDQUFTLE9BQUEsQ0FBUSxZQUFSLENBQVQsQ0FUQSxDQUFBOztBQUFBLElBVUksQ0FBQyxNQUFNLENBQUMsWUFBWixHQUEyQixJQVYzQixDQUFBOztBQVlBLElBQUcsTUFBQSxDQUFBLE1BQUEsS0FBa0IsV0FBckI7QUFDSSxFQUFBLE1BQU0sQ0FBQyxNQUFQLEdBQWdCLE1BQWhCLENBREo7Q0FaQTs7QUFBQSxNQWVNLENBQUMsTUFBUCxHQUFnQixJQUFJLENBQUMsTUFmckIsQ0FBQTs7QUFBQSxNQWdCTSxDQUFDLE1BQVAsR0FBZ0IsSUFBSSxDQUFDLE1BaEJyQixDQUFBOztBQUFBLE1BaUJNLENBQUMsTUFBUCxHQUFnQixJQUFJLENBQUMsTUFBTCxDQUFBLENBakJoQixDQUFBOztBQUFBLEtBcUJLLENBQUMsS0FBTixDQUFZLEtBQVosQ0FyQkEsQ0FBQTs7QUFBQSxPQXVCQSxDQUFRLDJCQUFSLENBdkJBLENBQUE7O0FBQUEsS0F5QkssQ0FBQyxVQUFOLENBQUEsQ0F6QkEsQ0FBQTs7QUFBQSxLQTBCSyxDQUFDLEdBQU4sQ0FBQSxDQTFCQSxDQUFBIiwiZmlsZSI6ImdlbmVyYXRlZC5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzQ29udGVudCI6WyIoZnVuY3Rpb24gZSh0LG4scil7ZnVuY3Rpb24gcyhvLHUpe2lmKCFuW29dKXtpZighdFtvXSl7dmFyIGE9dHlwZW9mIHJlcXVpcmU9PVwiZnVuY3Rpb25cIiYmcmVxdWlyZTtpZighdSYmYSlyZXR1cm4gYShvLCEwKTtpZihpKXJldHVybiBpKG8sITApO3ZhciBmPW5ldyBFcnJvcihcIkNhbm5vdCBmaW5kIG1vZHVsZSAnXCIrbytcIidcIik7dGhyb3cgZi5jb2RlPVwiTU9EVUxFX05PVF9GT1VORFwiLGZ9dmFyIGw9bltvXT17ZXhwb3J0czp7fX07dFtvXVswXS5jYWxsKGwuZXhwb3J0cyxmdW5jdGlvbihlKXt2YXIgbj10W29dWzFdW2VdO3JldHVybiBzKG4/bjplKX0sbCxsLmV4cG9ydHMsZSx0LG4scil9cmV0dXJuIG5bb10uZXhwb3J0c312YXIgaT10eXBlb2YgcmVxdWlyZT09XCJmdW5jdGlvblwiJiZyZXF1aXJlO2Zvcih2YXIgbz0wO288ci5sZW5ndGg7bysrKXMocltvXSk7cmV0dXJuIHN9KSIsIihmdW5jdGlvbiAoc2lub25DaGFpKSB7XG4gICAgXCJ1c2Ugc3RyaWN0XCI7XG5cbiAgICAvLyBNb2R1bGUgc3lzdGVtcyBtYWdpYyBkYW5jZS5cblxuICAgIC8qIGlzdGFuYnVsIGlnbm9yZSBlbHNlICovXG4gICAgaWYgKHR5cGVvZiByZXF1aXJlID09PSBcImZ1bmN0aW9uXCIgJiYgdHlwZW9mIGV4cG9ydHMgPT09IFwib2JqZWN0XCIgJiYgdHlwZW9mIG1vZHVsZSA9PT0gXCJvYmplY3RcIikge1xuICAgICAgICAvLyBOb2RlSlNcbiAgICAgICAgbW9kdWxlLmV4cG9ydHMgPSBzaW5vbkNoYWk7XG4gICAgfSBlbHNlIGlmICh0eXBlb2YgZGVmaW5lID09PSBcImZ1bmN0aW9uXCIgJiYgZGVmaW5lLmFtZCkge1xuICAgICAgICAvLyBBTURcbiAgICAgICAgZGVmaW5lKGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICAgIHJldHVybiBzaW5vbkNoYWk7XG4gICAgICAgIH0pO1xuICAgIH0gZWxzZSB7XG4gICAgICAgIC8vIE90aGVyIGVudmlyb25tZW50ICh1c3VhbGx5IDxzY3JpcHQ+IHRhZyk6IHBsdWcgaW4gdG8gZ2xvYmFsIGNoYWkgaW5zdGFuY2UgZGlyZWN0bHkuXG4gICAgICAgIGNoYWkudXNlKHNpbm9uQ2hhaSk7XG4gICAgfVxufShmdW5jdGlvbiBzaW5vbkNoYWkoY2hhaSwgdXRpbHMpIHtcbiAgICBcInVzZSBzdHJpY3RcIjtcblxuICAgIHZhciBzbGljZSA9IEFycmF5LnByb3RvdHlwZS5zbGljZTtcblxuICAgIGZ1bmN0aW9uIGlzU3B5KHB1dGF0aXZlU3B5KSB7XG4gICAgICAgIHJldHVybiB0eXBlb2YgcHV0YXRpdmVTcHkgPT09IFwiZnVuY3Rpb25cIiAmJlxuICAgICAgICAgICAgICAgdHlwZW9mIHB1dGF0aXZlU3B5LmdldENhbGwgPT09IFwiZnVuY3Rpb25cIiAmJlxuICAgICAgICAgICAgICAgdHlwZW9mIHB1dGF0aXZlU3B5LmNhbGxlZFdpdGhFeGFjdGx5ID09PSBcImZ1bmN0aW9uXCI7XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gdGltZXNJbldvcmRzKGNvdW50KSB7XG4gICAgICAgIHJldHVybiBjb3VudCA9PT0gMSA/IFwib25jZVwiIDpcbiAgICAgICAgICAgICAgIGNvdW50ID09PSAyID8gXCJ0d2ljZVwiIDpcbiAgICAgICAgICAgICAgIGNvdW50ID09PSAzID8gXCJ0aHJpY2VcIiA6XG4gICAgICAgICAgICAgICAoY291bnQgfHwgMCkgKyBcIiB0aW1lc1wiO1xuICAgIH1cblxuICAgIGZ1bmN0aW9uIGlzQ2FsbChwdXRhdGl2ZUNhbGwpIHtcbiAgICAgICAgcmV0dXJuIHB1dGF0aXZlQ2FsbCAmJiBpc1NweShwdXRhdGl2ZUNhbGwucHJveHkpO1xuICAgIH1cblxuICAgIGZ1bmN0aW9uIGFzc2VydENhbldvcmtXaXRoKGFzc2VydGlvbikge1xuICAgICAgICBpZiAoIWlzU3B5KGFzc2VydGlvbi5fb2JqKSAmJiAhaXNDYWxsKGFzc2VydGlvbi5fb2JqKSkge1xuICAgICAgICAgICAgdGhyb3cgbmV3IFR5cGVFcnJvcih1dGlscy5pbnNwZWN0KGFzc2VydGlvbi5fb2JqKSArIFwiIGlzIG5vdCBhIHNweSBvciBhIGNhbGwgdG8gYSBzcHkhXCIpO1xuICAgICAgICB9XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gZ2V0TWVzc2FnZXMoc3B5LCBhY3Rpb24sIG5vbk5lZ2F0ZWRTdWZmaXgsIGFsd2F5cywgYXJncykge1xuICAgICAgICB2YXIgdmVyYlBocmFzZSA9IGFsd2F5cyA/IFwiYWx3YXlzIGhhdmUgXCIgOiBcImhhdmUgXCI7XG4gICAgICAgIG5vbk5lZ2F0ZWRTdWZmaXggPSBub25OZWdhdGVkU3VmZml4IHx8IFwiXCI7XG4gICAgICAgIGlmIChpc1NweShzcHkucHJveHkpKSB7XG4gICAgICAgICAgICBzcHkgPSBzcHkucHJveHk7XG4gICAgICAgIH1cblxuICAgICAgICBmdW5jdGlvbiBwcmludGZBcnJheShhcnJheSkge1xuICAgICAgICAgICAgcmV0dXJuIHNweS5wcmludGYuYXBwbHkoc3B5LCBhcnJheSk7XG4gICAgICAgIH1cblxuICAgICAgICByZXR1cm4ge1xuICAgICAgICAgICAgYWZmaXJtYXRpdmU6IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgICAgICAgICByZXR1cm4gcHJpbnRmQXJyYXkoW1wiZXhwZWN0ZWQgJW4gdG8gXCIgKyB2ZXJiUGhyYXNlICsgYWN0aW9uICsgbm9uTmVnYXRlZFN1ZmZpeF0uY29uY2F0KGFyZ3MpKTtcbiAgICAgICAgICAgIH0sXG4gICAgICAgICAgICBuZWdhdGl2ZTogZnVuY3Rpb24gKCkge1xuICAgICAgICAgICAgICAgIHJldHVybiBwcmludGZBcnJheShbXCJleHBlY3RlZCAlbiB0byBub3QgXCIgKyB2ZXJiUGhyYXNlICsgYWN0aW9uXS5jb25jYXQoYXJncykpO1xuICAgICAgICAgICAgfVxuICAgICAgICB9O1xuICAgIH1cblxuICAgIGZ1bmN0aW9uIHNpbm9uUHJvcGVydHkobmFtZSwgYWN0aW9uLCBub25OZWdhdGVkU3VmZml4KSB7XG4gICAgICAgIHV0aWxzLmFkZFByb3BlcnR5KGNoYWkuQXNzZXJ0aW9uLnByb3RvdHlwZSwgbmFtZSwgZnVuY3Rpb24gKCkge1xuICAgICAgICAgICAgYXNzZXJ0Q2FuV29ya1dpdGgodGhpcyk7XG5cbiAgICAgICAgICAgIHZhciBtZXNzYWdlcyA9IGdldE1lc3NhZ2VzKHRoaXMuX29iaiwgYWN0aW9uLCBub25OZWdhdGVkU3VmZml4LCBmYWxzZSk7XG4gICAgICAgICAgICB0aGlzLmFzc2VydCh0aGlzLl9vYmpbbmFtZV0sIG1lc3NhZ2VzLmFmZmlybWF0aXZlLCBtZXNzYWdlcy5uZWdhdGl2ZSk7XG4gICAgICAgIH0pO1xuICAgIH1cblxuICAgIGZ1bmN0aW9uIHNpbm9uUHJvcGVydHlBc0Jvb2xlYW5NZXRob2QobmFtZSwgYWN0aW9uLCBub25OZWdhdGVkU3VmZml4KSB7XG4gICAgICAgIHV0aWxzLmFkZE1ldGhvZChjaGFpLkFzc2VydGlvbi5wcm90b3R5cGUsIG5hbWUsIGZ1bmN0aW9uIChhcmcpIHtcbiAgICAgICAgICAgIGFzc2VydENhbldvcmtXaXRoKHRoaXMpO1xuXG4gICAgICAgICAgICB2YXIgbWVzc2FnZXMgPSBnZXRNZXNzYWdlcyh0aGlzLl9vYmosIGFjdGlvbiwgbm9uTmVnYXRlZFN1ZmZpeCwgZmFsc2UsIFt0aW1lc0luV29yZHMoYXJnKV0pO1xuICAgICAgICAgICAgdGhpcy5hc3NlcnQodGhpcy5fb2JqW25hbWVdID09PSBhcmcsIG1lc3NhZ2VzLmFmZmlybWF0aXZlLCBtZXNzYWdlcy5uZWdhdGl2ZSk7XG4gICAgICAgIH0pO1xuICAgIH1cblxuICAgIGZ1bmN0aW9uIGNyZWF0ZVNpbm9uTWV0aG9kSGFuZGxlcihzaW5vbk5hbWUsIGFjdGlvbiwgbm9uTmVnYXRlZFN1ZmZpeCkge1xuICAgICAgICByZXR1cm4gZnVuY3Rpb24gKCkge1xuICAgICAgICAgICAgYXNzZXJ0Q2FuV29ya1dpdGgodGhpcyk7XG5cbiAgICAgICAgICAgIHZhciBhbHdheXNTaW5vbk1ldGhvZCA9IFwiYWx3YXlzXCIgKyBzaW5vbk5hbWVbMF0udG9VcHBlckNhc2UoKSArIHNpbm9uTmFtZS5zdWJzdHJpbmcoMSk7XG4gICAgICAgICAgICB2YXIgc2hvdWxkQmVBbHdheXMgPSB1dGlscy5mbGFnKHRoaXMsIFwiYWx3YXlzXCIpICYmIHR5cGVvZiB0aGlzLl9vYmpbYWx3YXlzU2lub25NZXRob2RdID09PSBcImZ1bmN0aW9uXCI7XG4gICAgICAgICAgICB2YXIgc2lub25NZXRob2QgPSBzaG91bGRCZUFsd2F5cyA/IGFsd2F5c1Npbm9uTWV0aG9kIDogc2lub25OYW1lO1xuXG4gICAgICAgICAgICB2YXIgbWVzc2FnZXMgPSBnZXRNZXNzYWdlcyh0aGlzLl9vYmosIGFjdGlvbiwgbm9uTmVnYXRlZFN1ZmZpeCwgc2hvdWxkQmVBbHdheXMsIHNsaWNlLmNhbGwoYXJndW1lbnRzKSk7XG4gICAgICAgICAgICB0aGlzLmFzc2VydCh0aGlzLl9vYmpbc2lub25NZXRob2RdLmFwcGx5KHRoaXMuX29iaiwgYXJndW1lbnRzKSwgbWVzc2FnZXMuYWZmaXJtYXRpdmUsIG1lc3NhZ2VzLm5lZ2F0aXZlKTtcbiAgICAgICAgfTtcbiAgICB9XG5cbiAgICBmdW5jdGlvbiBzaW5vbk1ldGhvZEFzUHJvcGVydHkobmFtZSwgYWN0aW9uLCBub25OZWdhdGVkU3VmZml4KSB7XG4gICAgICAgIHZhciBoYW5kbGVyID0gY3JlYXRlU2lub25NZXRob2RIYW5kbGVyKG5hbWUsIGFjdGlvbiwgbm9uTmVnYXRlZFN1ZmZpeCk7XG4gICAgICAgIHV0aWxzLmFkZFByb3BlcnR5KGNoYWkuQXNzZXJ0aW9uLnByb3RvdHlwZSwgbmFtZSwgaGFuZGxlcik7XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gZXhjZXB0aW9uYWxTaW5vbk1ldGhvZChjaGFpTmFtZSwgc2lub25OYW1lLCBhY3Rpb24sIG5vbk5lZ2F0ZWRTdWZmaXgpIHtcbiAgICAgICAgdmFyIGhhbmRsZXIgPSBjcmVhdGVTaW5vbk1ldGhvZEhhbmRsZXIoc2lub25OYW1lLCBhY3Rpb24sIG5vbk5lZ2F0ZWRTdWZmaXgpO1xuICAgICAgICB1dGlscy5hZGRNZXRob2QoY2hhaS5Bc3NlcnRpb24ucHJvdG90eXBlLCBjaGFpTmFtZSwgaGFuZGxlcik7XG4gICAgfVxuXG4gICAgZnVuY3Rpb24gc2lub25NZXRob2QobmFtZSwgYWN0aW9uLCBub25OZWdhdGVkU3VmZml4KSB7XG4gICAgICAgIGV4Y2VwdGlvbmFsU2lub25NZXRob2QobmFtZSwgbmFtZSwgYWN0aW9uLCBub25OZWdhdGVkU3VmZml4KTtcbiAgICB9XG5cbiAgICB1dGlscy5hZGRQcm9wZXJ0eShjaGFpLkFzc2VydGlvbi5wcm90b3R5cGUsIFwiYWx3YXlzXCIsIGZ1bmN0aW9uICgpIHtcbiAgICAgICAgdXRpbHMuZmxhZyh0aGlzLCBcImFsd2F5c1wiLCB0cnVlKTtcbiAgICB9KTtcblxuICAgIHNpbm9uUHJvcGVydHkoXCJjYWxsZWRcIiwgXCJiZWVuIGNhbGxlZFwiLCBcIiBhdCBsZWFzdCBvbmNlLCBidXQgaXQgd2FzIG5ldmVyIGNhbGxlZFwiKTtcbiAgICBzaW5vblByb3BlcnR5QXNCb29sZWFuTWV0aG9kKFwiY2FsbENvdW50XCIsIFwiYmVlbiBjYWxsZWQgZXhhY3RseSAlMVwiLCBcIiwgYnV0IGl0IHdhcyBjYWxsZWQgJWMlQ1wiKTtcbiAgICBzaW5vblByb3BlcnR5KFwiY2FsbGVkT25jZVwiLCBcImJlZW4gY2FsbGVkIGV4YWN0bHkgb25jZVwiLCBcIiwgYnV0IGl0IHdhcyBjYWxsZWQgJWMlQ1wiKTtcbiAgICBzaW5vblByb3BlcnR5KFwiY2FsbGVkVHdpY2VcIiwgXCJiZWVuIGNhbGxlZCBleGFjdGx5IHR3aWNlXCIsIFwiLCBidXQgaXQgd2FzIGNhbGxlZCAlYyVDXCIpO1xuICAgIHNpbm9uUHJvcGVydHkoXCJjYWxsZWRUaHJpY2VcIiwgXCJiZWVuIGNhbGxlZCBleGFjdGx5IHRocmljZVwiLCBcIiwgYnV0IGl0IHdhcyBjYWxsZWQgJWMlQ1wiKTtcbiAgICBzaW5vbk1ldGhvZEFzUHJvcGVydHkoXCJjYWxsZWRXaXRoTmV3XCIsIFwiYmVlbiBjYWxsZWQgd2l0aCBuZXdcIik7XG4gICAgc2lub25NZXRob2QoXCJjYWxsZWRCZWZvcmVcIiwgXCJiZWVuIGNhbGxlZCBiZWZvcmUgJTFcIik7XG4gICAgc2lub25NZXRob2QoXCJjYWxsZWRBZnRlclwiLCBcImJlZW4gY2FsbGVkIGFmdGVyICUxXCIpO1xuICAgIHNpbm9uTWV0aG9kKFwiY2FsbGVkT25cIiwgXCJiZWVuIGNhbGxlZCB3aXRoICUxIGFzIHRoaXNcIiwgXCIsIGJ1dCBpdCB3YXMgY2FsbGVkIHdpdGggJXQgaW5zdGVhZFwiKTtcbiAgICBzaW5vbk1ldGhvZChcImNhbGxlZFdpdGhcIiwgXCJiZWVuIGNhbGxlZCB3aXRoIGFyZ3VtZW50cyAlKlwiLCBcIiVDXCIpO1xuICAgIHNpbm9uTWV0aG9kKFwiY2FsbGVkV2l0aEV4YWN0bHlcIiwgXCJiZWVuIGNhbGxlZCB3aXRoIGV4YWN0IGFyZ3VtZW50cyAlKlwiLCBcIiVDXCIpO1xuICAgIHNpbm9uTWV0aG9kKFwiY2FsbGVkV2l0aE1hdGNoXCIsIFwiYmVlbiBjYWxsZWQgd2l0aCBhcmd1bWVudHMgbWF0Y2hpbmcgJSpcIiwgXCIlQ1wiKTtcbiAgICBzaW5vbk1ldGhvZChcInJldHVybmVkXCIsIFwicmV0dXJuZWQgJTFcIik7XG4gICAgZXhjZXB0aW9uYWxTaW5vbk1ldGhvZChcInRocm93blwiLCBcInRocmV3XCIsIFwidGhyb3duICUxXCIpO1xufSkpO1xuIiwiIyMjXG4jIGNyYWZ0aW5nX2d1aWRlIC0gYmFzZV9tb2RlbC5jb2ZmZWVcbiNcbiMgQ29weXJpZ2h0IChjKSAyMDE0IGJ5IFJlZHdvb2QgTGFic1xuIyBBbGwgcmlnaHRzIHJlc2VydmVkLlxuIyMjXG5cbiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xuXG5tb2R1bGUuZXhwb3J0cyA9IGNsYXNzIEJhc2VNb2RlbCBleHRlbmRzIEJhY2tib25lLk1vZGVsXG5cbiAgICBjb25zdHJ1Y3RvcjogKGF0dHJpYnV0ZXM9e30sIG9wdGlvbnM9e30pLT5cbiAgICAgICAgc3VwZXIgYXR0cmlidXRlcywgb3B0aW9uc1xuXG4gICAgICAgIG1ha2VHZXR0ZXIgPSAobmFtZSktPiByZXR1cm4gLT4gQGdldCBuYW1lXG4gICAgICAgIG1ha2VTZXR0ZXIgPSAobmFtZSktPiByZXR1cm4gKHZhbHVlKS0+IEBzZXQgbmFtZSwgdmFsdWVcbiAgICAgICAgZm9yIG5hbWUgaW4gXy5rZXlzIGF0dHJpYnV0ZXNcbiAgICAgICAgICAgIGNvbnRpbnVlIGlmIG5hbWUgaXMgJ2lkJ1xuICAgICAgICAgICAgT2JqZWN0LmRlZmluZVByb3BlcnR5IHRoaXMsIG5hbWUsIGdldDptYWtlR2V0dGVyKG5hbWUpLCBzZXQ6bWFrZVNldHRlcihuYW1lKVxuXG4gICAgIyBCYWNrYm9uZS5Nb2RlbCBPdmVycmlkZXMgIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cbiAgICBzeW5jOiAtPiAjIGRvIG5vdGhpbmdcblxuICAgICMgT2JqZWN0IE92ZXJyaWRlcyAjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xuXG4gICAgdG9TdHJpbmc6IC0+XG4gICAgICAgIHJldHVybiBcIiN7QGNvbnN0cnVjdG9yLm5hbWV9ICgje0BjaWR9KVwiXG4iLCIjIyNcbiMgQ3JhZnRpbmcgR3VpZGUgLSBpdGVtLmNvZmZlZVxuI1xuIyBDb3B5cmlnaHQgKGMpIDIwMTQgYnkgUmVkd29vZCBMYWJzXG4jIEFsbCByaWdodHMgcmVzZXJ2ZWQuXG4jIyNcblxuQmFzZU1vZGVsID0gcmVxdWlyZSAnLi9iYXNlX21vZGVsJ1xuXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblxubW9kdWxlLmV4cG9ydHMgPSBjbGFzcyBJdGVtIGV4dGVuZHMgQmFzZU1vZGVsXG5cbiAgICBjb25zdHJ1Y3RvcjogKGF0dHJpYnV0ZXM9e30sIG9wdGlvbnM9e30pLT5cbiAgICAgICAgYXR0cmlidXRlcy5uYW1lICAgICA/PSAnJ1xuICAgICAgICBhdHRyaWJ1dGVzLnF1YW50aXR5ID89IDFcbiAgICAgICAgc3VwZXIgYXR0cmlidXRlcywgb3B0aW9uc1xuXG4gICAgIyBQdWJsaWMgTWV0aG9kcyAjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIiwiIyMjXG4jIENyYWZ0aW5nIEd1aWRlIC0gdjEuY29mZmVlXG4jXG4jIENvcHlyaWdodCAoYykgMjAxNCBieSBSZWR3b29kIExhYnNcbiMgQWxsIHJpZ2h0cyByZXNlcnZlZC5cbiMjI1xuXG5JdGVtICAgICAgID0gcmVxdWlyZSAnLi4vaXRlbSdcblJlY2lwZSAgICAgPSByZXF1aXJlICcuLi9yZWNpcGUnXG5SZWNpcGVCb29rID0gcmVxdWlyZSAnLi4vcmVjaXBlX2Jvb2snXG5cblxuIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cbm1vZHVsZS5leHBvcnRzID0gY2xhc3MgVjFcblxuICAgIGNvbnN0cnVjdG9yOiAtPlxuICAgICAgICBAX2Vycm9yTG9jYXRpb24gPSAndGhlIGhlYWRlciBpbmZvcm1hdGlvbidcblxuICAgIHBhcnNlOiAoZGF0YSktPlxuICAgICAgICByZXR1cm4gQF9wYXJzZVJlY2lwZUJvb2sgZGF0YVxuXG4gICAgIyBQcml2YXRlIE1ldGhvZHMgIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cbiAgICBfcGFyc2VSZWNpcGVCb29rOiAoZGF0YSktPlxuICAgICAgICBpZiBub3QgZGF0YT8gdGhlbiB0aHJvdyBuZXcgRXJyb3IgJ3JlY2lwZSBib29rIGRhdGEgaXMgbWlzc2luZydcbiAgICAgICAgaWYgbm90IGRhdGEudmVyc2lvbj8gdGhlbiB0aHJvdyBuZXcgRXJyb3IgJ3ZlcnNpb24gaXMgcmVxdWlyZWQnXG4gICAgICAgIGlmIG5vdCBkYXRhLm1vZF9uYW1lPyB0aGVuIHRocm93IG5ldyBFcnJvciAnbW9kX25hbWUgaXMgcmVxdWlyZWQnXG4gICAgICAgIGlmIG5vdCBkYXRhLm1vZF92ZXJzaW9uPyB0aGVuIHRocm93IG5ldyBFcnJvciAnbW9kX3ZlcnNpb24gaXMgcmVxdWlyZWQnXG4gICAgICAgIGlmIG5vdCBfLmlzQXJyYXkoZGF0YS5yZWNpcGVzKSB0aGVuIHRocm93IG5ldyBFcnJvciAncmVjaXBlcyBtdXN0IGJlIGFuIGFycmF5J1xuXG4gICAgICAgIGJvb2sgICAgICAgICAgICAgPSBuZXcgUmVjaXBlQm9vayB2ZXJzaW9uOmRhdGEudmVyc2lvbiwgbW9kTmFtZTpkYXRhLm1vZF9uYW1lLCBtb2RWZXJzaW9uOmRhdGEubW9kX3ZlcnNpb25cbiAgICAgICAgYm9vay5kZXNjcmlwdGlvbiA9IGRhdGEuZGVzY3JpcHRpb24gb3IgJydcblxuICAgICAgICBmb3IgaW5kZXggaW4gWzAuLi5kYXRhLnJlY2lwZXMubGVuZ3RoXVxuICAgICAgICAgICAgQF9lcnJvckxvY2F0aW9uID0gXCJyZWNpcGUgI3tpbmRleCArIDF9XCJcbiAgICAgICAgICAgIHJlY2lwZURhdGEgPSBkYXRhLnJlY2lwZXNbaW5kZXhdXG4gICAgICAgICAgICBib29rLnJlY2lwZXMucHVzaCBAX3BhcnNlUmVjaXBlIHJlY2lwZURhdGFcblxuICAgICAgICByZXR1cm4gYm9va1xuXG4gICAgX3BhcnNlUmVjaXBlOiAoZGF0YSwgb3B0aW9ucz17fSktPlxuICAgICAgICBpZiBub3QgZGF0YT8gdGhlbiB0aHJvdyBuZXcgRXJyb3IgXCJyZWNpcGUgZGF0YSBpcyBtaXNzaW5nIGZvciAje0BfZXJyb3JMb2NhdGlvbn1cIlxuICAgICAgICBpZiBub3QgZGF0YS5vdXRwdXQ/IHRoZW4gdGhyb3cgbmV3IEVycm9yIFwiI3tAX2Vycm9yTG9jYXRpb259IGlzIG1pc3Npbmcgb3V0cHV0XCJcbiAgICAgICAgaWYgbm90IGRhdGEuaW5wdXQ/IHRoZW4gdGhyb3cgbmV3IEVycm9yIFwiI3tAX2Vycm9yTG9jYXRpb259IGlzIG1pc3NpbmcgaW5wdXRcIlxuXG4gICAgICAgIG91dHB1dCA9IEBfcGFyc2VJdGVtTGlzdCBkYXRhLm91dHB1dCwgZmllbGQ6J291dHB1dCcsIGNhbkJlRW1wdHk6ZmFsc2VcbiAgICAgICAgQF9lcnJvckxvY2F0aW9uID0gXCJyZWNpcGUgZm9yIG91dHB1dFswXS5uYW1lXCJcblxuICAgICAgICBkYXRhLnRvb2xzID89IFtdXG4gICAgICAgIGlucHV0ICA9IEBfcGFyc2VJdGVtTGlzdCBkYXRhLmlucHV0LCAgZmllbGQ6J2lucHV0JywgY2FuQmVFbXB0eTpmYWxzZVxuICAgICAgICB0b29scyAgPSBAX3BhcnNlSXRlbUxpc3QgZGF0YS50b29scywgIGZpZWxkOid0b29scycsIGNhbkJlRW1wdHk6dHJ1ZVxuXG4gICAgICAgIHJldHVybiBuZXcgUmVjaXBlIGlucHV0OmlucHV0LCBvdXRwdXQ6b3V0cHV0LCB0b29sczp0b29sc1xuXG4gICAgX3BhcnNlSXRlbUxpc3Q6IChkYXRhLCBvcHRpb25zPXt9KS0+XG4gICAgICAgIGlmIG5vdCBkYXRhPyB0aGVuIHRocm93IG5ldyBFcnJvciBcIiN7QF9lcnJvckxvY2F0aW9ufSBtdXN0IGhhdmUgYW4gI3tvcHRpb25zLmZpZWxkfSBmaWVsZFwiXG5cbiAgICAgICAgaWYgbm90IF8uaXNBcnJheShkYXRhKSB0aGVuIGRhdGEgPSBbZGF0YV1cbiAgICAgICAgaWYgZGF0YS5sZW5ndGggaXMgMCBhbmQgbm90IG9wdGlvbnMuY2FuQmVFbXB0eVxuICAgICAgICAgICAgdGhyb3cgbmV3IEVycm9yIFwiI3tvcHRpb25zLmZpZWxkfSBmb3IgI3tAX2Vycm9yTG9jYXRpb259IGNhbm5vdCBiZSBlbXB0eVwiXG5cbiAgICAgICAgcmVzdWx0ID0gW11cbiAgICAgICAgZm9yIGluZGV4IGluIFswLi4uZGF0YS5sZW5ndGhdXG4gICAgICAgICAgICBpdGVtRGF0YSA9IGRhdGFbaW5kZXhdXG4gICAgICAgICAgICByZXN1bHQucHVzaCBAX3BhcnNlSXRlbSBpdGVtRGF0YSwgZmllbGQ6b3B0aW9ucy5maWVsZCwgaW5kZXg6aW5kZXhcblxuICAgICAgICByZXR1cm4gcmVzdWx0XG5cbiAgICBfcGFyc2VJdGVtOiAoZGF0YSwgb3B0aW9ucz17fSktPlxuICAgICAgICBlcnJvckJhc2UgPSBcIiN7b3B0aW9ucy5maWVsZH0gZWxlbWVudCAje29wdGlvbnMuaW5kZXh9IGZvciAje0BfZXJyb3JMb2NhdGlvbn1cIlxuICAgICAgICBpZiBub3QgZGF0YT8gdGhlbiB0aHJvdyBuZXcgRXJyb3IgXCIje2Vycm9yQmFzZX0gaXMgbWlzc2luZ1wiXG5cbiAgICAgICAgaWYgXy5pc1N0cmluZyhkYXRhKSB0aGVuIGRhdGEgPSBbMSwgZGF0YV1cbiAgICAgICAgaWYgbm90IF8uaXNBcnJheShkYXRhKSB0aGVuIHRocm93IG5ldyBFcnJvciBcIiN7ZXJyb3JCYXNlfSBtdXN0IGJlIGFuIGFycmF5XCJcblxuICAgICAgICBpZiBkYXRhLmxlbmd0aCBpcyAxIHRoZW4gZGF0YS51bnNoaWZ0IDFcbiAgICAgICAgaWYgZGF0YS5sZW5ndGggaXNudCAyIHRoZW4gdGhyb3cgbmV3IEVycm9yIFwiI3tlcnJvckJhc2V9IG11c3QgaGF2ZSBhdCBsZWFzdCBvbmUgZWxlbWVudFwiXG4gICAgICAgIGlmIG5vdCBfLmlzTnVtYmVyKGRhdGFbMF0pIHRoZW4gdGhyb3cgbmV3IEVycm9yIFwiI3tlcnJvckJhc2V9IG11c3Qgc3RhcnQgd2l0aCBhIG51bWJlclwiXG5cbiAgICAgICAgcmV0dXJuIG5ldyBJdGVtIHF1YW50aXR5OmRhdGFbMF0sIG5hbWU6ZGF0YVsxXVxuIiwiIyMjXG4jIENyYWZ0aW5nIEd1aWRlIC0gcmVjaXBlLmNvZmZlZVxuI1xuIyBDb3B5cmlnaHQgKGMpIDIwMTQgYnkgUmVkd29vZCBMYWJzXG4jIEFsbCByaWdodHMgcmVzZXJ2ZWQuXG4jIyNcblxuQmFzZU1vZGVsID0gcmVxdWlyZSAnLi9iYXNlX21vZGVsJ1xuXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblxubW9kdWxlLmV4cG9ydHMgPSBjbGFzcyBSZWNpcGUgZXh0ZW5kcyBCYXNlTW9kZWxcblxuICAgIGNvbnN0cnVjdG9yOiAoYXR0cmlidXRlcz17fSwgb3B0aW9ucz17fSktPlxuICAgICAgICBzdXBlciBhdHRyaWJ1dGVzLCBvcHRpb25zXG5cbiAgICAgICAgT2JqZWN0LmRlZmluZVByb3BlcnR5IHRoaXMsICduYW1lJywgZ2V0Oi0+IEBvdXRwdXRbMF0ubmFtZVxuIiwiIyMjXG4jIENyYWZ0aW5nIEd1aWRlIC0gcmVjaXBlX2Jvb2suY29mZmVlXG4jXG4jIENvcHlyaWdodCAoYykgMjAxNCBieSBSZWR3b29kIExhYnNcbiMgQWxsIHJpZ2h0cyByZXNlcnZlZC5cbiMjI1xuXG5CYXNlTW9kZWwgPSByZXF1aXJlICcuL2Jhc2VfbW9kZWwnXG5cbiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xuXG5tb2R1bGUuZXhwb3J0cyA9IGNsYXNzIFJlY2lwZUJvb2sgZXh0ZW5kcyBCYXNlTW9kZWxcblxuICAgIGNvbnN0cnVjdG9yOiAoYXR0cmlidXRlcz17fSwgb3B0aW9ucz17fSktPlxuICAgICAgICBpZiBfLmlzRW1wdHkoYXR0cmlidXRlcy5tb2ROYW1lKSB0aGVuIHRocm93IG5ldyBFcnJvciAnbW9kTmFtZSBjYW5ub3QgYmUgZW1wdHknXG4gICAgICAgIGlmIF8uaXNFbXB0eShhdHRyaWJ1dGVzLm1vZFZlcnNpb24pIHRoZW4gdGhyb3cgbmV3IEVycm9yICdtb2RWZXJzaW9uIGNhbm5vdCBiZSBlbXB0eSdcblxuICAgICAgICBhdHRyaWJ1dGVzLmRlc2NyaXB0aW9uID89ICcnXG4gICAgICAgIGF0dHJpYnV0ZXMucmVjaXBlcyAgICAgPz0gW11cbiAgICAgICAgc3VwZXIgYXR0cmlidXRlcywgb3B0aW9uc1xuXG4gICAgIyBQdWJsaWMgTWV0aG9kcyAjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cbiAgICBnZXRSZWNpcGVzOiAobmFtZSktPlxuICAgICAgICByZXN1bHQgPSBbXVxuICAgICAgICBmb3IgcmVjaXBlIGluIEByZWNpcGVzXG4gICAgICAgICAgICBpZiByZWNpcGUubmFtZSBpcyBuYW1lXG4gICAgICAgICAgICAgICAgcmVzdWx0LnB1c2ggcmVjaXBlXG5cbiAgICAgICAgcmV0dXJuIHJlc3VsdFxuXG4gICAgIyBPYmplY3QgT3ZlcnJpZGVzICMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cbiAgICB0b1N0cmluZzogLT5cbiAgICAgICAgcmV0dXJuIFwiUmVjaXBlQm9vayAoI3tAY2lkfSkge1xuICAgICAgICAgICAgbW9kTmFtZToje0Btb2ROYW1lfSxcbiAgICAgICAgICAgIG1vZFZlcnNpb246I3tAbW9kVmVyc2lvbn0sXG4gICAgICAgICAgICByZWNpcGVzOiN7QHJlY2lwZXMubGVuZ3RofSBpdGVtc31cIlxuIiwiIyMjXG4jIENyYWZ0aW5nIEd1aWRlIC0gdjEudGVzdC5jb2ZmZWVcbiNcbiMgQ29weXJpZ2h0IChjKSAyMDE0IGJ5IFJlZHdvb2QgTGFic1xuIyBBbGwgcmlnaHRzIHJlc2VydmVkLlxuIyMjXG5cblYxID0gcmVxdWlyZSAnLi4vLi4vc3JjL3NjcmlwdHMvbW9kZWxzL3BhcnNlcl92ZXJzaW9ucy92MSdcblxuIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cbnBhcnNlciA9IG51bGxcblxuIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cbmRlc2NyaWJlICdSZWNpcGVCb29rUGFyc2VyLlYxJywgLT5cblxuICAgIGJlZm9yZSAtPiBwYXJzZXIgPSBuZXcgVjFcblxuICAgIGRlc2NyaWJlICdfcGFyc2VSZWNpcGVCb29rJywgLT5cblxuICAgICAgICBpdCAncmVxdWlyZXMgYSBtb2RfbmFtZScsIC0+XG4gICAgICAgICAgICBkYXRhID0gdmVyc2lvbjoxLCBtb2RfdmVyc2lvbjonMS4wJywgcmVjaXBlczpbXVxuICAgICAgICAgICAgZXhwZWN0KC0+IHBhcnNlci5fcGFyc2VSZWNpcGVCb29rIGRhdGEpLnRvLnRocm93IEVycm9yLCAnbW9kX25hbWUgaXMgcmVxdWlyZWQnXG5cbiAgICAgICAgaXQgJ3JlcXVpcmVzIGEgbW9kX3ZlcnNpb24nLCAtPlxuICAgICAgICAgICAgZGF0YSA9IHZlcnNpb246MSwgbW9kX25hbWU6J0VtcHR5JywgcmVjaXBlczpbXVxuICAgICAgICAgICAgZXhwZWN0KC0+IHBhcnNlci5fcGFyc2VSZWNpcGVCb29rIGRhdGEpLnRvLnRocm93IEVycm9yLCAnbW9kX3ZlcnNpb24gaXMgcmVxdWlyZWQnXG5cbiAgICAgICAgaXQgJ2NhbiBwYXJzZSBhbiBlbXB0eSByZWNpcGUgYm9vaycsIC0+XG4gICAgICAgICAgICBkYXRhID1cbiAgICAgICAgICAgICAgICB2ZXJzaW9uOiAxXG4gICAgICAgICAgICAgICAgbW9kX25hbWU6ICdFbXB0eSdcbiAgICAgICAgICAgICAgICBtb2RfdmVyc2lvbjogJzEuMCdcbiAgICAgICAgICAgICAgICByZWNpcGVzOiBbXVxuICAgICAgICAgICAgYm9vayA9IHBhcnNlci5fcGFyc2VSZWNpcGVCb29rIGRhdGFcbiAgICAgICAgICAgIGJvb2subW9kTmFtZS5zaG91bGQuZXF1YWwgJ0VtcHR5J1xuICAgICAgICAgICAgYm9vay5tb2RWZXJzaW9uLnNob3VsZC5lcXVhbCAnMS4wJ1xuXG4gICAgICAgIGl0ICdjYW4gcGFyc2UgYSBub24tZW1wdHkgcmVjaXBlIGJvb2snLCAtPlxuICAgICAgICAgICAgZGF0YSA9XG4gICAgICAgICAgICAgICAgdmVyc2lvbjogMVxuICAgICAgICAgICAgICAgIG1vZF9uYW1lOiAnTWluZWNyYWZ0J1xuICAgICAgICAgICAgICAgIG1vZF92ZXJzaW9uOiAnMS43LjEwJ1xuICAgICAgICAgICAgICAgIHJlY2lwZXM6IFtcbiAgICAgICAgICAgICAgICAgICAgeyBpbnB1dDonc3VnYXIgY2FuZScsIG91dHB1dDonc3VnYXInIH1cbiAgICAgICAgICAgICAgICAgICAgeyBpbnB1dDpbWzMsICd3b29sJ10sIFszLCAncGxhbmtzJ11dLCB0b29sczonY3JhZnRpbmcgdGFibGUnLCBvdXRwdXQ6J2JlZCcgfVxuICAgICAgICAgICAgICAgIF1cbiAgICAgICAgICAgIGJvb2sgPSBwYXJzZXIuX3BhcnNlUmVjaXBlQm9vayBkYXRhXG4gICAgICAgICAgICBib29rLm1vZE5hbWUuc2hvdWxkLmVxdWFsICdNaW5lY3JhZnQnXG4gICAgICAgICAgICBib29rLm1vZFZlcnNpb24uc2hvdWxkLmVxdWFsICcxLjcuMTAnXG4gICAgICAgICAgICAoci5uYW1lIGZvciByIGluIGJvb2sucmVjaXBlcykuc29ydCgpLnNob3VsZC5lcWwgWydiZWQnLCAnc3VnYXInXVxuXG4gICAgZGVzY3JpYmUgJ19wYXJzZVJlY2lwZScsIC0+XG5cbiAgICAgICAgaXQgJ3JlcXVpcmVzIG91dHB1dCB0byBiZSBkZWZpbmVkJywgLT5cbiAgICAgICAgICAgIHBhcnNlci5fZXJyb3JMb2NhdGlvbiA9ICdib2F0J1xuICAgICAgICAgICAgZXhwZWN0KC0+IHBhcnNlci5fcGFyc2VSZWNpcGUgaW5wdXQ6J3dvb2wnKS50by50aHJvdyBFcnJvciwgJ2JvYXQgaXMgbWlzc2luZyBvdXRwdXQnXG5cbiAgICAgICAgaXQgJ3JlcXVpcmVzIGlucHV0IHRvIGJlIGRlZmluZWQnLCAtPlxuICAgICAgICAgICAgcGFyc2VyLl9lcnJvckxvY2F0aW9uID0gJ2JvYXQnXG4gICAgICAgICAgICBleHBlY3QoLT4gcGFyc2VyLl9wYXJzZVJlY2lwZSBvdXRwdXQ6J3dvb2wnKS50by50aHJvdyBFcnJvciwgJ2JvYXQgaXMgbWlzc2luZyBpbnB1dCdcblxuICAgICAgICBpdCAnY2FuIHBhcnNlIGEgcmVndWxhciByZWNpcGUnLCAtPlxuICAgICAgICAgICAgZGF0YSA9XG4gICAgICAgICAgICAgICAgb3V0cHV0OiAnYmVkJ1xuICAgICAgICAgICAgICAgIGlucHV0OiBbWzMsICdwbGFua3MnXSwgWzMsICd3b29sJ11dXG4gICAgICAgICAgICAgICAgdG9vbHM6ICdjcmFmdGluZyB0YWJsZSdcbiAgICAgICAgICAgIHJlY2lwZSA9IHBhcnNlci5fcGFyc2VSZWNpcGUgZGF0YVxuICAgICAgICAgICAgKGkubmFtZSBmb3IgaSBpbiByZWNpcGUub3V0cHV0KS5zaG91bGQuZXFsIFsnYmVkJ11cbiAgICAgICAgICAgIChpLm5hbWUgZm9yIGkgaW4gcmVjaXBlLmlucHV0KS5zb3J0KCkuc2hvdWxkLmVxbCBbJ3BsYW5rcycsICd3b29sJ11cbiAgICAgICAgICAgIChpLm5hbWUgZm9yIGkgaW4gcmVjaXBlLnRvb2xzKS5zaG91bGQuZXFsIFsnY3JhZnRpbmcgdGFibGUnXVxuXG4gICAgICAgIGl0ICdjYW4gcGFyc2UgYSByZWNpcGUgd2l0aG91dCB0b29scycsIC0+XG4gICAgICAgICAgICByZWNpcGUgPSBwYXJzZXIuX3BhcnNlUmVjaXBlIG91dHB1dDonc3VnYXInLCBpbnB1dDonc3VnYXIgY2FuZSdcbiAgICAgICAgICAgIChpLm5hbWUgZm9yIGkgaW4gcmVjaXBlLm91dHB1dCkuc2hvdWxkLmVxbCBbJ3N1Z2FyJ11cbiAgICAgICAgICAgIChpLm5hbWUgZm9yIGkgaW4gcmVjaXBlLmlucHV0KS5zb3J0KCkuc2hvdWxkLmVxbCBbJ3N1Z2FyIGNhbmUnXVxuICAgICAgICAgICAgKGkubmFtZSBmb3IgaSBpbiByZWNpcGUudG9vbHMpLnNob3VsZC5lcWwgW11cblxuICAgIGRlc2NyaWJlICdfcGFyc2VJdGVtTGlzdCcsIC0+XG5cbiAgICAgICAgaXQgJ2NhbiBwcm9tb3RlIGEgc2luZ2xlIGl0ZW0gdG8gYSBsaXN0JywgLT5cbiAgICAgICAgICAgIGxpc3QgPSBwYXJzZXIuX3BhcnNlSXRlbUxpc3QgJ2JvYXQnXG4gICAgICAgICAgICAoaS5uYW1lIGZvciBpIGluIGxpc3QpLnNob3VsZC5lcWwgWydib2F0J11cblxuICAgICAgICBpdCAnY2FuIHJlcXVpcmUgYSBsaXN0IHRvIGJlIG5vbi1lbXB0eScsIC0+XG4gICAgICAgICAgICBwYXJzZXIuX2Vycm9yTG9jYXRpb24gPSAnYm9hdCdcbiAgICAgICAgICAgIG9wdGlvbnMgPSBmaWVsZDonb3V0cHV0JywgY2FuQmVFbXB0eTpmYWxzZVxuICAgICAgICAgICAgZXhwZWN0KC0+IHBhcnNlci5fcGFyc2VJdGVtTGlzdCBbXSwgb3B0aW9ucykudG8udGhyb3cgRXJyb3IsICdvdXRwdXQgZm9yIGJvYXQgY2Fubm90IGJlIGVtcHR5J1xuXG4gICAgICAgIGl0ICdjYW4gYWxsb3cgYW4gZW1wdHkgbGlzdCcsIC0+XG4gICAgICAgICAgICBsaXN0ID0gcGFyc2VyLl9wYXJzZUl0ZW1MaXN0IFtdLCBjYW5CZUVtcHR5OnRydWVcbiAgICAgICAgICAgIGxpc3QubGVuZ3RoLnNob3VsZC5lcXVhbCAwXG5cbiAgICAgICAgaXQgJ2NhbiBwYXJzZSBhIG5vbi1lbXB0eSBsaXN0JywgLT5cbiAgICAgICAgICAgIGxpc3QgPSBwYXJzZXIuX3BhcnNlSXRlbUxpc3QgW1szLCAncGxhbmsnXSwgWzMsICd3b29sJ11dXG4gICAgICAgICAgICAoaS5uYW1lIGZvciBpIGluIGxpc3QpLnNvcnQoKS5zaG91bGQuZXFsIFsncGxhbmsnLCAnd29vbCddXG5cbiAgICBkZXNjcmliZSAnX3BhcnNlSXRlbScsIC0+XG5cbiAgICAgICAgaXQgJ3JlcXVpcmVzIHRoZSBhcnJheSB0byBoYXZlIGF0IGxlYXN0IG9uZSBlbGVtZW50JywgLT5cbiAgICAgICAgICAgIHBhcnNlci5fZXJyb3JMb2NhdGlvbiA9ICdib2F0J1xuICAgICAgICAgICAgb3B0aW9ucyA9IGluZGV4OjEsIGZpZWxkOidvdXRwdXQnXG4gICAgICAgICAgICBleHBlY3QoLT4gcGFyc2VyLl9wYXJzZUl0ZW0oW10sIG9wdGlvbnMpKS50by50aHJvdyBFcnJvcixcbiAgICAgICAgICAgICAgICBcIm91dHB1dCBlbGVtZW50IDEgZm9yIGJvYXQgbXVzdCBoYXZlIGF0IGxlYXN0IG9uZSBlbGVtZW50XCJcblxuICAgICAgICBpdCAnY2FuIGZpbGwgaW4gYSBtaXNzaW5nIG51bWJlcicsIC0+XG4gICAgICAgICAgICBpdGVtID0gcGFyc2VyLl9wYXJzZUl0ZW0gJ2JvYXQnXG4gICAgICAgICAgICBpdGVtLm5hbWUuc2hvdWxkLmVxdWFsICdib2F0J1xuICAgICAgICAgICAgaXRlbS5xdWFudGl0eS5zaG91bGQuZXF1YWwgMVxuXG4gICAgICAgICAgICBpdGVtMiA9IHBhcnNlci5fcGFyc2VJdGVtIFsnYm9hdCddXG4gICAgICAgICAgICBpdGVtMi5uYW1lLnNob3VsZC5lcXVhbCAnYm9hdCdcbiAgICAgICAgICAgIGl0ZW0yLnF1YW50aXR5LnNob3VsZC5lcXVhbCAxXG5cbiAgICAgICAgaXQgJ3JlcXVpcmVzIHRoZSBkYXRhIHRvIHN0YXJ0IHdpdGggYSBudW1iZXInLCAtPlxuICAgICAgICAgICAgcGFyc2VyLl9lcnJvckxvY2F0aW9uID0gJ2JvYXQnXG4gICAgICAgICAgICBvcHRpb25zID0gaW5kZXg6MSwgZmllbGQ6J291dHB1dCdcbiAgICAgICAgICAgIGV4cGVjdCgtPiBwYXJzZXIuX3BhcnNlSXRlbShbJzInLCAnYm9vayddLCBvcHRpb25zKSkudG8udGhyb3cgRXJyb3IsXG4gICAgICAgICAgICAgICAgXCJvdXRwdXQgZWxlbWVudCAxIGZvciBib2F0IG11c3Qgc3RhcnQgd2l0aCBhIG51bWJlclwiXG5cbiAgICAgICAgaXQgJ2NhbiBwYXJzZSBhIGJhc2ljIGl0ZW0nLCAtPlxuICAgICAgICAgICAgaXRlbSA9IHBhcnNlci5fcGFyc2VJdGVtIFsyLCAnYm9vayddXG4gICAgICAgICAgICBpdGVtLmNvbnN0cnVjdG9yLm5hbWUuc2hvdWxkLmVxdWFsICdJdGVtJ1xuIiwiIyMjXG4jIENyYWZ0aW5nIEd1aWRlIC0gdGVzdC5jb2ZmZWVcbiNcbiMgQ29weXJpZ2h0IChjKSAyMDE0IGJ5IFJlZHdvb2QgTGFic1xuIyBBbGwgcmlnaHRzIHJlc2VydmVkLlxuIyMjXG5cbiMgVGVzdCBTZXQtdXAgIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xuXG5jaGFpLnVzZSByZXF1aXJlICdzaW5vbi1jaGFpJ1xuY2hhaS5jb25maWcuaW5jbHVkZVN0YWNrID0gdHJ1ZVxuXG5pZiB0eXBlb2YoZ2xvYmFsKSBpcyAndW5kZWZpbmVkJ1xuICAgIHdpbmRvdy5nbG9iYWwgPSB3aW5kb3dcblxuZ2xvYmFsLmFzc2VydCA9IGNoYWkuYXNzZXJ0XG5nbG9iYWwuZXhwZWN0ID0gY2hhaS5leHBlY3Rcbmdsb2JhbC5zaG91bGQgPSBjaGFpLnNob3VsZCgpXG5cbiMgVGVzdCBSZWdpc3RyeSAjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xuXG5tb2NoYS5zZXR1cCAnYmRkJ1xuXG5yZXF1aXJlICcuL3BhcnNlcl92ZXJzaW9ucy92MS50ZXN0J1xuXG5tb2NoYS5jaGVja0xlYWtzKClcbm1vY2hhLnJ1bigpXG4iXX0=
