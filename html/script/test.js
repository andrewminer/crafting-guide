// Fixtures ///////////////////////////////////////////////////////////////////////////////////////////////////////////

var __sampleRecipe =
    '{                                                                   ' +
    '    "output": [[1, "Cake"], [1, "Bucket"]],                         ' +
    '    "input": [[3, "Milk"], [2, "Sugar"], [3, "Wheat"], [1, "Egg"]], ' +
    '    "tools": ["Crafting Table"]                                     ' +
    '}                                                                   ';

var __vanillaRecipeBookSample =
    '{                                                             ' +
    '    "name": "Vanilla Recipes",                                ' +
    '    "description": "Crafting recipes from vanilla Minecraft", ' +
    '    "recipes": [                                              ' +
    '        {                                                     ' +
    '            "output": [[4, "Birch Plank"]],                   ' +
    '            "input": [[1, "Birch Log"]],                      ' +
    '            "tools": []                                       ' +
    '        }, {                                                  ' +
    '            "output": [[1, "Crafting Table"]],                ' +
    '            "input": [[4, "Birch Plank"]],                    ' +
    '            "tools": []                                       ' +
    '        }, {                                                  ' +
    '            "output": [[1, "Crafting Table"]],                ' +
    '            "input": [[4, "Oak Plank"]],                      ' +
    '            "tools": []                                       ' +
    '        }, {                                                  ' +
    '            "output": [[1, "Furnace"]],                       ' +
    '            "input": [[8, "Cobblestone"]],                    ' +
    '            "tools": ["Crafting Table"]                       ' +
    '        }, {                                                  ' +
    '            "output": [[1, "Iron Ingot"]],                    ' +
    '            "input": [[1, "Iron Ore"], [125, "milli-coal"]],  ' +
    '            "tools": ["Furnace"]                              ' +
    '        }, {                                                  ' +
    '            "output": [[4, "Oak Plank"]],                     ' +
    '            "input": [[1, "Oak Log"]],                        ' +
    '            "tools": []                                       ' +
    '        }, {                                                  ' +
    '            "output": [[4, "Stick"]],                         ' +
    '            "input": [[2, "Birch Plank"]],                    ' +
    '            "tools": []                                       ' +
    '        }, {                                                  ' +
    '            "output": [[4, "Stick"]],                         ' +
    '            "input": [[2, "Oak Plank"]],                      ' +
    '            "tools": []                                       ' +
    '        }, {                                                  ' +
    '            "output": [[1, "Book"]],                          ' +
    '            "input": [[1, "Leather"], [3, "Paper"]],          ' +
    '            "tools": []                                       ' +
    '        }, {                                                  ' +
    '            "output": [[1, "Bookshelf"]],                     ' +
    '            "input": [[6, "Oak Plank"], [3, "Book"]],         ' +
    '            "tools": ["Crafting Table"]                       ' +
    '         }, {                                                 ' +
    '             "output": [[3, "Paper"]],                        ' +
    '             "input": [[3, "Sugar Cane"]],                    ' +
    '             "tools": []                                      ' +
    '         }, {                                                 ' +
    '             "output": [[1, "Iron Pickaxe"]],                 ' +
    '             "input": [[3, "Iron Ingot"], [2, "Stick"]],      ' +
    '             "tools": []                                      ' +
    '        }                                                     ' +
    '    ]                                                         ' +
    '}                                                             ';

var __extraVanillaRecipeBookSample =
    '{                                                                   ' +
    '    "name": "Extra Vanilla Recipes",                                ' +
    '    "description": "Extra crafting recipes from vanilla Minecraft", ' +
    '    "recipes": [                                                    ' +
    '        {                                                           ' +
    '            "output": [[4, "Spruce Plank"]],                        ' +
    '            "input": [[1, "Spruce Log"]],                           ' +
    '            "tools": []                                             ' +
    '        }, {                                                        ' +
    '            "output": [[4, "Stick"]],                               ' +
    '            "input": [[2, "Spruce Plank"]],                         ' +
    '            "tools": []                                             ' +
    '        }, {                                                        ' +
    '            "output": [[1, "Crafting Table"]],                      ' +
    '            "input": [[4, "Spruce Plank"]],                         ' +
    '            "tools": []                                             ' +
    '        }                                                           ' +
    '    ]                                                               ' +
    '}                                                                   ';

