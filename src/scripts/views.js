var jade = jade || require('jade').runtime;

this["JST"] = this["JST"] || {};

this["JST"]["crafting_table"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<div class=\"view__crafting_table\">\n  <h2><img src=\"/images/workbench_top.png\"/>\n    <p>Crafting Table</p>\n  </h2>\n  <div class=\"recipe_selector\">\n    <p>I want to make</p>\n    <select name=\"quantity\">\n      <option value=\"1\">1</option>\n      <option value=\"2\">2</option>\n      <option value=\"4\">4</option>\n      <option value=\"8\">8</option>\n      <option value=\"16\">16</option>\n      <option value=\"64\">64</option>\n    </select>\n    <input name=\"name\" placeholder=\"enter an item name\"/>\n    <label>\n      <input name=\"including_tools\" type=\"checkbox\"/>including tools\n    </label>\n  </div>\n  <table>\n    <tr>\n      <td class=\"have\">\n        <h3>\n          <p>You have...</p>\n        </h3>\n        <textarea name=\"have\" placeholder=\"For example:\n\n3 wool\n4 iron ingot\"></textarea>\n      </td>\n      <td class=\"need\">\n        <h3>\n          <p>You'll need...</p>\n        </h3>\n        <ul></ul>\n      </td>\n      <td class=\"make\">\n        <h3>\n          <p>You'll make...</p>\n        </h3>\n        <ul></ul>\n      </td>\n      <td class=\"result\">\n        <h3>\n          <p>You'll get...</p>\n        </h3>\n        <ul></ul>\n      </td>\n    </tr>\n  </table>\n</div>");;return buf.join("");
};

this["JST"]["item_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<div class=\"view__landing_page\">\n  <div class=\"view__crafting_table\"></div>\n  <div class=\"view__recipe_catalog\"></div>\n</div>");;return buf.join("");
};

this["JST"]["recipe_book"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<tr>\n  <td>\n    <p></p>\n  </td>\n  <td>\n    <p></p>\n  </td>\n</tr>");;return buf.join("");
};

this["JST"]["recipe_catalog"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<div class=\"view__recipe_catalog\">\n  <h2><img src=\"/images/bookshelf.png\"/>\n    <p>Recipe Catalog</p>\n  </h2>\n  <table>\n    <tr>\n      <td>&nbsp;</td>\n      <td>\n        <input placeholder=\"enter a URL to load another recipe book...\" class=\"recipe_book_url\"/>\n        <button class=\"recipe_book_load_button\">Load</button>\n      </td>\n    </tr>\n  </table>\n  <div class=\"load_error\">\n    <p></p>\n  </div>\n</div>");;return buf.join("");
};

this["JST"]["test"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<p>Hello world!</p>");;return buf.join("");
};

if (typeof exports === 'object' && exports) {module.exports = this["JST"];}