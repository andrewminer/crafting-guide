// Constants //////////////////////////////////////////////////////////////////////////////////////////////////////////

var ERROR_DISPLAY_DURATION = 10000; // ms
var FADE_DURATION = 250; // ms
var INDENT_UNIT = "    ";
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

Array.prototype.each = function(onVisit) {
    for (var i = 0; i < this.length; i++) {
        var shouldStop = onVisit(this[i]);
        if (shouldStop) return;
    }
};

Array.prototype.toString = function(options, indent) {
    if (options === "pretty") {
        options = {"prefix": "[\n", "suffix": "\n]", "delimiter": ",\n", "indentBy": "    "};
    } 

    options = (options === undefined) ? {} : options;
    indent  = (indent  === undefined) ? "" : indent;

    var prefix    = (options.prefix    === undefined) ? "["  : options.prefix;
    var suffix    = (options.suffix    === undefined) ? "]"  : options.suffix;
    var delimiter = (options.delimiter === undefined) ? ", " : options.delimiter;
    var indentBy  = (options.indentBy  === undefined) ? ""   : options.indentBy;

    var result = prefix;
    var needsDelimiter = false;
    for (var i = 0; i < this.length; i++) {
        if (needsDelimiter === true) result += delimiter;
        needsDelimiter = true;

        if (typeof(this[i].toString) === 'function') {
            result += this[i].toString(options, indentBy);
        } else {
            result += this[i];
        }
    }
    result = result.replace(/\n/g, "\n" + indentBy);
    result += suffix;
    return result;
};

Object.prototype.eachProperty = function(onVisit) {
    for (var property in this) {
        if (this.hasOwnProperty(property)) {
            onVisit(property, this.property);
        }
    }
};

// UI Functions ///////////////////////////////////////////////////////////////////////////////////////////////////////
/*
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
        var plan = createCraftingPlan(count, recipeName, __toolsIncluded);
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
*/
// UI Helper Functions ////////////////////////////////////////////////////////////////////////////////////////////////
/*
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
*/
// Crafter Object /////////////////////////////////////////////////////////////////////////////////////////////////////

function createCrafter(recipeName, options) {
    if (recipeName === undefined) throw "RecipeName is requried";
    options = (options === undefined) ? {} : options;
    recipeBooks = (options.recipeBooks === undefined) ? __recipeBooks : options.recipeBooks;
    includeTools = (options.includeTools === true) ? true : false;

    var object = {
        includeTools: includeTools,
        rootNode: undefined
    };

    return object;
}

// Crafting Alternatives //////////////////////////////////////////////////////////////////////////////////////////////
/*
function createCraftingAlternative(recipe, children) {
    var object = {
        children: children,
        recipe: recipe
    };

    return object;
}
*/
// Crafting Node Object ///////////////////////////////////////////////////////////////////////////////////////////////

