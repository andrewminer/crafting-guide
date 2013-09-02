// Constants //////////////////////////////////////////////////////////////////////////////////////////////////////////

var ERROR_DISPLAY_DURATION = 10000; // ms
var FADE_DURATION = 250; // ms
var SLIDE_DURATION = 600; // ms

// Global Variables ///////////////////////////////////////////////////////////////////////////////////////////////////

var __inventory = createManifest();
var __loadingCount = 0;
var __recipeBooks = [];
var __toolsIncluded = false;

// Extensions /////////////////////////////////////////////////////////////////////////////////////////////////////////

Array.prototype.copy = function(copyFunction) {
    var result = [];
    for (var i = 0; i < this.length; i++) {
        if (copyFunction !== undefined) {
            result[i] = copyFunction(this[i]);
        } else if (typeof(this[i].copy) === "function") {
            result[i] = this[i].copy();
        } else {
            result[i] = this[i];
        }
    }
    return result;
};

Array.prototype.toHtml = function(delimiter) {
    var result = "";
    var needsDelimiter = false;
    for (var i = 0; i < this.length; i++) {
        if (needsDelimiter) result += delimiter;
        result += (typeof(this[i].toHtml) === "function") ? this[i].toHtml() : this[i].toString();
    }
    return result;
}

// UI Functions ///////////////////////////////////////////////////////////////////////////////////////////////////////

$(function() {
    $("#recipe_book_load_button").click(onRecipeLoadButtonClicked);
    $("#crafting_count").change(onCraftingSelectorChanged);
    $("#tools_included").change(onIncludeToolsChanged);
    $("#crafting_selector").focus(onCraftingSelectorFocused);
    $("#inventory").keyup(onInventoryChanged);

    loadRecipeBook("data/vanilla.json");
    loadRecipeBook("data/buildcraft.json");
    loadRecipeBook("data/industrial_craft.json");
});

function onCraftingSelectorChanged() {
    var recipeName = $("#crafting_selector").val();
    var count = parseInt($("#crafting_count option:selected").val());
    if (count === undefined) return;


    if (! hasRecipe(recipeName)) {
        $("#crafting_output").slideUp(SLIDE_DURATION);
    } else {
        var plan = createCraftingPlan(count, recipeName);
        var result = createCraftingResult(__inventory);
        plan.alternatives[0].craft(result);

        $("#missing_materials").html(result.missingMaterials.toHtml());
        $("#crafted_items").html(formatStepList(result.stepList));
        $("#leftover_materials").html(result.inventory.toHtml());
        $("#crafting_output").slideDown(SLIDE_DURATION);
    }

    updatePageState(count, recipeName);
}

function onCraftingSelectorFocused() {
    $("#crafting_selector").autocomplete("search");
}

function onIncludeToolsChanged() {
    __toolsIncluded = $("#tools_included").is(":checked");
    onCraftingSelectorChanged()
}

function onInventoryChanged() {
    __inventory.removeAll();

    var inventoryText = $("#inventory").val();
    if (inventoryText) {
        var inventoryLines = inventoryText.split("\n");
        for (var i = 0; i < inventoryLines.length; i++) {
            var line = inventoryLines[i].trim();
            var match = /^([0-9]+)(.*)$/.exec(line);

            var count = (match) ? parseInt(match[1]) : 1;
            var itemName = (match) ? match[2].trim() : line;

            if (itemName.length > 0) {
                __inventory.add(count, itemName);
            }
        }
    }
    onCraftingSelectorChanged();
}

function onRecipeBookLoaded() {
    if (__loadingCount > 0 || __recipeBooks.length === 0) {
        $("#crafting").fadeOut(FADE_DURATION);
    } else if (__loadingCount === 0 && __recipeBooks.length > 0) {
        updateCraftingSelector();
        parseUrlParameters();
        $("#crafting").fadeIn(FADE_DURATION);
    }
}

