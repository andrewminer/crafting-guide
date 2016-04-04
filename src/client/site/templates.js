var jade = jade || require('jade/lib/runtime');

this["JST"] = this["JST"] || {};

this["JST"]["browse_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"content view__browse_page\"><div class=\"left\"><div class=\"view__adsense\"></div></div><div class=\"right\"><div class=\"tile_container\"></div></div></div>");;return buf.join("");
};

this["JST"]["browse_page/mod_tile"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__mod_tile\"><a><div class=\"left\"><img/></div><div class=\"right\"><p class=\"title\"></p><p class=\"description\"></p></div></a></div>");;return buf.join("");
};

this["JST"]["common/adsense"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__adsense\"></div>");;return buf.join("");
};

this["JST"]["common/crafting_grid"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__crafting_grid\"><div class=\"row\"><div class=\"view__slot\"></div><div class=\"view__slot\"></div><div class=\"view__slot\"></div></div><div class=\"row\"><div class=\"view__slot\"></div><div class=\"view__slot\"></div><div class=\"view__slot\"></div></div><div class=\"row\"><div class=\"view__slot\"></div><div class=\"view__slot\"></div><div class=\"view__slot\"></div></div></div>");;return buf.join("");
};

this["JST"]["common/inventory"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__inventory\"><div class=\"item_container\"></div><div class=\"empty_placeholder\">nothing</div><div class=\"buttons\"><div class=\"button item-selector\"><div class=\"bezel\"><p>add an item...</p></div></div><div class=\"button clear\"><div class=\"bezel\"><p>clear</p></div></div></div></div>");;return buf.join("");
};

this["JST"]["common/item_group"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<section class=\"view__item_group\"><h2></h2><div class=\"panel\"></div></section>");;return buf.join("");
};

this["JST"]["common/item_group/item_tile"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__item_tile\"><a><img/><p class=\"itemName\"></p></a></div>");;return buf.join("");
};

this["JST"]["common/item_selector/element"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__element\"><img/><div class=\"name\"></div><div class=\"modName\"></div></div>");;return buf.join("");
};

this["JST"]["common/item_selector"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__item_selector\"><div class=\"view__item_selector_popup\"><div class=\"search\"><img src=\"/images/search.png\"/><input placeholder=\"enter the name of an item\"/><img src=\"/images/close.png\" class=\"close\"/></div><div class=\"results\"></div></div></div>");;return buf.join("");
};

this["JST"]["common/markdown_section/markdown_image_list/markdown_image"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__markdown_image\"><div class=\"loaded\"><div class=\"thumbnail\"><img/></div><div class=\"dynamic\"><div class=\"button\"><div class=\"bezel\"><p></p></div></div><div class=\"fileName\"><p></p></div><div class=\"error\"><p></p></div></div><form><input type=\"file\" accept=\"image/gif,image/jpeg,image/png\" multiple=\"false\"/></form></div><div class=\"loading\"><p>checking for image...</p></div></div>");;return buf.join("");
};

this["JST"]["common/markdown_section/markdown_image_list"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__markdown_image_list\"><h3>Images Referenced</h3><div class=\"image_container\"></div></div>");;return buf.join("");
};

this["JST"]["common/markdown_section"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__markdown_section\"><h2></h2><div class=\"panel\"><div class=\"waiting\"><img src=\"/images/wait.gif\"/></div><div class=\"markdown\"></div><div class=\"creating\"><p>Please help by adding a description!</p></div><div class=\"editor\"><div class=\"instructions\">Edit using <a href=\"https://help.github.com/articles/github-flavored-markdown/\" target=\"new\">GitHub\nFlavored Markdown</a>. Use <tt>[[Item Name]]</tt> to link to another item and <tt>![](image.png)</tt>\nto add an image.</div><div class=\"text\"><textarea></textarea><div class=\"sizer\"></div></div></div><div class=\"view__markdown_image_list\"></div><div class=\"footer\"><div class=\"question\"><a href=\"javascript:void;\">Confused? Click here to ask a question!</a></div><div class=\"error\"><p></p></div><div class=\"buttons\"><div class=\"button edit\"><div class=\"bezel\"><p>edit</p></div></div><div class=\"button save\"><div class=\"bezel\"><p>save</p></div></div><div class=\"button preview\"><div class=\"bezel\"><p>preview</p></div></div><div class=\"button cancel\"><div class=\"bezel\"><p>cancel</p></div></div><div class=\"button return\"><div class=\"bezel\"><p>return</p></div></div></div></div><div class=\"confirming\"><p>Thanks for your help!</p><p>Your changes will appear on the site in a few minutes.</p></div><div class=\"appologizing\"><p>Sorry, but something went wrong.</p><p>Please try again after a few moments.</p></div></div></div>");;return buf.join("");
};

