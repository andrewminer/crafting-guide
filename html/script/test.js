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

module("CraftingNode"); ///////////////////////////////////////////////////////////////////////////////////////////////

test("create: simple", function() {
    var node = createCraftingNode(12, "Furnace", false, undefined, __sampleRecipeBooks);
    deepEqual(node.alternatives.length, 0);
    deepEqual(node.children.length, 0);
    deepEqual(node.count, 12);
    deepEqual(node.name, "Furnace");
    deepEqual(node.parentNode, undefined);
    deepEqual(node.recipe.name, "Furnace");
});

test("create: complex", function() {
    var node = createCraftingNode(1, "Iron Gear", false, undefined, __sampleRecipeBooks);
    deepEqual(node.name, "Iron Gear");
    deepEqual(node.children.length, 2);
    deepEqual(node.children[0].name, "Iron Ingot");
    deepEqual(node.children[1].name, "Stone Gear");

    node = node.children[1];
    deepEqual(node.name, "Stone Gear");
    deepEqual(node.children.length, 1);
    deepEqual(node.children[0].name, "Wooden Gear");

    node = node.children[0];
    deepEqual(node.name, "Wooden Gear");
    deepEqual(node.children.length, 1);
    deepEqual(node.children[0].name, "Stick");

    node = node.children[0];
    deepEqual(node.name, "Stick");
    deepEqual(node.recipe.input[0].name, "Birch Plank");
    deepEqual(node.alternatives.length, 2);
    deepEqual(node.alternatives[0].input[0].name, "Oak Plank");
    deepEqual(node.alternatives[1].input[0].name, "Spruce Plank");

    node = node.children[0];
    deepEqual(node.name, "Birch Plank");
    deepEqual(node.alternatives, []);
    deepEqual(node.children, []);
});

test("create: with tool", function() {
    var node = createCraftingNode(1, "Iron Ingot", true, undefined, __sampleRecipeBooks);
    deepEqual(node.alternatives.length, 0, JSON.stringify(node.alternatives));
    deepEqual(node.children.length, 1);
    deepEqual(node.children[0].name, "Furnace");
    deepEqual(node.name, "Iron Ingot");
});

test("craft: simple", function() {
    var node = createCraftingNode(1, "Furnace", false, undefined, __sampleRecipeBooks);
    var result = node.craft();

    deepEqual(result.inventory.materials["Furnace"], 1);
    deepEqual(result.inventory.length, 1);
    deepEqual(result.missingMaterials.materials["Cobblestone"], 8);
    deepEqual(result.missingMaterials.length, 1);
    deepEqual(result.stepList.length, 1);
    deepEqual(result.stepList[0].count, 1);
    deepEqual(result.stepList[0].name, "Furnace");

    node = createCraftingNode(2, "Furnace", false, undefined, __sampleRecipeBooks);
    result = node.craft();

    deepEqual(result.inventory.materials["Furnace"], 2, JSON.stringify(result.inventory));
    deepEqual(result.inventory.length, 1, JSON.stringify(result.inventory));

    deepEqual(result.missingMaterials.materials["Cobblestone"], 16);
    deepEqual(result.missingMaterials.length, 1);

    deepEqual(result.stepList.length, 1);
    deepEqual(result.stepList[0].count, 2);
    deepEqual(result.stepList[0].name, "Furnace");
});

test("craft: with initial inventory", function() {
    var inventory = createManifest();
    inventory.add(4, "Cobblestone");
    var result = createCraftingResult(inventory);
    var node = createCraftingNode(2, "Furnace", false, undefined, __sampleRecipeBooks);
    node.craft(result);

    deepEqual(result.inventory.materials["Furnace"], 2);
    deepEqual(result.inventory.length, 1);
    deepEqual(result.missingMaterials.materials["Cobblestone"], 12);
    deepEqual(result.missingMaterials.length, 1);
    deepEqual(result.stepList.length, 1);
    deepEqual(result.stepList[0].count, 2);
    deepEqual(result.stepList[0].name, "Furnace");
});

