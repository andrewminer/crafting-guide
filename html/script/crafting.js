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

Array.prototype.excluding = function(excludedElement) {
    var result = [];
    this.each(function(element) {
        if (element === excludedElement) return;
        result.push(element);
    });
    return result;
};

Array.prototype.pushAll = function(array) {
    array.each(function(element) {
        this.push(element);
    });
}

Array.prototype.toString = function(options, indent) {
    if (options === "pretty") {
        options = {"prefix": "[\n", "suffix": "\n]", "delimiter": ",\n", "indentBy": "    "};
    } 

    var options = (options === undefined) ? {} : options;
    var indent  = (indent  === undefined) ? "" : indent;

    var prefix    = (options.prefix    === undefined) ? "["  : options.prefix;
    var suffix    = (options.suffix    === undefined) ? "]"  : options.suffix;
    var delimiter = (options.delimiter === undefined) ? ", " : options.delimiter;
    var indentBy  = (options.indentBy  === undefined) ? ""   : options.indentBy;

    var result = prefix;
    var needsDelimiter = false;
    for (var i = 0; i < this.length; i++) {
        if (needsDelimiter === true) result += delimiter;
        needsDelimiter = true;

        if (this[i] === undefined) {
            result += "undefined";
        } else if (typeof(this[i].toString) === 'function') {
            result += this[i].toString(options, indentBy);
        } else {
            result += this[i];
        }
    }
    result = result.replace(/\n/g, "\n" + indentBy);
    result += suffix;
    return result;
};

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
        var crafter = createCrafter(recipeName, {count: count, includeTools: __toolsIncluded});
        var plan = crafter.chooseBestPlan();

        $("#missing_materials").html(formatManifest(plan.materials));
        $("#crafted_items").html(formatStepList(plan.stepList));
        $("#leftover_materials").html(formatManifest(plan.inventory));
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
                $("#load_error").slideDown(SLIDE_DURATION).delay(ERROR_DISPLAY_DURATION).slideUp(SLIDE_DURATION);
            }
        },
        error: function(response, status, error) {
            $("#load_error").html(status + ": " + error);
            $("#load_error").slideDown(SLIDE_DURATION).delay(ERROR_DISPLAY_DURATION).slideUp(SLIDE_DURATION);
        },
        complete: function() {
            __loadingCount--;
            onRecipeBookLoaded();
        }
    });
}

function formatStepList(stepList) {
    var result = "";
    stepList.each(function(step) {
        result += "<tr><td>" + step.count + "</td><td>" + step.name + "</td></tr>";
    });
    return result;
}