this["JST"]["common/recipe"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__recipe\"><div class=\"input\"><div class=\"view__crafting_grid\"></div><div class=\"tool\"></div></div><div class=\"output\"><div class=\"view__slot\"></div><div class=\"multiplier\"></div></div></div>");;return buf.join("");
};

this["JST"]["common/slot"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__slot\"><a><img src=\"/images/empty.png\"/><div class=\"quantity\"></div></a></div>");;return buf.join("");
};

this["JST"]["common/stack"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__stack\"><div class=\"quantity\"><input/></div><div class=\"icon\"><img src=\"\"/></div><div class=\"name\"><a></a></div><div style=\"display: none\" class=\"action first\"><div class=\"button\"><div class=\"bezel\"><p>&nbsp;</p></div></div></div><div style=\"display: none\" class=\"action second\"><div class=\"button\"><div class=\"bezel\"><p>&nbsp;</p></div></div></div></div>");;return buf.join("");
};

this["JST"]["common/video"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__video\"><iframe width=\"356\" height=\"267\" src=\"\" frameborder=\"0\" allowfullscreen=\"true\"></iframe><div class=\"caption\"><p></p></div></div>");;return buf.join("");
};

this["JST"]["craft_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("");
var quarryHref = '/craft/quarry'
var quarry
var quantumSuitHref = '/craft/quantumsuit_bodyarmor:quantumsuit_boots:quantumsuit_helmet:quantumsuit_leggings'
var ic2Href = '/browse/industrial_craft_2'
var solarPanelHref = '/craft/solar_panel_vi'
var solarFluxHref = '/browse/solar_flux'
buf.push("<div class=\"content view__craft_page\"><div class=\"left\"><div class=\"view__adsense\"></div></div><div class=\"right\"><section class=\"instructions\"><h2>Instructions</h2><div class=\"panel\"><p>Crafting Guide provides step-by-step instructions for thousands of items from Minecraft and many\npopular mods.  Just click \"Add an item...\" down below.</p><p>Not sure what you'd like to make?  Try one of these:</p><div class=\"items\"><a href=\"/craft/potion_of_strength_ii_1_30\"><img src=\"/data/minecraft/items/potion_of_strength_ii_1_30/icon.png\"/></a><a href=\"/craft/quarry\"><img src=\"/data/buildcraft/items/quarry/icon.png\"/></a><a href=\"/craft/quantumsuit_bodyarmor:quantumsuit_boots:quantumsuit_helmet:quantumsuit_leggings\"><img src=\"/data/ic2_classic/items/quantumsuit_helmet/icon.png\"/></a><a href=\"/craft/solar_panel_vi\"><img src=\"/data/solar_flux/items/solar_panel_vi/icon.png\"/></a><a href=\"/craft/crystal_chest\"><img src=\"/data/iron_chests/items/crystal_chest/icon.png\"/></a><a href=\"/craft/digital_miner\"><img src=\"/data/mekanism/items/digital_miner/icon.png\"/></a><a href=\"/craft/2.tesseract\"><img src=\"/data/thermal_expansion/items/tesseract/icon.png\"/></a></div></div></section><section class=\"want\"><h2>Items to Make</h2><div class=\"panel\"><div class=\"view__inventory large editable\"></div></div></section><section class=\"have\"><h2>Already in Inventory</h2><div class=\"panel\"><div class=\"view__inventory large editable\"></div></div></section><section class=\"view__craftsman_working\"></section><section class=\"need\"><h2>Need to Gather</h2><div class=\"panel\"><div class=\"view__inventory large\"></div></div></section><section class=\"steps\"><h2>Steps</h2><div class=\"panel\"></div></section></div></div>");;return buf.join("");
};

this["JST"]["craft_page/craftsman_working"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__item_group section\"><div class=\"content\"><div class=\"waiting\"><img src=\"/images/wait.gif\"/></div><div class=\"message\"><p></p></div><div class=\"count\"><p></p></div></div></div>");;return buf.join("");
};