var __buildCraftRecipeBookSample =
    '{                                                                                                 ' +
    '    "name": "BuildCraft",                                                                         ' +
    '    "description": "Crafting recipes from BuildCraft 3, by SpaceToad",                            ' +
    '    "recipes": [                                                                                  ' +
    '        {                                                                                         ' +
    '            "output": [[1, "Wooden Gear"]],                                                       ' +
    '            "input": [[4, "Stick"]],                                                              ' +
    '            "tools": ["Crafting Table"]                                                           ' +
    '        }, {                                                                                      ' +
    '            "output": [[1, "Stone Gear"]],                                                        ' +
    '            "input": [[4, "Cobblestone"], [1, "Wooden Gear"]],                                    ' +
    '            "tools": ["Crafting Table"]                                                           ' +
    '        }, {                                                                                      ' +
    '            "output": [[1, "Iron Gear"]],                                                         ' +
    '            "input": [[4, "Iron Ingot"], [1, "Stone Gear"]],                                      ' +
    '            "tools": ["Crafting Table"]                                                           ' +
    '        }, {                                                                                      ' +
    '            "output": [[1, "Mining Well"]],                                                       ' +
    '            "input": [[6, "Iron Ingot"], [1, "Iron Pickaxe"], [1, "Iron Gear"], [1, "Redstone"]], ' +
    '            "tools": ["Crafting Table"]                                                           ' +
    '        }                                                                                         ' +
    '    ]                                                                                             ' +
    '}                                                                                                 ';

var __industrialCraftRecipeBookSample =
    '{                                                                                           ' +
    '    "name": "Industrial Craft",                                                             ' +
    '    "description": "Crafting recipes from IndustrialCraft 2, by Alblaka (in progress)",     ' +
    '    "recipes": [                                                                            ' +
    '        {                                                                                   ' +
    '            "output": [[1, "Electronic Circuit"]],                                          ' +
    '            "input": [[6, "Insulated Copper Cable"], [2, "Redstone"], [1, "Refined Iron"]], ' +
    '            "tools": ["Crafting Table"]                                                     ' +
    '        }, {                                                                                ' +
    '            "output": [[1, "Insulated Copper Cable"]],                                      ' +
    '            "input": [[1, "Copper Cable"], [1, "Rubber"]],                                  ' +
    '            "tools": []                                                                     ' +
    '        }, {                                                                                ' +
    '            "output": [[6, "Copper Cable"]],                                                ' +
    '            "input": [[3, "Copper Ingot"]],                                                 ' +
    '            "tools": ["Crafting Table"]                                                     ' +
    '        }, {                                                                                ' +
    '            "output": [[1, "Copper Ingot"]],                                                ' +
    '            "input": [[1, "Copper Ore"], [125, "milli-coal"]],                              ' +
    '            "tools": ["Furnace"]                                                            ' +
    '        }, {                                                                                ' +
    '            "output": [[1, "Refined Iron"]],                                                ' +
    '            "input": [[1, "Iron Ingot"], [125, "milli-coal"]],                              ' +
    '            "tools": ["Furnace"]                                                            ' +
    '        }, {                                                                                ' +
    '            "output": [[1, "Rubber"]],                                                      ' +
    '            "input": [[1, "Resin"], [125, "milli-coal"]],                                   ' +
    '            "tools": ["Furnace"]                                                            ' +
    '        }, {                                                                                ' +
    '            "output": [[3, "Rubber"]],                                                      ' +
    '            "input": [[1, "Resin"]],                                                        ' +
    '            "tools": ["Extractor"]                                                          ' +
    '        }, {                                                                                ' +
    '            "output": [[1, "Extractor"]],                                                   ' +
    '            "input": [[4, "Tree Tap"], [1, "Machine Block"], [1, "Electronic Circuit"]],    ' +
    '            "tools": ["Crafting Table"]                                                     ' +
    '        }, {                                                                                ' +
    '            "output": [[1, "Machine Block"]],                                               ' +
    '            "input": [[8, "Refined Iron"]],                                                 ' +
    '            "tools": ["Crafting Table"]                                                     ' +
    '        }, {                                                                                ' +
    '            "output": [[1, "Tree Tap"]],                                                    ' +
    '            "input": [[5, "Oak Plank"]],                                                    ' +
    '            "tools": ["Crafting Table"]                                                     ' +
    '        }, {                                                                                ' +
    '            "output": [[1, "Rubber Boots"]],                                                ' +
    '            "input": [[6, "Rubber"], [1, "Wool"]],                                          ' +
    '            "tools": ["Crafting Table"]                                                     ' +
    '        }                                                                                   ' +
    '    ]                                                                                       ' +
    '}                                                                                           ';