function onRecipeLoadButtonClicked() {
    $("#reipebook_load_button").attr("disabled", true);
    loadRecipeBook($("#recipe_book_url").val(), function() {
        $("#recipe_book_url").val("");
        $("#reipebook_load_button").removeAttr("disabled");
    });
}

// UI Helper Functions ////////////////////////////////////////////////////////////////////////////////////////////////

function loadRecipeBook(recipeBookUrl) {
    __loadingCount++;
    $.ajax({
        url: recipeBookUrl,
        dataType: "text",
        success: function(text) {
            try {
                var recipeBook = createRecipeBook(recipeBookUrl, $.parseJSON(text));
                __recipeBooks.push(recipeBook);

                recipeBook.toHtml().insertBefore($("#recipe_book_table tr").last());
            } catch (e) {
                $("#load_error").html(e);
                $("#load_error").slideDown(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).slideUp(FADE_DURATION);
            }
        },
        error: function(response, status, error) {
            $("#load_error").html(status + ": " + error);
            $("#load_error").slideDown(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).slideUp(FADE_DURATION);
        },
        complete: function() {
            __loadingCount--;
            onRecipeBookLoaded();
        }
    });
}

function formatStepList(stepList) {
    var result = "";
    for (var i = 0; i < stepList.length; i++) {
        result += "<tr>";
        result += "<td>" + stepList[i].count + "</td>";
        result += "<td>" + stepList[i].name + "</td>";
        result += "</tr>";
    }
    return result;
}

function parseUrlParameters() {
    var quantity = $.url().param('quantity');
    if (quantity !== undefined) {
        $("#crafting_count").val(quantity);

        if ($("#crafting_count option:selected").val() === undefined) {
            $("#crafting_count").val(1);

            $("#crafting_error").html("Unsupported quantity: " + quantity);
            $("#crafting_error").fadeIn(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).fadeOut(FADE_DURATION);
        }
    }
        
    var recipeName = $.url().param('recipeName');
    if (recipeName !== undefined) {
        $("#crafting_selector").val(recipeName);

        if (hasRecipe(recipeName)) {
            onCraftingSelectorChanged();
        } else if (recipeName.length > 0) {
            $("#crafting_error").html("Cannot find recipe for " + recipeName);
            $("#crafting_error").fadeIn(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).fadeOut(FADE_DURATION);
        }
    }
}

function updateCraftingSelector() {
    $("#crafting_selector").autocomplete({
        source: getAllRecipeNames(), delay: 0, minLength: 0,
        change: onCraftingSelectorChanged,
        close: onCraftingSelectorChanged,
        select: onCraftingSelectorChanged,
    });
}

function updatePageState(count, recipeName) {
    var newTitle = "Crafting Guide";
    var newLink = window.location.pathname;
    var state = {}
    if (recipeName !== undefined && recipeName.length > 0) {
        newTitle = "Crafting Guide: " + count + " " + recipeName;
        newLink = "?count=" + count + "&recipeName=" + encodeURIComponent(recipeName);
        newLink = newLink.replace(/%20/g, "+");
        state = {count: count, name: recipeName};
    }

    document.title = newTitle;
    history.pushState(state, newTitle, newLink);
    ga('send', 'pageview');
}

// Crafting Node Object ///////////////////////////////////////////////////////////////////////////////////////////////