function createCraftingNode(targetName, options) {
    if (targetName === undefined) throw "TargetName is required";

    options          = (options                  === undefined) ? {}               : options;
    count            = (options.count            === undefined) ? 1                : options.count;
    includeTools     = (options.includeTools     === true)      ? true             : false;
    initialInventory = (options.initialInventory === undefined) ? createManifest() : options.initialInventory;
    parentNode       = (options.parentNode       === undefined) ? undefined        : options.parentNode;
    recipe           = (options.recipe           === undefined) ? undefined        : options.recipe;
    recipeBooks      = (options.recipeBooks      === undefined) ? __recipeBooks    : options.recipeBooks;

    var object = {
        children: [],
        choices: [],
        count: count,
        includeTools: includeTools,
        inventory: createManifest(),
        materials: createManifest(),
        parentNode: parentNode,
        recipe: recipe,
        score: 0,
        targetName: targetName
    };

    object.expandChoices = function() {
        object.choices.each(function(choiceGroup) {
            choiceGroup.each(function(recipe) {
                var child = createCraftingNode(recipe.name, {
                    recipe: recipe,
                    includeTools: includeTools,
                    parentNode: object,
                    recipeBooks: recipeBooks
                });
                if (child) object.children.push(child);
            });
        });
    };

    object.expandFully = function() {
        object.expandChoices();
        object.children.each(function(child) {
            child.expandFully();
        });
    };

    object.toString = function(options) {
        options = (options === undefined) ? {} : options;
        indent = (options.indent === undefined) ? "" : options.indent;

        var recipeName = (object.recipe === undefined) ? "<root node>" : recipe.name;
        var result = indent + recipeName + ((object.choices.length > 0) ? " *" : "");
        if (object.children.length > 0) {
            result += "\n";
            object.children.each(function(child) {
                result += object.children[i].toString({indent: indent + "    "}) + "\n";
            });
        }
        return result;
    };

    function elaborateInputChoices() {
        object.recipe.input.each(function(input) {
            var alternatives = findAllRecipes(input.name, recipeBooks);
            if (alternatives.length > 0) {
                object.choices.push(alternatives);
            }
        });
    }

    function elaborateToolChoices() {
        object.recipe.tools.each(function(tool) {
            var alternatives = findAllRecipes(tool, recipeBooks);
            if (alternatives.length > 0) {
                object.choices.push(alternatives);
            }
        });
    }

    function computeCraftingResults() {
        function isComplete() {
            return (object.parentNode === undefined) ?
                ! object.materials.contains(1, object.targetName) :
                object.inventory.contains(count, object.targetName);
        }

        while (! isComplete()) {
            object.recipe.input.each(function(input) {
                for (var j = 0; j < input.count; j++) {
                    if (object.inventory.contains(1, input.name)) {
                        object.inventory.remove(1, input.name);
                    } else {
                        object.materials.add(1, input.name);
                    }
                }
            });
            object.recipe.output.each(function(output) {
                object.inventory.add(output.count, output.name);
            });
        }

        if (options.includeTools) {
            options.recipe.tools.each(function(tool) {
                if (! object.inventory.contains(1, tool)) {
                    object.materials.add(1, tool);
                }
            });
        }
    }

    function init() {
        object.inventory.addAll(initialInventory);
        
        if (parentNode) {
            object.inventory.addAll(parentNode.inventory);
            object.materials.addAll(parentNode.materials);
        }

        if (object.recipe) {
            elaborateInputChoices();
            if (options.includeTools) {
                elaborateToolChoices();
            }
            computeCraftingResults();
        } else {
            var recipes = findAllRecipes(targetName, recipeBooks);
            if (recipes.length === 0) return undefined;
            object.choices.push(recipes);
        }

        return object;
    }

    return init();
}

// Crafting Result Object /////////////////////////////////////////////////////////////////////////////////////////////
/*
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
        rootNode.visitCraftingNodes(function(node) {
            if (stepCounts[node.name] !== undefined) {
                result.push(createIngredient(stepCounts[node.name], node.name));
                delete stepCounts[node.name];
            }
        });

        object.stepList = result;
    };

    object.toKey = function() {
        return object.missingMaterials.toKey();
    };

    return object;
}
*/
// Ingredient Object //////////////////////////////////////////////////////////////////////////////////////////////////