var __sampleRecipeBooks = undefined;

QUnit.testStart(function(name, module) {
    __sampleRecipeBooks = [
        createRecipeBook("inline://vanilla", JSON.parse(__vanillaRecipeBookSample)),
        createRecipeBook("inline://extra", JSON.parse(__extraVanillaRecipeBookSample)),
        createRecipeBook("inline://buildcraft", JSON.parse(__buildCraftRecipeBookSample)),
        createRecipeBook("inline://industrialcraft", JSON.parse(__industrialCraftRecipeBookSample))
    ];
});


module("Extensions"); /////////////////////////////////////////////////////////////////////////////////////////////////

test("Array.copy", function() {
    var sample = [ "alpha", "bravo", "charlie" ];
    var copiedSample = sample.copy();
    deepEqual(sample, copiedSample);
    notStrictEqual(sample, copiedSample);

    sample.push("delta");
    notDeepEqual(sample, copiedSample);

    sample = [ createIngredient(1, "alpha"), createIngredient(2, "bravo"), createIngredient(3, "charlie") ];
    copiedSample = sample.copy();
    deepEqual(sample[0].name, copiedSample[0].name);
    deepEqual(sample[2].name, copiedSample[2].name);
    deepEqual(sample.length, copiedSample.length);
    notStrictEqual(sample, copiedSample);
});

test("Array.each", function() {
    var sample = ["a", "b", "c", "d"];

    var result = "";
    sample.each(function(element) { result += element; });
    deepEqual(result, "abcd");
});

test("Array.toString", function() {
    var sample = ["a", "b", ["c", "d", ["e", "f"], "g"], "h"];

    deepEqual(sample.toString(), "[a, b, [c, d, [e, f], g], h]");
    deepEqual(sample.toString("pretty"), "[\n    a,\n    b,\n    [\n        c,\n        d,\n        [\n            " +
        "e,\n            f\n        ],\n        g\n    ],\n    h\n]");

    var options = {"prefix": "<", "suffix": ">", "delimiter": "|"};
    deepEqual(sample.toString(options), "<a|b|<c|d|<e|f>|g>|h>");
});

module("Base Object"); ////////////////////////////////////////////////////////////////////////////////////////////////

test("eachProperty", function() {
    var sample = createBaseObject("BaseObject", {alpha: "a", bravo: "b", charlie: "c"});

    var result = {};
    sample.eachProperty(function(key, value) { result[key] = value; });
    
    deepEqual(result.alpha, "a");
    deepEqual(result.bravo, "b");
    deepEqual(result.charlie, "c");
});

module("Crafter"); ////////////////////////////////////////////////////////////////////////////////////////////////////


module("CraftingNode"); ///////////////////////////////////////////////////////////////////////////////////////////////

test("create: simple", function() {
    var node = createCraftingNode("Furnace", {count: 12, recipeBooks: __sampleRecipeBooks});

    deepEqual(node.choices.length, 1);
    deepEqual(node.choices[0].length, 1);
    deepEqual(node.choices[0][0].recipe.name, "Furnace");
    deepEqual(node.count, 12);
    deepEqual(node.includeTools, false);
    deepEqual(node.inventory.length, 0);
    deepEqual(node.materials.length, 0);
    deepEqual(node.parentNode, undefined);
    deepEqual(node.recipe, undefined);
});