function createCraftingNode(count, recipeName, alternatives, recipeBooks) {
    if (recipeBooks === undefined) recipeBooks = __recipeBooks;

    var object = {
        alternatives: [],
        children: [],
        count: count,
        name: recipeName,
        parentNode: undefined,
        recipe: undefined
    };

    if (count !== undefined) {
        if (alternatives === undefined) {
            alternatives = findAllRecipes(recipeName, recipeBooks);
        }
        if (alternatives.length === 0) return undefined;
        object.recipe = alternatives.shift();
        object.alternatives = alternatives;

        for (var i = 0; i < object.recipe.input.length; i++) {
            var input = object.recipe.input[i];
            var node = createCraftingNode(input.count, input.name, undefined, recipeBooks);
            if (node) {
                node.parentNode = object;
                object.children.push(node);
            }
        }
    }

    object.copy = function() {
        var result = createCraftingNode();
        result.alternatives = object.alternatives.copy();
        result.count = object.count;
        result.name = object.name;
        result.parentNode = undefined;
        result.recipe = object.recipe.copy();

        result.children = object.children.copy();
        for (var i = 0; i < result.children.length; i++) {
            result.children[i].parentNode = result;
        }

        return result;
    };

    object.craft = function(craftingResult, isCraftingChild) {
        if (craftingResult === undefined) {
            craftingResult = createCraftingResult();
        }
        var shouldContinueCrafting = function() {
            if (isCraftingChild === true) {
                return craftingResult.missingMaterials.contains(1, object.name);
            } else {
                return ! craftingResult.inventory.contains(object.count, object.name);
            }
        }

        var count = 0;
        while (shouldContinueCrafting()) {
            if (count++ > 100000) {
                throw "Too many iterations";
            }
            for (var i = 0; i < object.recipe.input.length; i++) {
                var input = object.recipe.input[i];
                for (var j = 0; j < input.count; j++) {
                    if (craftingResult.inventory.contains(1, input.name)) {
                        craftingResult.consumeInventory(input.name);
                    } else {
                        craftingResult.addMissingMaterial(input.name);
                    }
                }
            }
            for (var i = 0; i < object.recipe.output.length; i++) {
                var output = object.recipe.output[i];
                craftingResult.addCraftingResult(output.count, output.name);
            }
        }
        for (var i = 0; i < object.children.length; i++) {
            var child = object.children[i];
            child.craft(craftingResult, true);
        }
        if (isCraftingChild !== true) {
            craftingResult.sortStepsBy(object);
        }
        return craftingResult;
    };

    object.createNextAlternative = function(recipeBooks) {
        if (recipeBooks === undefined) recipeBooks = __recipeBooks;
        if (object.alternatives.length === 0) return undefined;
        var nextAlternative = createCraftingNode(object.count, object.name, object.alternatives, recipeBooks);
        object.alternatives = [];
        return nextAlternative;
    };

    object.depthFirstTraversal = function(callback) {
        var shouldContinue = true;
        for (var i = 0; i < object.children.length; i++) {
            var child = object.children[i];
            shouldContinue = child.depthFirstTraversal(callback);
            if (shouldContinue === false) return false;
        }
        return (callback(object) !== false);
    };

    object.findNodeWithAlternatives = function() {
        var result = undefined;
        object.depthFirstTraversal(function(node) {
            if (node.alternatives.length >= 1) {
                result = node;
                return false;
            }
        });
        return result;
    };

    object.getNodeAt = function(position) {
        var node = object;
        for (var i = 0; i < position.length; i++) {
            node = node.children[position[i]];
        }
        return node;
    };

    object.getPosition = function() {
        if (object.parentNode === undefined) return [];
        var position = object.parentNode.getPosition();
        for (var i = 0; i < object.parentNode.children.length; i++) {
            if (object !== object.parentNode.children[i]) continue;
            position.push(i);
            break;
        }
        return position;
    };

    object.setNodeAt = function(position, node) {
        if (position.length === 1) {
            object.children[position[0]] = node;
            node.parentNode = object;
        } else {
            var child = object.children[position[0]];
            child.setNodeAt(position.slice(1), node);
        }
    };

    return object;
}

// Crafting Plan Object ///////////////////////////////////////////////////////////////////////////////////////////////