test("craft: no-op", function() {
    var inventory = createManifest();
    inventory.add(1, "Furnace");
    var result = createCraftingResult(inventory);
    var node = createCraftingNode(1, "Furnace", false, undefined, __sampleRecipeBooks);
    node.craft(result);

    deepEqual(result.inventory.materials["Furnace"], 1, JSON.stringify(result.inventory));
    deepEqual(result.inventory.length, 1, JSON.stringify(result.inventory));
    deepEqual(result.missingMaterials.length, 0, JSON.stringify(result.missingMaterials));
    deepEqual(result.stepList.length, 0, JSON.stringify(result.stepList));
});

test("craft: deep tree", function() {
    var node = createCraftingNode(1, "Iron Gear", false, undefined, __sampleRecipeBooks);
    var result = node.craft();

    deepEqual(result.inventory.materials["Iron Gear"], 1);
    deepEqual(result.inventory.materials["Birch Plank"], 2);
    deepEqual(result.inventory.length, 2, JSON.stringify(result));

    deepEqual(result.missingMaterials.materials["Birch Log"], 1);
    deepEqual(result.missingMaterials.materials["Cobblestone"], 4);
    deepEqual(result.missingMaterials.materials["Iron Ore"], 4);
    deepEqual(result.missingMaterials.materials["milli-coal"], 500);
    deepEqual(result.missingMaterials.length, 4);

    deepEqual(result.stepList[0].count, 4);
    deepEqual(result.stepList[0].name, "Iron Ingot");
    deepEqual(result.stepList[1].count, 4);
    deepEqual(result.stepList[1].name, "Birch Plank");
    deepEqual(result.stepList[2].count, 4);
    deepEqual(result.stepList[2].name, "Stick");
    deepEqual(result.stepList[3].count, 1);
    deepEqual(result.stepList[3].name, "Wooden Gear");
    deepEqual(result.stepList[4].count, 1);
    deepEqual(result.stepList[4].name, "Stone Gear");
    deepEqual(result.stepList[5].count, 1);
    deepEqual(result.stepList[5].name, "Iron Gear");
    deepEqual(result.stepList.length, 6);
});

test("craft: repeatedly craft ingredient", function() {
    var node = createCraftingNode(1, "Bookshelf", false, undefined, __sampleRecipeBooks);
    var result = node.craft();

    deepEqual(result.inventory.materials["Bookshelf"], 1, JSON.stringify(result.inventory));
    deepEqual(result.inventory.materials["Oak Plank"], 2, JSON.stringify(result.inventory));
    deepEqual(result.inventory.length, 2, JSON.stringify(result.inventory));

    deepEqual(result.missingMaterials.materials["Oak Log"], 2, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["Sugar Cane"], 9, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["Leather"], 3, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.length, 3, JSON.stringify(result.missingMaterials));

    deepEqual(result.stepList[0].count, 8, JSON.stringify(result.stepList));
    deepEqual(result.stepList[0].name, "Oak Plank", JSON.stringify(result.stepList));
    deepEqual(result.stepList[1].count, 9, JSON.stringify(result.stepList));
    deepEqual(result.stepList[1].name, "Paper", JSON.stringify(result.stepList));
    deepEqual(result.stepList[2].count, 3, JSON.stringify(result.stepList));
    deepEqual(result.stepList[2].name, "Book", JSON.stringify(result.stepList));
    deepEqual(result.stepList[3].count, 1, JSON.stringify(result.stepList));
    deepEqual(result.stepList[3].name, "Bookshelf", JSON.stringify(result.stepList));
    deepEqual(result.stepList.length, 4, JSON.stringify(result.stepList));
});