test("create: multiple alternatives", function() {
    var node = createCraftingNode("Stick", {recipeBooks: __sampleRecipeBooks});

    deepEqual(node.choices.length, 1);
    deepEqual(node.choices[0].length, 3);
    deepEqual(node.choices[0][0].recipe.input[0].name, "Birch Plank");
    deepEqual(node.choices[0][1].recipe.input[0].name, "Oak Plank");
    deepEqual(node.choices[0][2].recipe.input[0].name, "Spruce Plank");
    deepEqual(node.count, 1);
});

test("expandChoices: root node with single choice", function() {
    var node = createCraftingNode("Furnace", {recipeBooks: __sampleRecipeBooks});
    node.expandChoices();
    deepEqual(node.children.length, 1);

    var child = node.children[0];
    deepEqual(child.choices.length, 0);
    deepEqual(child.count, 1);
    deepEqual(child.inventory.materials["Furnace"], 1);
    deepEqual(child.materials.materials["Cobblestone"], 8);
    deepEqual(child.parentNode, node);
    deepEqual(child.recipe.name, "Furnace");
});

test("expandChoices: root node with multiple choices", function() {
    var node = createCraftingNode("Stick", {recipeBooks: __sampleRecipeBooks});
    node.expandChoices();
    deepEqual(node.children.length, 3);

    deepEqual(node.children[0].recipe.input[0].name, "Birch Plank", node.children[0]);
    deepEqual(node.children[0].outcome, "make", node.children[0]);
    deepEqual(node.children[1].recipe.input[0].name, "Oak Plank", node.children[1]);
    deepEqual(node.children[1].outcome, "make", node.children[1]);
    deepEqual(node.children[2].recipe.input[0].name, "Spruce Plank", node.children[2]);
    deepEqual(node.children[2].outcome, "make", node.children[2]);
});

test("expandChoices: internal node", function() {
    var root = createCraftingNode("Iron Gear", {recipeBooks: __sampleRecipeBooks});
    root.expandChoices();
    var ironGear = root.children[0];
    ironGear.expandChoices();
    var stoneGear = ironGear.children[1];
    stoneGear.expandChoices();

    deepEqual(stoneGear.choices.length, 0, stoneGear.choices);
    deepEqual(stoneGear.children.length, 2, stoneGear.children);
    deepEqual(stoneGear.children[0].recipe.name, "Iron Ingot");
    deepEqual(stoneGear.children[1].recipe.name, "Wooden Gear");
    deepEqual(stoneGear.inventory.length, 1, stoneGear.inventory);
    deepEqual(stoneGear.inventory.countOf("Iron Gear"), 1, stoneGear.inventory);
    deepEqual(stoneGear.materials.length, 3, stoneGear.materials);
    deepEqual(stoneGear.materials.countOf("Iron Ingot"), 4, stoneGear.materials);
    deepEqual(stoneGear.materials.countOf("Cobblestone"), 4, stoneGear.materials);
    deepEqual(stoneGear.materials.countOf("Wooden Gear"), 1, stoneGear.materials);
    deepEqual(stoneGear.outcome, "use");
});

test("expandFully: simple recipe", function() {
    var root = createCraftingNode("Stick", {recipeBooks: __sampleRecipeBooks});
    root.expandFully();
    var birchPlank = root.children[0].children[0];
    var oakPlank = root.children[1].children[0];
    var sprucePlank = root.children[2].children[0];

    deepEqual(birchPlank.recipe.name, "Birch Plank", birchPlank.toString());
    deepEqual(oakPlank.recipe.name, "Oak Plank", oakPlank.toString());
    deepEqual(sprucePlank.recipe.name, "Spruce Plank", sprucePlank.toString());
});