function createCraftingPlan(count, recipeName, recipeBooks) {
    if (recipeBooks === undefined) recipeBooks = __recipeBooks;

    var object = {
        count: count,
        recipeName: recipeName,
        alternatives: []
    };

    var nodesToProcess = [ createCraftingNode(count, recipeName, undefined, recipeBooks) ];
    while (nodesToProcess.length > 0) {
        var node = nodesToProcess.shift();
        var choiceNode = node.findNodeWithAlternatives();

        if (choiceNode === undefined) {
            object.alternatives.push(node);
        } else if (choiceNode === node) {
            nodesToProcess.push(node);
            nodesToProcess.push(node.createNextAlternative(recipeBooks));
        } else {
            nodesToProcess.push(node);
            var position = choiceNode.getPosition();
            var alternateNode = choiceNode.createNextAlternative(recipeBooks);

            var nextAlternative = node.copy();
            nextAlternative.setNodeAt(position, alternateNode);
            nodesToProcess.push(nextAlternative);
        }
    }

    return object;
}

// Crafting Result Object /////////////////////////////////////////////////////////////////////////////////////////////

function createCraftingResult(startingInventory) {
    if (startingInventory === undefined) startingInventory = createManifest();

    var object = {
        inventory: startingInventory.copy(),
        missingMaterials: createManifest(),
        stepList: [],
    };

    object.addCraftingResult = function(count, name) {
        var foundStep = false;
        for (var i = 0; i < object.stepList.length; i++) {
            var step = object.stepList[i];
            if (step.name === name) {
                step.count += count;
                foundStep = true;
            }
        }
        if (! foundStep) {
            object.stepList.unshift(createIngredient(count, name));
        }
        for (var i = 0; i < count; i++) {
            if (object.missingMaterials.contains(1, name)) {
                object.missingMaterials.remove(1, name);
            } else {
                object.inventory.add(1, name);
            }
        }
    }

    object.addMissingMaterial = function(name) {
        object.missingMaterials.add(1, name);
    }

    object.consumeInventory = function(name) {
        object.inventory.remove(1, name);
    }

    object.copy = function() {
        var result = createCraftingResult();
        result.inventory = object.inventory.copy();
        result.missingMaterials = object.missingMaterials.copy();
        result.stepList = object.stepList.copy();
        return result;
    };

    object.sortStepsBy = function(rootNode) {
        var stepCounts = {};
        for (var i = 0; i < object.stepList.length; i++) {
            var step = object.stepList[i];
            stepCounts[step.name] = step.count;
        }

        var result = [];
        rootNode.depthFirstTraversal(function(node) {
            if (stepCounts[node.name] !== undefined) {
                result.push(createIngredient(stepCounts[node.name], node.name));
                delete stepCounts[node.name];
            }
        });

        object.stepList = result;
    };

    return object;
}

// Ingredient Object //////////////////////////////////////////////////////////////////////////////////////////////////

function createIngredient(count, name) {
    var object = {count: count, name: name};

    object.copy = function() {
        return createIngredient(object.count, object.name);
    };

    return object;
}

// Manifest Object ////////////////////////////////////////////////////////////////////////////////////////////////////

function createManifest() {
    var object = {materials: {}, length: 0};

    object.add = function(count, name) {
        if (object.materials[name] === undefined) {
            object.materials[name] = count;
            object.length += 1;
        } else {
            object.materials[name] = object.materials[name] + count;
        }
    };

    object.contains = function(count, name) {
        if (object.materials[name] === undefined) return false;
        return (object.materials[name] >= count);
    };

    object.copy = function(count, name) {
        var result = createManifest();
        for (var name in object.materials) {
            if (! object.materials.hasOwnProperty(name)) continue;
            result.add(object.materials[name], name);
        }
        return result;
    }

    object.remove = function(count, name) {
        if (object.materials[name] !== undefined) {
            var availableCount = object.materials[name];
            if (availableCount === count) {
                delete object.materials[name]
                object.length -= 1;
            } else if (availableCount > count) {
                object.materials[name] -= count;
            } else {
                throw "Only " + availableCount + " " + name + ", cannot remove " + count;
            }
        } else {
            throw "No " + name + ", cannot remove " + count;
        }
    };

    object.removeAll = function() {
        object.materials = {};
        object.length = 0;
    }

    object.toHtml = function() {
        var result = "";
        var count = 0;
        for (var name in object.materials) {
            result += "<tr><td>" + object.materials[name] + "</td><td>" + name + "</td></tr>";
            count += 1
        }

        if (count === 0) result = "<tr><td>Nothing</td><td>&nbsp;</td></tr>";
        return result;
    };

    return object;
}