function createIngredient(count, name) {
    var object = {count: count, name: name};

    object.copy = function() {
        return createIngredient(object.count, object.name);
    };

    object.toString = function() {
        return object.count + " " + object.name;
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

    object.addAll = function(manifest) {
        object.materials.eachProperty(function(material, count) {
            object.add(count, material);
        });
    };

    object.contains = function(count, name) {
        if (object.materials[name] === undefined) return false;
        return (object.materials[name] >= count);
    };

    object.copy = function(count, name) {
        var result = createManifest();
        object.materials.eachProperty(function(material, count) {
            result.add(count, material);
        });
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
        var materialCount = 0;
        object.materials.eachProperty(function(material, count) {
            result += "<tr><td>" + count + "</td><td>" + material + "</td></tr>";
            materialCount += 1
        });

        if (materialCount === 0) result = "<tr><td>Nothing</td><td>&nbsp;</td></tr>";
        return result;
    };

    object.toKey = function() {
        var result = "|";
        object.materials.eachProperty(function(material, count) {
            result += count + ":" + material + "|";
        });
        return result;
    };

    object.toString = function() {
        var result = "[";
        var needsDelimiter = false;
        object.materials.eachProperty(function(material, count) {
            if (needsDelimiter) result += ", ";
            needsDelimiter = true;
            result += count + " " + material;
        });
        result += "]";
        return result;
    }

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

    object.copy = function() {
        var result = createRecipe();
        result.name = object.name;
        result.output = object.output.copy();
        result.input = object.input.copy();
        result.tools = object.tools.copy();
        return result;
    }

    object.loadFrom = function(data) {
        data.output.each(function(value) {
            object.output.push(createIngredient(value[0], value[1]));
        });
        if (object.output.length > 0) {
            object.name = object.output[0].name;
        }

        data.input.each(function(value) {
            object.input.push(createIngredient(value[0], value[1]));
        });

        object.tools = data.tools;
    };

    object.toString = function(options) {
        var options = {"prefix": "", "suffix": "", "delimiter": ", "};
        var result = "Makes " + object.output.toString(options) + " from " + object.input.toString(options);
        if (object.tools.length > 0) {
            result += " using " + object.tools.toString(options);
        }
        return result;
    };

    if (data !== undefined) {
        object.loadFrom(data);
    }

    return object;
}

// RecipeBook Object //////////////////////////////////////////////////////////////////////////////////////////////////

function createRecipeBook(sourceUrl, data) {
    var object = {
        name: undefined,
        description: undefined,
        length: 0,
        sourceUrl: sourceUrl,
        recipeSet: {},
        recipes: []
    };

    object.addRecipe = function(recipe) {
        var key = recipe.toString();
        if (object.recipeSet[key] !== undefined) return;

        object.recipeSet[key] = recipe;
        object.recipes.push(recipe);
        object.length += 1;
    };

    if (data !== undefined) {
        object.name = data.name;
        object.description = data.description;

        data.recipes.each(function(recipeData) {
            object.addRecipe(createRecipe(recipeData));
        });
    }

    object.findAllRecipes = function(recipeName) {
        var targetName = recipeName.toLowerCase();
        var result = []
        object.recipes.each(function(recipe) {
            if (recipe.name.toLowerCase() === targetName) {
                result.push(recipe)
            }
        });
        return result;
    };

    object.getAllRecipeNames = function() {
        var set = {};
        object.recipes.each(function(recipe) {
            set[recipe.name] = true;
        });
        var result = [];
        set.eachProperty(function(key, value) {
            result.push(key);
        });
        return result.sort();
    };

    object.hasRecipe = function(name) {
        var targetName = name.toLowerCase();
        var foundRecipe = false;
        object.recipes.each(function(recipe) {
            if (recipe.name.toLowerCase() === targetName) {
                foundRecipe = true;
                return false;
            }
        });
        return foundRecipe;
    };

    object.toString = function(options) {
        return object.recipes.toString(options);
    };

    /*
    object.toHtml = function() {
        return $(
            "<tr>" +
                "<td width=\"25%\"><a target=\"new\" href=\"" + object.sourceUrl + "\">" + object.name + "</a></td>" +
                "<td width=\"*\">" + object.description + "</td>" +
            "</tr>"
        );
    };
    */

    return object;
}

function hasRecipe(name, recipeBooks) {
    if (recipeBooks === undefined) recipeBooks = __recipeBooks;

    var foundRecipe = false;
    recipeBooks.each(function(recipeBook) {
        if (recipeBook.hasRecipe(name)) {
            foundRecipe = true;
            return false;
        }
    });
    return foundRecipe;
}

function findAllRecipes(name, recipeBooks) {
    if (recipeBooks === undefined) recipeBooks = __recipeBooks;

    var result = [];
    recipeBooks.each(function(recipeBook) {
        var recipes = recipeBook.findAllRecipes(name);
        recipes.each(function(recipe) {
            result.push(recipe);
        });
    });
    return result;
}

function getAllRecipeNames(recipeBooks) {
    if (recipeBooks === undefined) recipeBooks = __recipeBooks;

    var set = {};
    recipeBooks.each(function(recipeBook) {
        var recipeNames = recipeBook.getAllRecipeNames();
        for (var j = 0; j < recipeNames.length; j++) {
            set[recipeNames[j]] = true;
        }
    });

    var result = [];
    set.eachProperty(function(key, value) {
        result.push(key);
    });
    result.sort();
    return result;
}

