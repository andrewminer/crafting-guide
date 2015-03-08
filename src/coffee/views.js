var jade = jade || require('jade').runtime;

this["JST"] = this["JST"] || {};

this["JST"]["browse_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__browse_page\"><div class=\"sidebar\"><script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>\n<!-- Sidebar Skyscraper -->\n<ins class=\"adsbygoogle\"\n     style=\"display:inline-block;width:160px;height:600px\"\n     data-ad-client=\"ca-pub-6593013914878730\"\n     data-ad-slot=\"7613920409\"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n</div><div class=\"mainBody\"><h2><p>Active Mods</p></h2><div class=\"mods\"></div></div></div>");;return buf.join("");
};

this["JST"]["configure_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__configure_page\"><div class=\"sidebar\"><script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>\n<!-- Sidebar Skyscraper -->\n<ins class=\"adsbygoogle\"\n     style=\"display:inline-block;width:160px;height:600px\"\n     data-ad-client=\"ca-pub-6593013914878730\"\n     data-ad-slot=\"7613920409\"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n</div><div class=\"mainBody\"><div class=\"view__mod_pack\"></div></div></div>");;return buf.join("");
};

this["JST"]["craft_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__craft_page\"><div class=\"view__inventory want\"></div><div class=\"view__inventory have\"></div><div class=\"view__inventory need\"></div><div class=\"view__crafting_table\"></div></div>");;return buf.join("");
};

this["JST"]["crafting_grid"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<table class=\"view__crafting_grid\"><tr><td><a><img src=\"/images/empty.png\"/></a></td><td><a><img src=\"/images/empty.png\"/></a></td><td><a><img src=\"/images/empty.png\"/></a></td></tr><tr><td><a><img src=\"/images/empty.png\"/></a></td><td><a><img src=\"/images/empty.png\"/></a></td><td><a><img src=\"/images/empty.png\"/></a></td></tr><tr><td><a><img src=\"/images/empty.png\"/></a></td><td><a><img src=\"/images/empty.png\"/></a></td><td><a><img src=\"/images/empty.png\"/></a></td></tr></table>");;return buf.join("");
};

this["JST"]["crafting_table"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__crafting_table\"><h2><img src=\"/images/workbench_top.png\"/><p>Crafting Plan</p></h2><div class=\"panel\"><div class=\"prev\"></div><div class=\"view__minimal_recipe\"></div><div class=\"next\"></div><div class=\"problem\"><a>report a problem</a></div></div></div>");;return buf.join("");
};

this["JST"]["feedback"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__feedback\"><input name=\"name\" placeholder=\"name (optional)\"/><input name=\"email\" placeholder=\"email (optional)\"/><label name=\"comment\">Comment:</label><textarea name=\"comment\"></textarea><button name=\"send\">send</button><div class=\"error\"><p>Sending failed. Please try again later.</p></div><div class=\"label\"><img src=\"/images/paper.png\"/><p>Feedback</p></div></div>");;return buf.join("");
};

this["JST"]["full_recipe"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__full_recipe\"><div class=\"input\"><h3>Ingredients</h3><div class=\"view__inventory_table\"></div></div><div class=\"pattern\"><table class=\"view__crafting_grid\"></table><div class=\"tool\"><a></a></div></div><div class=\"output\"><h3>Produces</h3><div class=\"view__inventory_table\"></div></div></div>");;return buf.join("");
};