test("expandFully: complex recipe", function() {
    var root = createCraftingNode("Iron Gear", {recipeBooks: __sampleRecipeBooks});
    root.expandFully();

    var ironGear = root.children[0];
    var ironIngot = ironGear.children[0];
    var stoneGear = ironIngot.children[0];
    var woodenGear = stoneGear.children[0];
    var stick = woodenGear.children[0];
    var plank = stick.children[0];

    deepEqual(plank.recipe.name, "Birch Plank", plank);
    deepEqual(plank.inventory.length, 2, plank.inventory);
    deepEqual(plank.inventory.countOf("Birch Plank"), 2, plank.inventory);
    deepEqual(plank.inventory.countOf("Iron Gear"), 1, plank.inventory);
    deepEqual(plank.materials.length, 4, plank.inventory);
    deepEqual(plank.materials.countOf("Birch Log"), 1, plank.materials);
    deepEqual(plank.materials.countOf("Cobblestone"), 4, plank.materials);
    deepEqual(plank.materials.countOf("Iron Ore"), 4, plank.materials);
    deepEqual(plank.materials.countOf("milli-coal"), 500, plank.materials);

    stoneGear = ironGear.children[1];
    woodenGear = stoneGear.children[1];
    stick = woodenGear.children[3];
    plank = stick.children[1];
    ironIngot = plank.children[0];

    deepEqual(ironIngot.recipe.name, "Iron Ingot", ironIngot);
    deepEqual(ironIngot.inventory.length, 2, ironIngot.inventory);
    deepEqual(ironIngot.inventory.countOf("Spruce Plank"), 2, ironIngot.inventory);
    deepEqual(ironIngot.inventory.countOf("Iron Gear"), 1, ironIngot.inventory);
    deepEqual(ironIngot.materials.length, 4, ironIngot.inventory);
    deepEqual(ironIngot.materials.countOf("Spruce Log"), 1, ironIngot.materials);
    deepEqual(ironIngot.materials.countOf("Cobblestone"), 4, ironIngot.materials);
    deepEqual(ironIngot.materials.countOf("Iron Ore"), 4, ironIngot.materials);
    deepEqual(ironIngot.materials.countOf("milli-coal"), 500, ironIngot.materials);
});

test("expandFully: simple recipe with tools", function() {
    var root = createCraftingNode("Furnace", {recipeBooks: __sampleRecipeBooks, includeTools: true});
    root.expandFully();

    var furnace = root.children[0];
    var craftingTable = furnace.children[0];
    var birchPlank = craftingTable.children[0];
    
    deepEqual(furnace.recipe.name, "Furnace", furnace);
    deepEqual(craftingTable.recipe.name, "Crafting Table", craftingTable);
    deepEqual(birchPlank.recipe.name, "Birch Plank", birchPlank);
    deepEqual(birchPlank.materials.length, 2, birchPlank.materials);
    deepEqual(birchPlank.materials.countOf("Cobblestone"), 8, birchPlank.materials);
    deepEqual(birchPlank.materials.countOf("Birch Log"), 1, birchPlank.materials);
    deepEqual(birchPlank.inventory.length, 2, birchPlank.inventory);
    deepEqual(birchPlank.inventory.countOf("Furnace"), 1, birchPlank.inventory);
    deepEqual(birchPlank.inventory.countOf("Crafting Table"), 1, birchPlank.inventory);
});

test("generateCraftingPlans: simple", function() {
    var node = createCraftingNode("Furnace", {recipeBooks: __sampleRecipeBooks});
    node.expandFully();
    plans = node.generateCraftingPlans();

    deepEqual(plans.length, 1, plans);
    deepEqual(plans[0].stepList.length, 1, plans[0]);
    deepEqual(plans[0].stepList[0].count, 1, plans[0].stepList[0]);
    deepEqual(plans[0].stepList[0].name, "Furnace", plans[0].stepList[0]);
});

