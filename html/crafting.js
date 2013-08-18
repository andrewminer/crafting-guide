// Constants //////////////////////////////////////////////////////////////////////////////////////////////////////////

var FADE_DURATION = 250; // ms
var ERROR_DISPLAY_DURATION = 5000; // ms

// UI Functions ///////////////////////////////////////////////////////////////////////////////////////////////////////

function onPageLoad() {
    $("#recipe_load_button").click(onRecipeLoadButtonClicked);
    $("#crafting_selector").change(onCraftingSelectorChanged);

    loadRecipes("data/vanilla.json");
}

function onCraftingSelectorChanged() {
    var recipeName = $("#crafting_selector option:selected").val();
    var recipe = __recipes[recipeName];
    if (recipe === undefined) {
        $("#crafting_error").html("Cannot find recipe for " + recipeName);
        $("#crafting_error").fadeIn(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).fadeOut(FADE_DURATION);
    } else {
        var inventory = createManifest();
        var missingMaterials = recipe.computeMissingMaterials(inventory);
        $("#missing_materials").html(missingMaterials.toHtml());
        $("#leftover_materials").html(inventory.toHtml());
        $("#crafting_output").fadeIn(FADE_DURATION);
    }
}

function onRecipeLoadButtonClicked() {
    loadRecipes($("#recipe_url").val());
}

// UI Helper Functions ////////////////////////////////////////////////////////////////////////////////////////////////

function loadRecipes(recipeUrl) {
    $.ajax({
        url: recipeUrl,
        dataType: "text",
        success: function(data) {
            try {
                recipeData = $.parseJSON(data)["recipes"];
                __recipes = parseRecipeData(recipeData);
                $("#loaded_recipes ul").append("<li><a href=\"" + recipeUrl + "\">" + recipeUrl + "</a></li>");
                $("#loaded_recipes").fadeIn(FADE_DURATION);

                updateCraftingSelector();
                $("#crafting").fadeIn(FADE_DURATION);
            } catch (e) {
                $("#load_error").html(e);
                $("#load_error").slideDown(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).slideUp(FADE_DURATION);
            }
        },
        error: function(response, status, error) {
            $("#load_error").html(error);
            $("#load_error").slideDown(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).slideUp(FADE_DURATION);
        }
    });
}

function updateCraftingSelector() {
    var $selector = $("#crafting_selector");
    if (__recipes.length == 0) {
        $selector.attr("disabled", "disabled");
    } else {
        for (var name in __recipes) {
            if (!__recipes.hasOwnProperty(name)) continue;
            $selector.append("<option value=\"" + name + "\">" + name + "</option>");
        }
        $selector.removeAttr("disabled");
    }
}

// Manifest Object ////////////////////////////////////////////////////////////////////////////////////////////////////

function createManifest() {
    var object = {materials: {}};

    object.add = function(count, name) {
        if (object.materials[name] === undefined) {
            object.materials[name] = count;
        } else {
            object.materials[name] = object.materials[name] + count;
        }
    };

    object.contains = function(count, name) {
        if (object.materials[name] === undefined) return false;
        return (object.materials[name] >= count);
    };

    object.remove = function(count, name) {
        if (object.materials[name] !== undefined) {
            if (object.materials[name] <= count) {
                delete object.materials[name]
            } else {
                object.materials[name] -= count;
            }
        }
    };

    object.toHtml = function() {
        var result = "";
        var count = 0;
        for (var name in object.materials) {
            result += "<li>" + object.materials[name] + " " + name + "</li>";
            count += 1
        }

        if (count === 0) result = "<li class=\"disabled\">Nothing</li>";
        return result;
    };

    return object;
}

// Recipe Object //////////////////////////////////////////////////////////////////////////////////////////////////////

function parseRecipeData(recipeData) {
    var recipes = {};
    $.each(recipeData, function(i, data) {
        var recipe = createRecipe(data);
        $.each(recipe.output, function(j, output) {
            recipes[output.name] = recipe
        });
    });
    return recipes;
}

function createRecipe(data) {
    var object = {output: [], input: [], tools: data.tools};

    $.each(data.output, function(index, value) {
        object.output.push({count: value[0], name: value[1]});
    });

    $.each(data.input, function(index, value) {
        object.input.push({count: value[0], name: value[1]});
    });

    // Methods ////////////////////////////////////////////

    object.computeMissingMaterials = function(inventory) {
        if (inventory === undefined) inventory = createManifest();
        var missingMaterials = createManifest();
        var queue = [];

        function craftItem(ingredient) {
            var recipe = __recipes[ingredient.name];
            if (recipe === undefined) {
                missingMaterials.add(1, ingredient.name);
                ingredient.count -= 1
            } else {
                $.each(recipe.input, function(j, childIngredient) {
                    queue.push({count: childIngredient.count, name: childIngredient.name});
                });
                $.each(recipe.output, function(j, childProduct) {
                    inventory.add(childProduct.count, childProduct.name);
                });
                $.each(recipe.tools, function(j, tool) {
                    if (! inventory.contains(1, tool)) {
                        craftItem({count: 1, name: tool});
                    }
                });
            }
            return recipe;
        }

        craftItem({count: 1, name: object.output[0].name});

        while (queue.length > 0) {
            var ingredient = queue.shift();
            while (ingredient.count > 0) {
                if (inventory.contains(1, ingredient.name)) {
                    inventory.remove(1, ingredient.name);
                    ingredient.count -= 1;
                } else {
                    craftItem(ingredient);
                }
            }
        }

        return missingMaterials;
    }

    return object;
}