this["JST"]["craft_page/step"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__step\"><h3></h3><div class=\"main_content\"><div class=\"view__inventory\"></div><div class=\"view__recipe\"></div></div><div class=\"buttons\"><div class=\"button complete\"><div class=\"bezel\"><p>complete step</p></div></div><div class=\"button tool\"><div class=\"bezel\"><p>make this tool</p></div></div></div></div>");;return buf.join("");
};

this["JST"]["feedback"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__feedback\"><div class=\"form-content\"><input name=\"name\" placeholder=\"name (optional)\"/><input name=\"email\" placeholder=\"email (optional)\"/><label name=\"comment\">Comment:</label><textarea name=\"comment\"></textarea><div class=\"error\"><p>Sending failed. Please try again later.</p></div><div class=\"button send\"><div class=\"bezel\"><p>send</p></div></div></div><div class=\"tab\"><p>Feedback</p></div></div>");;return buf.join("");
};

this["JST"]["footer"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__footer\"><div class=\"divider top\"></div><div class=\"content\"><div class=\"left\"><h2>About</h2><p>Crafting Guide gives step-by-step instructions for making anything in Minecraft or its many mods. Just\nsay what you'd like to make, what you already have, it will do the rest, giving you a list of raw\nmaterials and instructions of which items to make in the proper order. You can even ask it to include\nthe materials and instructions for all the tools you'll need along the way!\n</p></div><div class=\"center\"><h2>Donate</h2><p>Crafting Guide is free for all, but if you find it helpful, donations in any amount are gratefully\naccepted.</p><div class=\"action\"><form action=\"https://www.paypal.com/cgi-bin/webscr\" method=\"post\" target=\"_top\" class=\"centered\"><input type=\"hidden\" name=\"cmd\" value=\"_s-xclick\"/><input type=\"hidden\" name=\"hosted_button_id\" value=\"GCB2TYZJYLAE6\"/><input type=\"image\" src=\"https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif\" border=\"0\" name=\"submit\" alt=\"PayPal - The safer, easier way to pay online!\"/><img src=\"https://www.paypalobjects.com/en_US/i/scr/pixel.gif\" width=\"1\" height=\"1\"/></form></div></div><div class=\"right\"><h2>Get Involved</h2><p>Crafting Guide is completely open-source, and you can help!  Whether you want to write a recipe book\n(all simple JSON), or implement new features, just head over to GitHub to get started.</p><div class=\"action\"><iframe src=\"http://ghbtns.com/github-btn.html?user=andrewminer&amp;repo=crafting-guide&amp;type=fork&amp;size=large\" allowtransparency=\"true\" frameborder=\"0\" scrolling=\"0\" width=\"100\" height=\"32\"></iframe></div></div></div><div class=\"divider bottom\"></div></div>");;return buf.join("");
};

this["JST"]["header"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__header\"><div class=\"top-row\"><a href=\"/\" class=\"logo\"><img src=\"/images/site-icon.png\"/></a><h1>Minecraft Crafting Guide</h1><div class=\"addthis_sharing_toolbox\"></div></div><div class=\"divider\"><div class=\"button craft\"><div class=\"bezel\"><p>Craft</p></div></div><div class=\"button browse\"><div class=\"bezel\"><p>Browse</p></div></div><div class=\"button news\"><div class=\"bezel\"><p>News</p></div></div><div class=\"button search\"><div class=\"bezel\"><p>Search</p></div></div><div class=\"button login\"><div class=\"bezel\"><p>Login</p></div></div></div><div class=\"breadcrumbs\"></div></div>");;return buf.join("");
};

this["JST"]["item_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"content view__item_page\"><div class=\"left\"><div class=\"view__adsense\"></div></div><div class=\"right\"><div class=\"about\"><div class=\"left\"><img/></div><div class=\"center\"><div class=\"title\"></div><a class=\"sourceMod\"></a><div class=\"button-row\"><div class=\"button craftingPlan\"><div class=\"bezel\"><p>View Crafting Plan</p></div></div></div></div><div class=\"right\"><p>Official Link:<a class=\"officialLink\">project page</a></p></div></div><section class=\"description view__markdown_section\"></section><section class=\"multiblock\"><h2>Multiblock Construction</h2><div class=\"panel\"><div class=\"view__multiblock_viewer\"></div></div></section><section class=\"recipes\"><h2>Recipes</h2><div class=\"panel\"></div></section><section class=\"videos\"><h2>Videos</h2><div class=\"panel\"></div></section><section class=\"view__item_group usedToMake\"></section><section class=\"view__item_group usedAsToolToMake\"></section><section class=\"view__item_group similar\"></section></div></div>");;return buf.join("");
};