function formatManifest(manifest) {
    var result = "";
    manifest.each(function(count, material) {
        result += "<tr><td>" + count + "</td><td>" + material + "</td></tr>";
    });
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

// Base Object ////////////////////////////////////////////////////////////////////////////////////////////////////////

function createBaseObject(type, root) {
    var type   = (type === undefined) ? "undefined" : type;
    var object = (root === undefined) ? {}          : root;

    object.hash = Math.floor(Math.random() * 100000000);
    object.type = type;

    object.eachProperty = function(onVisit) {
        if (typeof(onVisit) !== "function") throw "onVisit must be a function, not a " + typeof(onVisit)

        for (var property in object) {
            if (! this.hasOwnProperty(property)) continue;
            value = this[property];

            if (typeof(value) === 'function') continue;
            if (value === object.type) continue;
            if (value === object.hash) continue;

            onVisit(property, value);
        }
    };

    object.strip = function() {
        var result = {};
        object.eachProperty(function(key, value) {
            result[key] = value;
        });
        return result;
    };

    object.toString = function(options) {
        options = (options === undefined) ? {} : options;
        indent = (options.indent === undefined) ? "" : options.indent;

        var result = object.type + "<" + object.hash + ">";
        var needsDelimiter = false;
        object.eachProperty(function(key, value) {
            if (needsDelimiter) result += ",\n";
            result += indent + key + ": " + value.toString({indent: indent + "    "});
            needsDelimiter = true;
        });

        return result;
    };

    return object;
}

// Crafter Object /////////////////////////////////////////////////////////////////////////////////////////////////////

function createCrafter(recipeName, options) {
    if (recipeName === undefined) throw "RecipeName is requried";
    var options      = (options              === undefined) ? {}            : options;
    var count        = (options.count        === undefined) ? 1             : options.count;
    var recipeBooks  = (options.recipeBooks  === undefined) ? __recipeBooks : options.recipeBooks;
    var includeTools = (options.includeTools === true)      ? true          : false;

    var object = createBaseObject("Crafter", {
        includeTools: includeTools,
        plans: [],
        rootNode: undefined,
    });

    object.chooseBestPlan = function() {
        return object.plans[0];
    };

    function init() {
        object.rootNode = createCraftingNode(recipeName, {
            count: count,
            includeTools: includeTools,
            recipeBooks: recipeBooks,
        });
        object.rootNode.expandFully();
        object.plans = object.rootNode.generateCraftingPlans();

        return object;
    }

    return init();
}

// Crafting Node Object ///////////////////////////////////////////////////////////////////////////////////////////////

function createCraftingNode(targetName, options) {
    if (targetName === undefined) throw "TargetName is required";

    var options          = (options                  === undefined) ? {}               : options;
    var choices          = (options.choices          === undefined) ? []               : options.choices;
    var count            = (options.count            === undefined) ? 1                : options.count;
    var includeTools     = (options.includeTools     === true)      ? true             : false;
    var initialInventory = (options.initialInventory === undefined) ? createManifest() : options.initialInventory;
    var outcome          = (options.outcome          === undefined) ? "make"           : options.outcome;
    var parentNode       = (options.parentNode       === undefined) ? undefined        : options.parentNode;
    var recipe           = (options.recipe           === undefined) ? undefined        : options.recipe;
    var recipeBooks      = (options.recipeBooks      === undefined) ? __recipeBooks    : options.recipeBooks;

    var object = createBaseObject("CraftingNode", {
        children: [],
        choices: choices,
        count: count,
        crafted: createManifest(),
        includeTools: includeTools,
        inventory: createManifest(),
        materials: createManifest(),
        outcome: outcome,
        parentNode: parentNode,
        recipe: recipe,
        score: 0,
        targetName: targetName,
    });

    object.expandChoices = function() {
        object.choices.each(function(choiceGroup) {
            choiceGroup.each(function(choice) {
                var child = createCraftingNode(choice.recipe.name, {
                    choices: getChoicesExcluding(choiceGroup),
                    count: choice.count,
                    recipe: choice.recipe,
                    includeTools: object.includeTools,
                    outcome: choice.outcome,
                    parentNode: object,
                    recipeBooks: recipeBooks
                });
                if (child) {
                    object.children.push(child);
                }
            });
        });
        object.choices = [];
    };

    object.expandFully = function() {
        object.expandChoices();
        object.children.each(function(child) {
            child.expandFully();
        });
    };

    object.generateCraftingPlans = function() {
        var results = [];
        if (object.children.length === 0) {
            results.push(createCraftingPlan(object));
        } else {
            object.children.each(function(child) {
                child.generateCraftingPlans().each(function(plan) {
                    results.push(plan);
                });
            });
        }
        return results;
    };

    object.toString = function(options) {
        var options = (options === undefined) ? {} : options;
        var indent = (options.indent === undefined) ? "" : options.indent;

        var recipeName = (object.recipe === undefined) ? "ROOT" : object.recipe.name;
        var result = indent + recipeName + ((object.choices.length > 0) ? "*" : "") + " <" + object.hash + ">";
        if (object.children.length > 0) {
            result += "\n";
            var needsDelimiter = false;
            object.children.each(function(child) {
                if (needsDelimiter) result += "\n";
                result += child.toString({indent: indent + "    "});
                needsDelimiter = true;
            });
        }
        return result;
    };

    function addChoicesFor(recipeName, count, outcome) {
        var choiceGroup = [];
        findAllRecipes(recipeName, recipeBooks).each(function(recipe) {
            choiceGroup.push({recipe: recipe, count: count, outcome: outcome});
        });
        if (choiceGroup.length > 0) {
            object.choices.push(choiceGroup);
        }
    }

    function getChoicesExcluding(excludedChoiceGroup) {
        var result = [];
        object.choices.each(function(choiceGroup) {
            if (choiceGroup === excludedChoiceGroup) return;
            result.push([].concat(choiceGroup));
        });
        return result;
    }

    function elaborateInputChoices() {
        object.recipe.input.each(function(input) {
            addChoicesFor(input.name, input.count, 'use');
        });
    }

    function elaborateToolChoices() {
        object.recipe.tools.each(function(tool) {
            addChoicesFor(tool, 1, 'make');
        });
    }

    function computeCraftingResults() {
        if (object.recipe === undefined) return;

        function isComplete() {
            if (object.outcome == "make") return object.inventory.contains(object.count, object.targetName);
            if (object.outcome == "use") return object.materials.countOf(object.targetName) === 0;
            throw "Invalid outcome: " + object.outcome
        }

        while (! isComplete()) {
            object.recipe.input.each(function(input) {
                for (var i = 0; i < input.count; i++) {
                    if (object.inventory.contains(1, input.name)) {
                        object.inventory.remove(1, input.name);
                    } else {
                        object.materials.add(1, input.name);
                    }
                }
            });
            object.recipe.output.each(function(output) {
                for (var i = 0; i < output.count; i++) {
                    object.crafted.add(1, output.name);
                    if (object.materials.contains(1, output.name)) {
                        object.materials.remove(1, output.name);
                    } else {
                        object.inventory.add(1, output.name);
                    }
                }
            });
        }
    }

    function init() {
        object.inventory.addAll(initialInventory);
        
        if (object.parentNode) {
            object.inventory.addAll(object.parentNode.inventory);
            object.materials.addAll(object.parentNode.materials);
        }

        if (object.recipe) {
            elaborateInputChoices();
            if (includeTools) {
                elaborateToolChoices();
            }
            computeCraftingResults();
        } else {
            var recipes = findAllRecipes(targetName, recipeBooks);
            if (recipes.length === 0) return undefined;
            addChoicesFor(targetName, count, "make");
        }

        return object;
    }

    return init();
}

// Crafting Plan Object /////////////////////////////////////////////////////////////////////////////////////////////

function createCraftingPlan(sourceNode) {
    if (sourceNode === undefined) throw "SourceNode cannot be undefined";

    var object = createBaseObject("CraftingPlan", {
        stepList: [],
        inventory: createManifest(),
        leafNode: sourceNode,
        materials: createManifest(),
        rootNode: undefined,
    });

    object.toString = function(options) {
        var result = "Makes " + object.rootNode.targetName;
        result += " by making: " + object.stepList;
        result += " which requires: " + object.materials;
        result += " and yields: " + object.inventory;
        return result;
    };

    function buildStepList() {
        var current = object.leafNode;
        while (current !== undefined) {
            current.crafted.each(function(count, material) {
                object.stepList.push(createIngredient(count, material));
            });
            current = current.parentNode;
        }
    }

    function findTargetNode() {
        var current = sourceNode;
        while (current.parentNode !== undefined) {
            current = current.parentNode;
        }
        object.rootNode = current;
    }

    function init() {
        buildStepList();
        findTargetNode();

        object.inventory.addAll(sourceNode.inventory);
        object.materials.addAll(sourceNode.materials);
        return object;
    }

    return init();
}

// Ingredient Object //////////////////////////////////////////////////////////////////////////////////////////////////

function createIngredient(count, name) {
    var object = createBaseObject("Ingredient", {count: count, name: name});

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
    var object = createBaseObject("Manifest", {materials: createBaseObject("Set"), length: 0});

    object.add = function(count, name) {
        if (object.materials[name] === undefined) {
            object.materials[name] = count;
            object.length += 1;
        } else {
            object.materials[name] = object.materials[name] + count;
        }
    };

    object.addAll = function(manifest) {
        manifest.each(function(count, material) {
            object.add(count, material);
        });
    };

    object.contains = function(count, name) {
        var available = object.countOf(name);
        return (available >= count);
    };

    object.copy = function(count, name) {
        var result = createManifest();
        object.each(function(count, material) {
            result.add(count, material);
        });
        return result;
    };

    object.countOf = function(name) {
        return (object.materials[name] === undefined) ? 0 : object.materials[name];
    };

    object.each = function(onVisit) {
        object.materials.eachProperty(function(key, value) {
            return onVisit(value, key);
        });
    };

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
        object.each(function(count, material) {
            result += "<tr><td>" + count + "</td><td>" + material + "</td></tr>";
            materialCount += 1
        });

        if (materialCount === 0) result = "<tr><td>Nothing</td><td>&nbsp;</td></tr>";
        return result;
    };

    object.toKey = function() {
        var result = "|";
        object.each(function(count, material) {
            result += count + ":" + material + "|";
        });
        return result;
    };

    object.toString = function() {
        var result = "[";
        var needsDelimiter = false;
        object.each(function(count, material) {
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
    var object = createBaseObject("Recipe", {
        name: '',
        output: [],
        input: [],
        tools: [],
    });

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

    function init() {
        if (data !== undefined) {
            object.loadFrom(data);
        }
        return object;
    }

    return init();
}

// RecipeBook Object //////////////////////////////////////////////////////////////////////////////////////////////////

function createRecipeBook(sourceUrl, data) {
    var object = createBaseObject("RecipeBook", {
        name: undefined,
        description: undefined,
        length: 0,
        sourceUrl: sourceUrl,
        recipeSet: {},
        recipes: []
    });

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
        var set = createBaseObject("Set");
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
    for (key in set) {
        if (! set.hasOwnProperty(key)) continue;
        result.push(key);
    }
    result.sort();
    return result;
}