test("generateCraftingPlan: simple with tools", function() {
    var node = createCraftingNode("Furnace", {recipeBooks: __sampleRecipeBooks, includeTools: true});
    node.expandFully();
    plans = node.generateCraftingPlans(); 

    deepEqual(plans.length, 3, plans);
    deepEqual(plans[0].stepList.length, 3, plans[0]);
    deepEqual(plans[0].stepList[0].count, 4, plans[0].stepList[0]);
    deepEqual(plans[0].stepList[0].name, "Birch Plank", plans[0].stepList[0]);
    deepEqual(plans[0].stepList[1].count, 1, plans[0].stepList[0]);
    deepEqual(plans[0].stepList[1].name, "Crafting Table", plans[0].stepList[0]);
    deepEqual(plans[0].stepList[2].count, 1, plans[0].stepList[0]);
    deepEqual(plans[0].stepList[2].name, "Furnace", plans[0].stepList[0]);
});

test("generateCraftingPlan: complex", function() {
    var node = createCraftingNode("Iron Gear", {recipeBooks: __sampleRecipeBooks});
    node.expandFully();
    plans = node.generateCraftingPlans();

    deepEqual(plans.length, 15);
    deepEqual(plans[0].materials.countOf("Birch Log"), 1, plans[0].materials);
    deepEqual(plans[1].materials.countOf("Oak Log"), 1, plans[0].materials);
    deepEqual(plans[2].materials.countOf("Spruce Log"), 1, plans[0].materials);
});

module("Ingredient"); /////////////////////////////////////////////////////////////////////////////////////////////////

test("create", function() {
    var ingredient = createIngredient(12, "Furnace");
    deepEqual(ingredient.count, 12);
    deepEqual(ingredient.name, "Furnace");
});

test("copy", function() {
    var ingredient = createIngredient(12, "Furnace");
    var copiedIngredient = ingredient.copy();
    deepEqual(copiedIngredient.count, 12);
    deepEqual(copiedIngredient.name, "Furnace");
});

module("Manifest"); ///////////////////////////////////////////////////////////////////////////////////////////////////

test("create", function() {
    var manifest = createManifest();
    deepEqual(manifest.materials.strip(), {});
});

test("add / contains", function() {
    var manifest = createManifest();
    deepEqual(manifest.contains(1, "Furnace"), false);

    manifest.add(1, "Furnace");
    deepEqual(manifest.contains(1, "Furnace"), true);
    deepEqual(manifest.contains(2, "Furnace"), false);

    manifest.add(3, "Furnace");
    manifest.add(10, "Iron Ingot");
    deepEqual(manifest.contains(1, "Furnace"), true);
    deepEqual(manifest.contains(4, "Furnace"), true);
    deepEqual(manifest.contains(5, "Furnace"), false);
    deepEqual(manifest.contains(9, "Iron Ingot"), true);
    deepEqual(manifest.contains(10, "Iron Ingot"), true);
    deepEqual(manifest.contains(11, "Iron Ingot"), false);
});

test("addAll", function() {
    var manifest = createManifest();
    manifest.add(1, "Stick");
    manifest.add(2, "Oak Plank");
    manifest.add(3, "Iron Ingot");

    var manifest2 = createManifest();
    manifest2.addAll(manifest);

    deepEqual(manifest2.length, 3, manifest2.toString());
    deepEqual(manifest2.materials["Stick"], 1, manifest2.toString());
    deepEqual(manifest2.materials["Oak Plank"], 2, manifest2.toString());
    deepEqual(manifest2.materials["Iron Ingot"], 3, manifest2.toString());
});

test("contains", function() {
    var manifest = createManifest();
    manifest.add(3, "Iron Ingot");

    deepEqual(manifest.contains(0, "Iron Ingot"), true);
    deepEqual(manifest.contains(1, "Iron Ingot"), true);
    deepEqual(manifest.contains(2, "Iron Ingot"), true);
    deepEqual(manifest.contains(3, "Iron Ingot"), true);
    deepEqual(manifest.contains(4, "Iron Ingot"), false);

    manifest.remove(1, "Iron Ingot");
    manifest.remove(1, "Iron Ingot");
    manifest.remove(1, "Iron Ingot");
    deepEqual(manifest.contains(0, "Iron Ingot"), true);
    deepEqual(manifest.contains(1, "Iron Ingot"), false);
});