this["JST"]["item_page/multiblock_viewer/multiblock"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__multiblock\"><img src=\"/images/outline.png\" class=\"outline\"/></div>");;return buf.join("");
};

this["JST"]["item_page/multiblock_viewer"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__multiblock_viewer\"><div class=\"left\"><h3>Complete Materials</h3><div class=\"view__inventory complete\"></div><h3>Current Layer</h3><div class=\"view__inventory layer\"></div></div><div class=\"right\"><div class=\"buttons\"><div class=\"button back\"><div class=\"bezel\"><p>back</p></div></div><div class=\"button next\"><div class=\"bezel\"><p>next</p></div></div></div><div class=\"view__multiblock\"></div><div class=\"caption\"><img/><p>&nbsp;</p></div></div></div>");;return buf.join("");
};

this["JST"]["item_page/recipe_detail"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__recipe_detail\"><div class=\"input\"><h3>Ingredients</h3><div class=\"view__inventory\"></div></div><div class=\"pattern\"><div class=\"view__crafting_grid\"></div><a class=\"tool\"></a></div><div class=\"output\"><h3>Produces</h3><div class=\"view__inventory\"></div></div></div>");;return buf.join("");
};

this["JST"]["login_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"content view__login_page\"><div class=\"ready-to-login\"><div class=\"left\"><h1>Login with GitHub</h1><p>Use your GitHub credentials to login and make changes on Crafting Guide. No GitHub account? Don't\nworry, you can get one for free. <a class=\"read-more\" href=\"#\">read more...</a>\n</p><div class=\"expandable-container read-more\"><div class=\"content\"><p>All changes you make on the site get submitted directly to our GitHub repo, and then published\nthrough the same automated deployment process as changes made by anyone else. That way, anyone\ncan contribute easily: whether developer or end user.</p><p>To log in, we redirect you to GitHub's site, and once you're signed in, they'll send you back\nhere. We never see your credentials, and only get the minimum set of permissions necessary to\nsubmit changes to the Crafting Guide repo on your behalf.</p><p>GitHub offers free accounts, so even if you don't already have one, you've got nothing to lose!\n</p></div></div><div class=\"actions\"><div class=\"button login\"><div class=\"bezel\"><p>Login with GitHub</p></div></div></div></div><div class=\"right\"><img src=\"/images/github-login-large.png\"/></div></div><div class=\"fetching-token\"><div class=\"left\"><h1>Completing log in...</h1><p>Hang on just a second while we finish logging you in...</p><div class=\"actions\"><img src=\"/images/wait.gif\"/></div></div><div class=\"right\"><img src=\"/images/github-login-large.png\"/></div></div><div class=\"invalid-callback\"><div class=\"left\"><h1>Oops!</h1><p>Sorry about that, but it looks like something went wrong with your GitHub login. Click the button below\nto try again, or use the Feedback button on the left to let us know, and we'll try to help.\n</p><div class=\"actions\"><div class=\"button login\"><div class=\"bezel\"><p>Login with GitHub</p></div></div></div></div><div class=\"right\"><img src=\"/images/github-login-large.png\"/></div></div><div class=\"logged-in\"><div class=\"left\"><h1>All set!</h1><p>You are logged in to CraftingGuide using the following GitHub account:</p><div class=\"user\"><div class=\"left\"><img/></div><div class=\"right\"><div class=\"name\"></div><div class=\"email\"></div></div></div><p class=\"withRedirect\">You will be redirected shortly.</p><div class=\"actions\"><div class=\"button logout\"><div class=\"bezel\"><p>Logout</p></div></div></div></div><div class=\"right\"><img src=\"/images/github-login-large.png\" class=\"float-right\"/></div></div><div class=\"server-down\"><div class=\"left\"><h1>Sorry!</h1><p>Our interactive editing service is down right now, but you can always submit a pull request over at the\n<a href=\"https://github.com/andrewminer/crafting-guide\">Crafting Guide GitHub Repository</a>. We'll\nhave the editing service back up soon!</p></div></div></div>");;return buf.join("");
};