this["JST"]["home_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__home_page\"><div class=\"sidebar\"><div class=\"titleImage\"><a href=\"/browse/minecraft/\"><img src=\"/browse/minecraft/icon.png\"></a></div><div class=\"titleImage\"><a href=\"/browse/buildcraft/\"><img src=\"/browse/buildcraft/icon.png\"></a></div><div class=\"titleImage\"><a href=\"/browse/industrial_craft_2/\"><img src=\"/browse/industrial_craft_2/icon.png\"></a></div><div class=\"titleImage\"><a href=\"/browse/applied_energistics_2/\"><img src=\"/browse/applied_energistics_2/icon.png\"></a></div><div class=\"titleImage\"><a href=\"/browse/thermal_expansion/\"><img src=\"/browse/thermal_expansion/icon.png\"></a></div><div class=\"titleImage\"><a href=\"/browse/enderio/\"><img src=\"/browse/enderio/icon.png\"></a></div><div class=\"titleImage\"><a href=\"/browse/railcraft/\"><img src=\"/browse/railcraft/icon.png\"></a></div><script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>\n<!-- Sidebar Skyscraper -->\n<ins class=\"adsbygoogle\"\n     style=\"display:inline-block;width:160px;height:600px\"\n     data-ad-client=\"ca-pub-6593013914878730\"\n     data-ad-slot=\"7613920409\"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n</div><div class=\"mainBody\"><div class=\"section\"><h2>Welcome!</h2><div class=\"panel\"><div class=\"entry\"><p class=\"intro\">Crafting Guide is the ultimate resource for Minecraft. Whether you're punching trees or building\nreactors, you'll find Crafting Guide indispensable.</p><ul><li class=\"intro\">Can't remember the recipe for a <a href=\"/browse/buildcraft/quarry\">BuildCraft Quarry</a>?</li><li class=\"intro\">Curious to see all the blocks added by <a href=\"/browse/railcraft\">Railcraft</a>?</li><li class=\"intro\">Want step-by-step directions for making a full <a\nhref=\"/craft/quantumsuit_bodyarmor:quantumsuit_boots:quantumsuit_helmet:quantumsuit_leggings\"\n>IC2 QuantumSuit</a>?</li></ul><p class=\"intro\">No problem. Crafting Guide can do it all.</p><p><a class=\"section-link\" href='/configure'>Configure<a> which mods you're using, and the entire\nsite will update itself to your mod pack.</p><p><a class=\"section-link\" href='/browse'>Browse<a> through your own customized item catalog to\nsee full recipe lists, related items, recipes added by each tool, and even which items can be\nmade from the item you're looking at.</p><p><a class=\"section-link\" href='/craft'>Craft<a> any number of items from your mod pack to see a\nfull list of raw ingredients, and recipe-by-recipe instructions on how to make everything on\nyour list. No item is too complex, and no build is too big.\n</p></div></div></div><div class=\"section\"><h2>What's new?</h2><div class=\"panel\"><h3>2015-03-01</h3><div class=\"entry\"><p>This release delivers the second major expansion of Crafting Guide! Here's the list of what's\nnew:</p><ul><li>New home page!</li><li>Moved the crafting planner (the old home page) to its own <a href=\"/craft\">Craft</a> page</li><li>Moved mod pack management to the new <a href=\"/configure\">Configure</a> page</li><li>Added a <a href=\"/browse\">Browse</a> page where you can peruse the list of supported mods</li></ul></div><h3>2015-02-26</h3><div class=\"entry\"><p>This release adds a new section to the item pages called \"Used as Tool to Make\". The new section\nshows all the other items which can be made by that tool. For example, the IC2 Macerator shows\na bunch of things like Iron Dust, Gold Dust, etc.\n</p></div><h3>2015-02-24</h3><div class=\"entry\"><p>This release changes the crafting page to let you modify the quantity of items in the \"Items You\nWant\" and \"Items You Have\" section.  Let's say you want to make <a\nhref=\"/craft/64.potion_of_healing\">64 Potions of Healing</a>. You add \"Potion of Healing\" just\nas as you always did, but now you can click on the quantity to change it to whatever you want.</p><p>At the same time, I've changed the quantity field to allow up to 9999 of any item. Have fun with\nthose huge builds!\n</p></div><h3>2015-02-22</h3><div class=\"entry\"><p>Woo hoo! Or, should I say: Choo choo! I just added support for RailCraft! I also pushed up lots\nof performance improvements (55% faster at computing crafting plans)! Hopefully, you won't\nreally notice anything except that entering new items and computing really complicated crafting\nplans don't take so long.\n</p></div><h3>2015-02-19</h3><div class=\"entry\"><p>I just made some major updates to the crafting algorithm. Without getting into details, I'll say\nthat there are a few things you should notice:</p><ol><li>it will favor recipes which produce more of an item versus those which produce fewer (e.g.,\nIC2 plates get made with the Block Cutter instead of the Forge Hammer)</li><li>metal ingots will frequently (but not always) get crafted using 2x recipes instead of\nsmelting ore directly in a furnace</li><li>recipes for vanilla items added by mods are now available (e.g., smelting Iron Dust into Iron\ningots)</li></ol></div><h3>2015-02-10</h3><div class=\"entry\"><p>I just pushed up some fixes to avoid confusing various items of the same name from different\nmods.  The best example of this are the two Wrenches from Buildcraft and IC2, but there are a\nbunch of others.\n</p></div><h3>2015-02-09</h3><div class=\"entry\"><p>This release fixes a number of small issues and improves performance in a number of places. Most\nespecially, all links within the site have been changed to update the page in place without the\nneed to re-download anything.  This should make browsing between item pages <i>much</i> faster.\n</p></div><h3>2015-02-08</h3><div class=\"entry\"><p>This is the singlest largest expansion of the website yet! Each item from each mod now has its\nown page! This will expand in the future, but for now this shows all the recipes for the item as\nwell as all the closely related items and the others items that can be made using the item.</p><p>This also changes things so that links to Crafting Guide from other sites will first go to the\nitem's page (instead of to the crafting plan).  Not to worry though... there's still a direct\nlink from each item to the full crafting plan for that item.\n</p></div><h3>2015-02-02</h3><div class=\"entry\"><p>Crafting Guide now has support for EnderIO! I tend to add new mods in order of those with the\nmost votes, so remember to suggest your favorites!</p></div></div></div></div></div>");;return buf.join("");
};