test("craft: same item used multiple places", function() {
    var node = createCraftingNode(1, "Mining Well", false, undefined, __sampleRecipeBooks);
    var result = node.craft();

    deepEqual(result.inventory.materials["Mining Well"], 1, JSON.stringify(result.inventory));
    deepEqual(result.inventory.materials["Stick"], 2, JSON.stringify(result.inventory));
    deepEqual(result.inventory.length, 2, JSON.stringify(result.inventory));

    deepEqual(result.missingMaterials.materials["Redstone"], 1, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["Iron Ore"], 13, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["milli-coal"], 1625, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["Cobblestone"], 4, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["Birch Log"], 1, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.length, 5, JSON.stringify(result.missingMaterials));

    deepEqual(result.stepList[0].count, 13, JSON.stringify(result.stepList));
    deepEqual(result.stepList[0].name, "Iron Ingot", JSON.stringify(result.stepList));
    deepEqual(result.stepList[1].count, 4, JSON.stringify(result.stepList));
    deepEqual(result.stepList[1].name, "Birch Plank", JSON.stringify(result.stepList));
    deepEqual(result.stepList[2].count, 8, JSON.stringify(result.stepList));
    deepEqual(result.stepList[2].name, "Stick", JSON.stringify(result.stepList));
    deepEqual(result.stepList[3].count, 1, JSON.stringify(result.stepList));
    deepEqual(result.stepList[3].name, "Iron Pickaxe", JSON.stringify(result.stepList));
    deepEqual(result.stepList[4].count, 1, JSON.stringify(result.stepList));
    deepEqual(result.stepList[4].name, "Wooden Gear", JSON.stringify(result.stepList));
    deepEqual(result.stepList[5].count, 1, JSON.stringify(result.stepList));
    deepEqual(result.stepList[5].name, "Stone Gear", JSON.stringify(result.stepList));
    deepEqual(result.stepList[6].count, 1, JSON.stringify(result.stepList));
    deepEqual(result.stepList[6].name, "Iron Gear", JSON.stringify(result.stepList));
    deepEqual(result.stepList[7].count, 1, JSON.stringify(result.stepList));
    deepEqual(result.stepList[7].name, "Mining Well", JSON.stringify(result.stepList));
    deepEqual(result.stepList.length, 8, JSON.stringify(result.stepList));
});

test("craft: multiple tools needed", function() {
    var node = createCraftingNode(1, "Iron Pickaxe", true, undefined, __sampleRecipeBooks);
    var result = node.craft();

    deepEqual(result.inventory.materials["Iron Pickaxe"], 1, JSON.stringify(result.inventory));
    deepEqual(result.inventory.materials["Birch Plank"], 2, JSON.stringify(result.inventory));
    deepEqual(result.inventory.materials["Stick"], 2, JSON.stringify(result.inventory));
    deepEqual(result.inventory.materials["Furnace"], 1, JSON.stringify(result.inventory));
    deepEqual(result.inventory.materials["Crafting Table"], 1, JSON.stringify(result.inventory));
    deepEqual(result.inventory.length, 5, JSON.stringify(result.inventory));

    deepEqual(result.missingMaterials.materials["Birch Log"], 2, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["Iron Ore"], 3, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["Cobblestone"], 8, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.materials["milli-coal"], 375, JSON.stringify(result.missingMaterials));
    deepEqual(result.missingMaterials.length, 4, JSON.stringify(result.missingMaterials));
});

test("copy", function() {
    var node = createCraftingNode(3, "Stick", false, undefined, __sampleRecipeBooks);
    var copiedNode = node.copy();

    deepEqual(copiedNode.alternatives.length, 2);
    deepEqual(copiedNode.children.length, 1);
    deepEqual(copiedNode.count, 3);
    deepEqual(copiedNode.name, "Stick");
    deepEqual(copiedNode.parentNode, undefined);
    deepEqual(copiedNode.recipe.name, "Stick");
    notStrictEqual(node.children[0], copiedNode.children[0]);
});

test("createNextAlternative", function() {
    var node = createCraftingNode(1, "Stick", false, undefined, __sampleRecipeBooks);
    deepEqual(node.alternatives.length, 2);

    var firstAlternate = node.createNextAlternative(__sampleRecipeBooks);
    var secondAlternate = firstAlternate.createNextAlternative(__sampleRecipeBooks);

    deepEqual(node.alternatives, []);
    deepEqual(node.name, "Stick");
    deepEqual(node.recipe.input[0].name, "Birch Plank");
    deepEqual(node.createNextAlternative(__sampleRecipeBooks), undefined);

    deepEqual(firstAlternate.alternatives, []);
    deepEqual(firstAlternate.name, "Stick");
    deepEqual(firstAlternate.recipe.input[0].name, "Oak Plank");
    deepEqual(firstAlternate.createNextAlternative(__sampleRecipeBooks), undefined);

    deepEqual(secondAlternate.alternatives, []);
    deepEqual(secondAlternate.name, "Stick");
    deepEqual(secondAlternate.recipe.input[0].name, "Spruce Plank");
    deepEqual(secondAlternate.createNextAlternative(__sampleRecipeBooks), undefined);
});