test("copy", function() {
    var manifest = createManifest();
    manifest.add(10, "Furnace", JSON.stringify(manifest));
    manifest.add(10, "Iron Ingot", JSON.stringify(manifest));
    deepEqual(manifest.materials["Furnace"], 10, JSON.stringify(manifest));
    deepEqual(manifest.materials["Iron Ingot"], 10, JSON.stringify(manifest));
    deepEqual(manifest.length, 2, JSON.stringify(manifest));

    var copiedManifest = manifest.copy();
    deepEqual(copiedManifest.materials["Furnace"], 10, JSON.stringify(copiedManifest));
    deepEqual(copiedManifest.materials["Iron Ingot"], 10, JSON.stringify(copiedManifest));
    deepEqual(copiedManifest.length, 2, JSON.stringify(copiedManifest));
});

test("remove", function() {
    var manifest = createManifest();
    manifest.add(10, "Furnace");
    manifest.add(10, "Iron Ingot");
    deepEqual(manifest.materials["Furnace"], 10);
    deepEqual(manifest.materials["Iron Ingot"], 10);

    manifest.remove(1, "Furnace");
    deepEqual(manifest.materials["Furnace"], 9);
    deepEqual(manifest.materials["Iron Ingot"], 10);

    manifest.remove(9, "Furnace");
    deepEqual(manifest.materials["Furnace"], undefined);
    deepEqual(manifest.materials["Iron Ingot"], 10);

    throws(
        function() { manifest.remove(12, "Iron Ingot"); },
        "Only 10 Iron Ingot, cannot remove 12",
        JSON.stringify(manifest)
    );
    deepEqual(manifest.materials["Iron Ingot"], 10);

    throws(
        function() { manifest.remove(1, "Jellybean"); },
        "No Jellybean, cannot remove 1",
        JSON.stringify(manifest)
    );
    deepEqual(manifest.materials["Iron Ingot"], 10);
});

test("removeAll", function() {
    var manifest = createManifest();
    manifest.add(10, "Furnace");
    manifest.add(10, "Iron Ingot");
    deepEqual(manifest.materials["Furnace"], 10);
    deepEqual(manifest.materials["Iron Ingot"], 10);

    manifest.removeAll();
    deepEqual(manifest.materials["Furnace"], undefined);
    deepEqual(manifest.materials["Iron Ingot"], undefined);
});

module("Recipe"); /////////////////////////////////////////////////////////////////////////////////////////////////////

test("create", function() {
    var recipe = createRecipe(JSON.parse(__sampleRecipe));

    deepEqual(recipe.name, "Cake");
    deepEqual(recipe.output.length, 2);
    deepEqual(recipe.input.length, 4);
    deepEqual(recipe.tools, ["Crafting Table"]);
});

test("copy", function() {
    var recipe = createRecipe(JSON.parse(__sampleRecipe));
    var recipe2 = recipe.copy();

    notStrictEqual(recipe, recipe2);

    deepEqual(recipe2.name, "Cake");
    deepEqual(recipe2.output.length, 2);
    deepEqual(recipe2.input.length, 4);
    deepEqual(recipe2.tools, ["Crafting Table"]);
});

test("toString", function() {
    var recipe = createRecipe(JSON.parse(__sampleRecipe));
    var expected = "Makes 1 Cake, 1 Bucket from 3 Milk, 2 Sugar, 3 Wheat, 1 Egg using Crafting Table";
    deepEqual(recipe.toString(), expected)
});

module("RecipeBook"); /////////////////////////////////////////////////////////////////////////////////////////////////

test("create", function() {
    var recipeBook = __sampleRecipeBooks[0];

    deepEqual(recipeBook.name, "Vanilla Recipes");
    deepEqual(recipeBook.description, "Crafting recipes from vanilla Minecraft");
    deepEqual(recipeBook.sourceUrl, "inline://vanilla");
    deepEqual(recipeBook.length, 12);
    deepEqual(recipeBook.recipes[3].name, "Furnace");
});