this["JST"]["inventory"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__inventory\"><h2><img class=\"icon\"/><p></p></h2><div class=\"panel\"><div class=\"scrollbox\"><table><tr class=\"edit\"><td class=\"quantity\"></td><td class=\"icon\"></td><td width=\"*\" class=\"name\"><input name=\"name\"/></td><td class=\"action\"><button name=\"add\">add</button></td></tr></table></div><div class=\"toolbar\"><button name=\"clear\">clear</button></div></div></div>");;return buf.join("");
};

this["JST"]["inventory_table"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__inventory_table\"><table><tr class=\"edit\"><td class=\"quantity\"><input name=\"quantity\"/></td><td class=\"icon\"><img src=\"/images/unknown.png\"/></td><td width=\"*\" class=\"name\"><input name=\"name\"/></td><td class=\"action\"><button name=\"add\">add</button></td></tr></table><div class=\"toolbar\"><button name=\"clear\">clear</button></div></div>");;return buf.join("");
};

this["JST"]["item"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__item\"><a><table><tr><td class=\"itemIcon\"><img/></td><td width=\"*\" class=\"itemName\"></td></tr></table></a></div>");;return buf.join("");
};

this["JST"]["item_group"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__item_group section\"><h2></h2><div class=\"panel\"></div></div>");;return buf.join("");
};

this["JST"]["item_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__item_page\"><div class=\"sidebar\"><div class=\"titleImage\"><a><img/></a></div><a class=\"craftingPlan externalLink\"><p>See Crafting Plan</p></a><script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>\n<!-- Sidebar Skyscraper -->\n<ins class=\"adsbygoogle\"\n     style=\"display:inline-block;width:160px;height:600px\"\n     data-ad-client=\"ca-pub-6593013914878730\"\n     data-ad-slot=\"7613920409\"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n</div><div class=\"mainBody\"><h1 class=\"name\"></h1><div class=\"byline\"><p>from <a></a></p></div><div class=\"description\"><p></p></div><div class=\"recipes section\"><h2>Recipes</h2><div class=\"panel\"></div></div><div class=\"usedToMake\"><div class=\"view__item_group\"></div></div><div class=\"usedAsToolToMake\"><div class=\"view__item_group\"></div></div><div class=\"similar\"><div class=\"view__item_group\"></div></div><div class=\"plan\"></div></div></div>");;return buf.join("");
};

this["JST"]["minimal_recipe"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__minimal_recipe\"><div class=\"input\"><table class=\"view__crafting_grid\"></table><div class=\"tool\"></div></div><div class=\"output\"><a><img/></a><p class=\"quantity\"></p></div></div>");;return buf.join("");
};

this["JST"]["mod"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__mod\"><a><img class=\"logo\"/><h3 class=\"name\"><p></p></h3><div class=\"description\"><p></p></div></a></div>");;return buf.join("");
};

this["JST"]["mod_pack"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__mod_pack\"><h2><img src=\"/images/bookshelf.png\"/><p>Mod Pack</p></h2><div class=\"panel\"><div class=\"mods\"></div><div class=\"toolbar\"><button name=\"suggestMod\">suggest a mod</button></div></div></div>");;return buf.join("");
};

this["JST"]["mod_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__mod_page\"><div class=\"sidebar\"><div class=\"titleImage\"><a><img/></a></div><select class=\"version\"></select><a target=\"new\" class=\"homePage externalLink\"><p>Offical Home Page</p></a><a target=\"new\" class=\"documentation externalLink\"><p>Documentation</p></a><a target=\"new\" class=\"download externalLink\"><p>Download</p></a><script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>\n<!-- Sidebar Skyscraper -->\n<ins class=\"adsbygoogle\"\n     style=\"display:inline-block;width:160px;height:600px\"\n     data-ad-client=\"ca-pub-6593013914878730\"\n     data-ad-slot=\"7613920409\"></ins>\n<script>\n(adsbygoogle = window.adsbygoogle || []).push({});\n</script>\n</div><div class=\"mainBody\"><h1 class=\"name\"></h1><div class=\"byline\"><p></p></div><div class=\"description\"><p></p></div><div class=\"itemGroups\"></div></div></div>");;return buf.join("");
};

this["JST"]["mod_selector"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__mod_selector\"><div class=\"version\"><select><option value=\"none\">None</option></select></div><div class=\"name\"><a><p></p></a></div><div class=\"description\"><p></p></div></div>");;return buf.join("");
};

this["JST"]["stack"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<tr class=\"view__stack\"><td class=\"quantity\"><input/></td><td class=\"icon\"><img src=\"\"/></td><td width=\"*\" class=\"name\"><a></a></td><td class=\"action\"><button class=\"remove\">&nbsp;</button></td></tr>");;return buf.join("");
};

if (typeof exports === 'object' && exports) {module.exports = this["JST"];}