test("depthFirstTraversal", function() {
    var node = createCraftingNode(1, "Iron Gear", false, undefined, __sampleRecipeBooks);
    var expectedNames = ["Iron Ingot", "Birch Plank", "Stick", "Wooden Gear", "Stone Gear", "Iron Gear"];
    var names = [];

    node.depthFirstTraversal(function(node) { names.push(node.name); });
    deepEqual(names, expectedNames);
});

test("findNodeWithAlternatives", function() {
    var node = createCraftingNode(1, "Iron Gear", false, undefined, __sampleRecipeBooks);
    var nodeWithAlternatives = node.findNodeWithAlternatives();
    deepEqual(nodeWithAlternatives.name, "Stick");

    node = createCraftingNode(1, "Stick", false, undefined, __sampleRecipeBooks);
    nodeWithAlternatives = node.findNodeWithAlternatives();
    deepEqual(nodeWithAlternatives.name, "Stick");
});

test("getNodeAt", function() {
    var node = createCraftingNode(1, "Electronic Circuit", false, undefined, __sampleRecipeBooks);
    deepEqual(node.getNodeAt([0]).name, "Insulated Copper Cable");
    deepEqual(node.getNodeAt([1]).name, "Refined Iron");
    deepEqual(node.getNodeAt([0, 0]).name, "Copper Cable");
    deepEqual(node.getNodeAt([0, 1]).name, "Rubber");
    deepEqual(node.getNodeAt([0, 0, 0]).name, "Copper Ingot");
});

test("getPosition", function() {
    var node = createCraftingNode(1, "Electronic Circuit", false, undefined, __sampleRecipeBooks);
    deepEqual(node.getNodeAt([0]).getPosition(), [0]);
    deepEqual(node.getNodeAt([1]).getPosition(), [1]);
    deepEqual(node.getNodeAt([0, 0]).getPosition(), [0, 0]);
    deepEqual(node.getNodeAt([0, 1]).getPosition(), [0, 1]);
    deepEqual(node.getNodeAt([0, 0, 0]).getPosition(), [0, 0, 0]);
});

test("setNodeAt", function() {
    var ironGearNode = createCraftingNode(1, "Iron Gear", false, undefined, __sampleRecipeBooks);
    var furnaceNode = createCraftingNode(1, "Furnace", false, undefined, __sampleRecipeBooks);
    ironGearNode.setNodeAt([1, 0, 0], furnaceNode);

    deepEqual(ironGearNode.children[1].children[0].children[0].name, "Furnace");
    deepEqual(furnaceNode.parentNode, ironGearNode.children[1].children[0]);
});

module("CraftingPlan"); ///////////////////////////////////////////////////////////////////////////////////////////////

test("create: single complex plan", function() {
    var plan = createCraftingPlan(1, "Bookshelf", false, __sampleRecipeBooks);
    deepEqual(plan.count, 1);
    deepEqual(plan.recipeName, "Bookshelf");
    deepEqual(plan.alternatives.length, 1);
    deepEqual(plan.alternatives[0].getNodeAt([1, 0]).name, "Paper");
});

test("create: multiple simple plans", function() {
    var plan = createCraftingPlan(1, "Stick", false, __sampleRecipeBooks);
    deepEqual(plan.count, 1);
    deepEqual(plan.recipeName, "Stick");
    deepEqual(plan.alternatives[0].recipe.input[0].name, "Birch Plank");
    deepEqual(plan.alternatives[1].recipe.input[0].name, "Oak Plank");
    deepEqual(plan.alternatives[2].recipe.input[0].name, "Spruce Plank");
    deepEqual(plan.alternatives.length, 3);
});