this["JST"]["mod_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"content view__mod_page\"><div class=\"left\"><div class=\"view__adsense\"></div></div><div class=\"right\"><div class=\"about\"><div class=\"left\"><img/></div><div class=\"center\"><div class=\"title\"></div><div class=\"author\"></div><div class=\"description\"></div><div class=\"version\"><span>in my mod pack</span><select></select></div><div class=\"warning\"><b>PLEASE NOTE:</b> By selecting \"no\", crafting plans, search, and other features will ignore items\nand recipes from this mod.</div></div><div class=\"right\"><p>Official Links:</p><a class=\"homePage\">project page</a><a class=\"documentation\">documentation</a><a class=\"download\">download</a></div></div><section class=\"tutorials\"><h2>Tutorials</h2><div class=\"panel\"></div></section><div class=\"itemGroups\"></div></div></div>");;return buf.join("");
};

this["JST"]["mod_page/tutorial"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__tutorial\"><a><img/><p></p></a></div>");;return buf.join("");
};

this["JST"]["news_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"content view__news_page\"><div class=\"left\"><div class=\"view__adsense\"></div></div><div class=\"right\"><section><h3>2015-02-11</h3><div class=\"panel\"><p>I've been using <a href=\"/browse/modular_powersuits\">Modular PowerSuits</a> myself lately, and I\nnoticed that the newest version (finally!) comes with default recipes.  So, I've updated\nCrafting Guide to support both the newest vanilla recipes as well as those from Thermal\nExpansion.  You can switch back and forth on the <a href=\"/configure\">Configure</a> page.\n</p></div></section><section><h3>2015-02-09</h3><div class=\"panel\"><p>Back before the winter holidays, the extremely patient <a href=\"https://github.com/tdallmann\">\ntdallmann</a> completed support for <a href=\"/browse/hydraulicraft/\">Hydraulicraft</a>, and I'm\nafraid I'm only now getting it up on the site!  It looks like a neat mod based all around the\nscience of hydraulics with a nicely stepped set of devices to be made at each level. Many thanks\nto tddallmann for adding it to Crafting Guide!</p><p>I also received a submission for adding <a href=\"/browse/opencomputers\">OpenComputers</a> from\n<a href=\"https://github.com/yut23\">yut23</a>.  Should be a big help to those aspiring Minecraft\nprogrammers who want a bit more challege than is provided by <a href=\"/browse/computercraft\">\nComputerCraft</a>!  Thanks, yut23!\n</p></div></section><section><h3>2015-11-25</h3><div class=\"panel\"><p>With many thanks to <a href=\"https://github.com/pkmnfrk\">Mike Caron</a>, I'm pleased to announce\nsupport for <a href=\"/browse/storage_drawers\">Storage Drawers</a>!\n</p></div></section><section><h3>2015-12-13</h3><div class=\"panel\"><p>I'm super excited to announce that I've added full multi-block support for Crafting Guide! For\nexample, check out a <a href=\"/browse/big_reactors/5_core_passive_reactor\">5-Core Reactor</a>\nfrom Big Reactors, or the <a href=\"/browse/railcraft/steel_tank_5x5x5\">5x5x5 Steel Tank</a> from\nRailcraft.  I'm really pleased with how it turned out!\n</p></div></section><section><h3>2015-11-17</h3><div class=\"panel\"><p>And today, it's <a href=\"/browse/extra_cells\">Extra Cells</a>!\n</p></div></section><section><h3>2015-11-16</h3><div class=\"panel\"><p>It's a small one, but also highly requested...  Here's <a\nhref=\"/browse/computercraft\">ComputerCraft</a>!\n</p></div></section><section><h3>2015-11-14</h3><div class=\"panel\"><p>One more small one over the weekend... <a href=\"/browse/advanced_solar_panels\">Advanced Solar\nPanels</a> has been added to crafting guide!\n</p></div></section><section><h3>2015-11-14</h3><div class=\"panel\"><p>For a long while now, <a href=\"/browse/galacticraft\">Galacticraft</a> has been the most\nrequested mod, and it's finally here!  Enjoy!\n</p></div></section><section><h3>2015-11-10</h3><div class=\"panel\"><p>Remember me?  They guy who runs the site.  Yeah, I'm back, and with big news!  The site now has\na completely new crafting algorithm.  Instead of just taking the first crafting plan it comes up\nwith, it tries to compute every possible plan, rates them, and then picks the best one.  This\nalso clears up a lot of bugs related to the old algorithm.  The one drawback is that some items\ncan take a bit longer to compute than with the old way, but I think you'll find it's worth it!</p><p>On a personal note, I think it's clear that I don't have nearly as much time to dedicate to the\nsite as I used to.  That's mostly because I started a new job which keeps me away from working\non the site so much.  I hope to be able to get into a more regular pace now things my personal\nlife has settled down again.\n</p></div></section><section><h3>2015-07-25</h3><div class=\"panel\"><p>You may have noticed things have been very quiet with the site for the past month... well I'm\nafraid that's because I haven't been working on it.  Instead, I've been hunting for a new job.\nNow that I've got that all squared away (I'll be starting at Looker in Santa Cruz on Monday),\nI'll have nights and weekends to continue working on the site.  Thanks for being patient!\n</p></div></section><section><h3>2015-06-12</h3><div class=\"panel\"><p>Today I launched the second major part of the item description editor: image uploads! As you\nenter your description, use the markdown notation for an image <tt>  ![](image.png)  </tt> and a\nempty image preview will show up underneath the editor. Click the button to select an image from\nyour computer. Just be sure to keep the images to a reasonable size (< 750kB, and < 740px by\n600px).\n</p></div></section><section><h3>2015-05-13</h3><div class=\"panel\"><p>As of today, you can now add and edit item descriptions right on Crafting Guide. This feature is\nstarting small with just item descriptions, but eventually all the content on the site will be\neditable. All you need is a (free) GitHub account, and you're ready to go!</p><p>For those more comfortable with a regular text editor, all the content is still in GitHub under\nthe <a href=\"https://github.com/andrewminer/crafting-guide-data\">crafting-guide-data</a> repo.\nJust follow the instructions, and you can submit content via pull request instead of using the\nwebsite's editor.\n</p></div></section><section><h3>2015-04-30</h3><div class=\"panel\"><p>I've been working on a big new feature for a while now, but I didn't want to leave everyone\nwithout anything new for so long... So, I've just finished adding <a\nhref=\"/browse/minefactory_reloaded\">MineFactory Reloaded</a>! Enjoy!\n</p></div></section><section><h3>2015-04-20</h3><div class=\"panel\"><p>Okay... big changes on the crafting page! Instead of having four little boxes for the various\nparts of the crafting plan, the new page shows all the steps as one long list.  In addition, you\nget a lot more control over the plan. Now, you can even mark individual steps as complete to get\na new crafting plan which doesn't include those items.</p><p>As an example, let's say you're thinking about upgrading your <a\nhref=\"/browse/simply_jetpacks/reinforced_jetpack\">Reinforced Jetpack</a> to a shiny new <a\nhref=\"/browse/simply_jetpacks/resonant_jetpack\">Resonant Jetpack</a>, you can just mark off the\nstep for the Reinforced Jetpack, and get only the materials and steps for doing the upgrade.\nI'm really pleased with the new crafting page, and I think you're going to love it!\n</p></div></section><section><h3>2015-04-11</h3><div class=\"panel\"><p>I've just finished adding <a href=\"/browse/simply_jetpacks\">Simply Jetpacks</a> by Tonius.  It\nseems like a simple mod on the surface, but what with all the upgrades and technology tiers, it\ntakes an amazing <a href=\"/craft/flux_infused_jetplate\">87 steps</a> to make the highest-tier\njetpack!</p><p>I've also added <a href=\"/browse/solar_flux\">Solar Flux</a> by Nauktis. Again, another\ndeceptively simple mod, but the <a href=\"/browse/solar_flux/solar_panel_vi/\">most powerful solar\npanel</a> kicks out an impressive 4096 RF/t! I just hope your mine has been productive... among\nother things, you'll need 45 Diamonds, 110 Gold Ore, 1568 Copper Ore, and 6023 Iron Ore!</p></div></section></div></div>");;return buf.join("");
};

this["JST"]["tutorial_page"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"view__tutorial_page\"><div class=\"left\"><div class=\"view__adsense\"></div></div><div class=\"right\"><div class=\"about\"><div class=\"left\"><img/></div><div class=\"right\"><div class=\"title\"></div><div class=\"sourceMod\">a tutorial for <a></a></div><div class=\"officialLink\">from <a></a></div></div></div><div class=\"tutorial-sections\"></div><section class=\"videos\"><h2></h2><div class=\"panel\"><div class=\"video-container\"></div></div></section></div></div>");;return buf.join("");
};

if (typeof exports === 'object' && exports) {module.exports = this["JST"];}