// Recipe Object //////////////////////////////////////////////////////////////////////////////////////////////////////

function createRecipe(data) {
    var object = {
        name: '',
        output: [],
        input: [],
        tools: []
    };

    if (data !== undefined) {
        $.each(data.output, function(index, value) {
            object.output.push(createIngredient(value[0], value[1]));
        });
        if (object.output.length > 0) {
            object.name = object.output[0].name;
        }

        $.each(data.input, function(index, value) {
            object.input.push(createIngredient(value[0], value[1]));
        });

        object.tools = data.tools;
    }

    object.copy = function() {
        var result = createRecipe();
        result.name = object.name,
        result.output = object.output.copy(),
        result.input = object.input.copy(),
        result.tools = object.tools.copy()
        return result;
    };

    return object;
}

// RecipeBook Object //////////////////////////////////////////////////////////////////////////////////////////////////

function createRecipeBook(sourceUrl, data) {
    var object = {
        name: data.name,
        description: data.description,
        sourceUrl: sourceUrl,
        recipes: []
    };

    $(data.recipes).each(function(i, data) {
        object.recipes.push(createRecipe(data));
    });

    object.findAllRecipes = function(recipeName) {
        var targetName = recipeName.toLowerCase();
        var result = []
        for (var i = 0; i < object.recipes.length; i++) {
            var recipe = object.recipes[i];
            if (recipe.name.toLowerCase() === targetName) {
                result.push(recipe)
            }
        }
        return result;
    };

    object.getAllRecipeNames = function() {
        var set = {};
        for (var i = 0; i < object.recipes.length; i++) {
            set[object.recipes[i].name] = true;
        }
        var result = [];
        for (var name in set) {
            result.push(name);
        }
        return result.sort();
    };

    object.hasRecipe = function(name) {
        var targetName = name.toLowerCase();
        for (var i = 0; i < object.recipes.length; i++) {
            var recipe = object.recipes[i];
            if (recipe.name.toLowerCase() === targetName) return true;
        }
        return false;
    };

    object.toHtml = function() {
        return $(
            "<tr>" +
                "<td width=\"25%\"><a target=\"new\" href=\"" + object.sourceUrl + "\">" + object.name + "</a></td>" +
                "<td width=\"*\">" + object.description + "</td>" +
            "</tr>"
        );
    };

    return object;
}

function hasRecipe(name, recipeBooks) {
    if (recipeBooks === undefined) recipeBooks = __recipeBooks;

    for (var i = 0; i < recipeBooks.length; i++) {
        var recipeBook = recipeBooks[i];
        if (recipeBook.hasRecipe(name)) return true;
    }
    return false;
}

function findAllRecipes(name, recipeBooks) {
    if (recipeBooks === undefined) recipeBooks = __recipeBooks;

    var result = [];
    for (var i = 0; i < recipeBooks.length; i++) {
        var recipeBook = recipeBooks[i];
        var recipes = recipeBook.findAllRecipes(name);
        for (var j = 0; j < recipes.length; j++) {
            result.push(recipes[j]);
        }
    }
    return result;
}

function getAllRecipeNames(recipeBooks) {
    if (recipeBooks === undefined) recipeBooks = __recipeBooks;

    var set = {};
    for (var i = 0; i < recipeBooks.length; i++) {
        var recipeNames = recipeBooks[i].getAllRecipeNames();
        for (var j = 0; j < recipeNames.length; j++) {
            set[recipeNames[j]] = true;
        }
    }

    var result = [];
    for (var name in set) {
        result.push(name);
    }
    result.sort();
    return result;
}