test("create: multiple complex plans", function() {
    var plan = createCraftingPlan(1, "Iron Gear", false, __sampleRecipeBooks);
    var firstResult = plan.alternatives[0].craft();
    var secondResult = plan.alternatives[1].craft();
    var thirdResult = plan.alternatives[2].craft();

    deepEqual(firstResult.missingMaterials.materials["Birch Log"], 1, JSON.stringify(firstResult.missingMaterials));
    deepEqual(secondResult.missingMaterials.materials["Oak Log"], 1, JSON.stringify(secondResult.missingMaterials));
    deepEqual(thirdResult.missingMaterials.materials["Spruce Log"], 1, JSON.stringify(thirdResult.missingMaterials));
});

test("create: with infinite cycle plans", function() {
    var plan = createCraftingPlan(1, "Rubber Boots", true, __sampleRecipeBooks);

    deepEqual(plan.alternatives.length, 0, JSON.stringify(plan));
});

module("CraftingResult"); /////////////////////////////////////////////////////////////////////////////////////////////

test("create", function() {
    var result = createCraftingResult();
    deepEqual(result.inventory.length, 0);
    deepEqual(result.missingMaterials.length, 0);
    deepEqual(result.stepList.length, 0);

    var startingInventory = createManifest();
    startingInventory.add(1, "Furnace");
    startingInventory.add(10, "Iron Ingot");

    result = createCraftingResult(startingInventory);
    deepEqual(result.inventory.contains(1, "Furnace"), true);
    deepEqual(result.inventory.contains(10, "Iron Ingot"), true);
    deepEqual(result.missingMaterials.length, 0);
    deepEqual(result.stepList.length, 0);

    result.inventory.add(1, "Oak Log");
    deepEqual(startingInventory.materials["Oak Log"], undefined);

    startingInventory.removeAll();
    deepEqual(result.inventory.materials["Iron Ingot"], 10);
});

test("addCraftingResult", function() {
    var startingInventory = createManifest();
    startingInventory.add(10, "Furnace");
    var result = createCraftingResult(startingInventory);
    result.addMissingMaterial("Furnace");

    result.addCraftingResult(1, "Furnace");
    deepEqual(result.stepList.length, 1);
    deepEqual(result.stepList[0].name, "Furnace");
    deepEqual(result.stepList[0].count, 1);
    deepEqual(result.inventory.materials["Furnace"], 10);
    deepEqual(result.missingMaterials.contains(1, "Furnace"), false);

    result.addCraftingResult(3, "Bucket");
    deepEqual(result.stepList.length, 2, JSON.stringify(result.stepList));
    deepEqual(result.stepList[0].name, "Bucket", JSON.stringify(result.stepList));
    deepEqual(result.stepList[0].count, 3, JSON.stringify(result.stepList));
    deepEqual(result.inventory.materials["Bucket"], 3, JSON.stringify(result.inventory));

    result.addCraftingResult(10, "Furnace");
    deepEqual(result.stepList.length, 2);
    deepEqual(result.stepList[1].name, "Furnace");
    deepEqual(result.stepList[1].count, 11);
    deepEqual(result.inventory.materials["Furnace"], 20);
});

test("copy", function() {
    var result = createCraftingResult();
    result.addMissingMaterial("Oak Log");
    result.addCraftingResult(4, "Oak Plank");
    deepEqual(result.inventory.materials["Oak Plank"], 4);
    deepEqual(result.stepList[0].name, "Oak Plank");
    deepEqual(result.missingMaterials.materials["Oak Log"], 1);

    var copiedResult = result.copy();
    deepEqual(copiedResult.inventory.materials["Oak Plank"], 4);
    deepEqual(copiedResult.stepList[0].name, "Oak Plank");
    deepEqual(copiedResult.missingMaterials.materials["Oak Log"], 1);
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
    deepEqual(manifest.materials, {});
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

module("RecipeBook"); /////////////////////////////////////////////////////////////////////////////////////////////////

test("create", function() {
    var recipeBook = __sampleRecipeBooks[0];

    deepEqual(recipeBook.name, "Vanilla Recipes");
    deepEqual(recipeBook.description, "Crafting recipes from vanilla Minecraft");
    deepEqual(recipeBook.sourceUrl, "inline://vanilla");
    deepEqual(recipeBook.recipes.length, 12);
    deepEqual(recipeBook.recipes[3].name, "Furnace");
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

