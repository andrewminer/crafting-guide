// Constants //////////////////////////////////////////////////////////////////////////////////////////////////////////

var FADE_DURATION = 250; // ms
var ERROR_DISPLAY_DURATION = 5000; // ms

// Global Variables ///////////////////////////////////////////////////////////////////////////////////////////////////

var __recipebooks = [];

// UI Functions ///////////////////////////////////////////////////////////////////////////////////////////////////////

$(function() {
    $("#recipebook_load_button").click(onRecipeLoadButtonClicked);
    $("#crafting_selector").change(onCraftingSelectorChanged);
    $("#crafting_count").change(onCraftingSelectorChanged);

    loadRecipebook("data/vanilla.json");
    loadRecipebook("data/buildcraft.json");
});

function onCraftingSelectorChanged() {
    var recipeName = $("#crafting_selector option:selected").val();
    var recipe = findRecipe(recipeName);
    if (recipe === undefined) {
        $("#crafting_error").html("Cannot find recipe for " + recipeName);
        $("#crafting_error").fadeIn(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).fadeOut(FADE_DURATION);
    } else {
        var count = parseInt($("#crafting_count option:selected").val());
        var inventory = createManifest();
        var missingMaterials = recipe.computeMissingMaterials(inventory, count);
        $("#missing_materials").html(missingMaterials.toHtml());
        $("#leftover_materials").html(inventory.toHtml());
        $("#crafting_output").fadeIn(FADE_DURATION);
    }
}

function onRecipeLoadButtonClicked() {
    $("#reipebook_load_button").attr("disabled", true);
    loadRecipebook($("#recipebook_url").val(), function() {
        $("#recipebook_url").val("");
        $("#reipebook_load_button").removeAttr("disabled");
    });
}

// UI Helper Functions ////////////////////////////////////////////////////////////////////////////////////////////////

function loadRecipebook(recipebookUrl, onSuccess) {
    $.ajax({
        url: recipebookUrl,
        dataType: "text",
        success: function(text) {
            try {
                var recipebook = createRecipebook(recipebookUrl, $.parseJSON(text));
                __recipebooks.push(recipebook);

                recipebook.asTableRow().insertBefore($("#recipebook_table tr").last());

                updateCraftingSelector();
                $("#crafting").fadeIn(FADE_DURATION);

                if (onSuccess !== undefined) onSuccess();
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
    $selector.html("");

    if (__recipebooks.length == 0) {
        $selector.attr("disabled", "disabled");
        $selector.html("<option>No recipes</option>");
    } else {
        $(__recipebooks).each(function(i, recipebook) {
            var $optgroup = $("<optgroup label=\"" + recipebook.name + "\">");
            $selector.append($optgroup);

            for (var name in recipebook.recipes) {
                $optgroup.append("<option value=\"" + name + "\">" + name + "</option>");
            }
        });
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

function createRecipe(data) {
    var object = {output: [], input: [], tools: data.tools};

    $.each(data.output, function(index, value) {
        object.output.push({count: value[0], name: value[1]});
    });

    $.each(data.input, function(index, value) {
        object.input.push({count: value[0], name: value[1]});
    });

    // Methods ////////////////////////////////////////////

    object.computeMissingMaterials = function(inventory, count) {
        if (inventory === undefined) inventory = createManifest();
        if (count === undefined) count = 1;
        var missingMaterials = createManifest();
        var queue = [];

        function craftItem(ingredient) {
            var recipe = findRecipe(ingredient.name);
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
                        if (findRecipe(tool) === undefined) {
                            inventory.add(1, tool);
                            missingMaterials.add(1, tool);
                        } else {
                            craftItem({count: 1, name: tool});
                        }
                    }
                });
            }
            return recipe;
        }

        queue.push({count: count, name: object.output[0].name});

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

        inventory.add(object.output[0].count * count, object.output[0].name);
        return missingMaterials;
    }

    return object;
}

// RecipeBook Object //////////////////////////////////////////////////////////////////////////////////////////////////

function createRecipebook(sourceUrl, data) {
    var object = {
        name: data.name,
        description: data.description,
        sourceUrl: sourceUrl,
        recipes: {}
    };

    $(data.recipes).each(function(i, data) {
        var recipe = createRecipe(data);
        $(recipe.output).each(function(j, output) {
            object.recipes[output.name] = recipe
        });
    });

    object.asTableRow = function() {
        return $(
            "<tr>" +
                "<td width=\"25%\"><a target=\"new\" href=\"" + object.sourceUrl + "\">" + object.name + "</a></td>" +
                "<td width=\"*\">" + object.description + "</td>" +
            "</tr>"
        );
    };

    return object;
}

function findRecipe(name) {
    for (var i = 0; i < __recipebooks.length; i++) {
        var recipe = __recipebooks[i].recipes[name];
        if (recipe !== undefined) return recipe;
    }
    return undefined;
}