test("addRecipe", function() {
    var recipeBook = createRecipeBook();
    deepEqual(recipeBook.length, 0);

    recipeBook.addRecipe(__sampleRecipeBooks[0].recipes[1]);
    deepEqual(recipeBook.length, 1);
    deepEqual(recipeBook.recipes[0].name, "Crafting Table");
    deepEqual(recipeBook.recipes[0].input[0].name, "Birch Plank");

    recipeBook.addRecipe(__sampleRecipeBooks[0].recipes[2]);
    deepEqual(recipeBook.length, 2);
    deepEqual(recipeBook.recipes[1].name, "Crafting Table");
    deepEqual(recipeBook.recipes[1].input[0].name, "Oak Plank");

    recipeBook.addRecipe(__sampleRecipeBooks[0].recipes[1]);
    deepEqual(recipeBook.length, 2);
});

test("findAllRecipes", function() {
    var recipeBook = __sampleRecipeBooks[0];
    var recipes = undefined;

    recipes = recipeBook.findAllRecipes("Furnace");
    deepEqual(recipes.length, 1);
    deepEqual(recipes[0].name, "Furnace");

    recipes = recipeBook.findAllRecipes("Stick");
    deepEqual(recipes.length, 2);
    deepEqual(recipes[0].input[0].name, "Birch Plank");
    deepEqual(recipes[1].input[0].name, "Oak Plank");

    recipes = recipeBook.findAllRecipes("iRoN INGot");
    deepEqual(recipes.length, 1);
    deepEqual(recipes[0].name, "Iron Ingot");

    recipes = recipeBook.findAllRecipes("Jellybean");
    deepEqual(recipes.length, 0);
});

test("getAllRecipeNames", function() {
    var names = __sampleRecipeBooks[1].getAllRecipeNames();
    deepEqual(names, ["Crafting Table", "Spruce Plank", "Stick"]);
});

test("hasRecipe", function() {
    var recipeBook = __sampleRecipeBooks[0];

    deepEqual(recipeBook.hasRecipe("Furnace"), true);
    deepEqual(recipeBook.hasRecipe("Crafting Table"), true);
    deepEqual(recipeBook.hasRecipe("IRon InGoT"), true);
    deepEqual(recipeBook.hasRecipe("Jellybean"), false);
});

module("RecipeBook (globals)"); ///////////////////////////////////////////////////////////////////////////////////////

test("hasRecipe", function() {
    var recipeBooks = __sampleRecipeBooks;
    
    deepEqual(hasRecipe("Furnace", recipeBooks), true);
    deepEqual(hasRecipe("Crafting Table", recipeBooks), true);
    deepEqual(hasRecipe("irON inGot", recipeBooks), true);
    deepEqual(hasRecipe("Wooden Gear", recipeBooks), true);
    deepEqual(hasRecipe("Jellybean", recipeBooks), false);
});

test("findAllRecipes", function() {
    var recipeBooks = __sampleRecipeBooks;
    var recipes = undefined;

    recipes = findAllRecipes("Furnace", recipeBooks);
    deepEqual(recipes.length, 1);
    deepEqual(recipes[0].name, "Furnace");

    recipes = findAllRecipes("Stick", recipeBooks);
    deepEqual(recipes.length, 3);
    deepEqual(recipes[0].input[0].name, "Birch Plank");
    deepEqual(recipes[1].input[0].name, "Oak Plank");
    deepEqual(recipes[2].input[0].name, "Spruce Plank");

    recipes = findAllRecipes("IRON ingot", recipeBooks);
    deepEqual(recipes.length, 1);
    deepEqual(recipes[0].name, "Iron Ingot");

    recipes = findAllRecipes("Wooden Gear", recipeBooks);
    deepEqual(recipes.length, 1);
    deepEqual(recipes[0].name, "Wooden Gear");
});

test("getAllRecipeNames", function() {
    var recipeBooks = [__sampleRecipeBooks[1], __sampleRecipeBooks[2]];
    var names = getAllRecipeNames(recipeBooks);
    deepEqual(names,
        ["Crafting Table", "Iron Gear", "Mining Well", "Spruce Plank", "Stick", "Stone Gear", "Wooden Gear"]);
});

