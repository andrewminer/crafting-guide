// Constants //////////////////////////////////////////////////////////////////////////////////////////////////////////

var FADE_DURATION = 250; // ms
var ERROR_DISPLAY_DURATION = 5000; // ms

// Global Variables ///////////////////////////////////////////////////////////////////////////////////////////////////

var __recipebooks = [];
var __toolsIncluded = false;

// UI Functions ///////////////////////////////////////////////////////////////////////////////////////////////////////

$(function() {
    $("#recipebook_load_button").click(onRecipeLoadButtonClicked);
    $("#crafting_selector").change(onCraftingSelectorChanged);
    $("#crafting_count").change(onCraftingSelectorChanged);
    $("#tools_included").change(onIncludeToolsChanged);

    loadRecipebook("data/vanilla.json", function() {
        loadRecipebook("data/buildcraft.json", function() {
            loadRecipebook("data/industrial_craft.json", function() {
                loadRecipebook("data/thermal_expansion.json", function() {
                    parseUrlParameters();
                    onCraftingSelectorChanged();
                });
            });
        });
    });
});

function onCraftingSelectorChanged() {
    var recipeName = $("#crafting_selector option:selected").val();
    var count = parseInt($("#crafting_count option:selected").val());
    if (recipeName === undefined) return;
    if (count === undefined) return;

    updatePageState(count, recipeName);

    var recipe = findRecipe(recipeName);
    if (recipe === undefined) {
        $("#crafting_error").html("Cannot find recipe for " + recipeName);
        $("#crafting_error").fadeIn(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).fadeOut(FADE_DURATION);
    } else {
        var inventory = createManifest();
        var craftedItems = createManifest();
        var missingMaterials = createManifest();
        for (var i = 0; i < count; i++) {
            recipe.craft(inventory, craftedItems, missingMaterials);
            if (inventory.contains(count, recipeName)) break;
        }

        $("#missing_materials").html(missingMaterials.toHtml());
        $("#crafted_items").html(craftedItems.toHtml());
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

function onIncludeToolsChanged() {
    __toolsIncluded = $("#tools_included").is(":checked");
    onCraftingSelectorChanged()
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

        if ($("#crafting_selector option:selected").val() === undefined) {
            $("#crafting_error").html("Cannot find recipe for " + recipeName);
            $("#crafting_error").fadeIn(FADE_DURATION).delay(ERROR_DISPLAY_DURATION).fadeOut(FADE_DURATION);
        }
    }
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

            var names = [];
            for (var name in recipebook.recipes) {
                names.push(name);
            }
            names.sort();

            for (var i = 0; i < names.length; i++) {
                $optgroup.append("<option value=\"" + names[i] + "\">" + names[i] + "</option>");
            }
        });
        $selector.removeAttr("disabled");
    }
}

function updatePageState(count, recipeName) {
    var newTitle = "Crafting Guide: " + count + " " + recipeName;
    var newLink = "?count=" + count + "&recipeName=" + encodeURIComponent(recipeName);
    newLink = newLink.replace(/%20/g, "+");

    document.title = newTitle;
    history.pushState({count: count, name: recipeName}, newTitle, newLink);
    ga('send', 'pageview');
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

    object.removeAll = function() {
        object.materials = {};
    }

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

    object.craft = function(inventory, craftedItems, missingMaterials) {
        if (inventory === undefined) inventory = createManifest();
        if (craftedItems === undefined) craftedItems = createManifest();
        if (missingMaterials === undefined) missingMaterials = createManifest();
        var toCraftManifest = createManifest();
    
        function drainCraftingManifest(consumeItems) {
            for (var name in toCraftManifest.materials) {
                var count = toCraftManifest.materials[name];
                var itemRecipe = findRecipe(name);

                for (var i = 0; i < count; i++) {
                    if (inventory.contains(1, name)) {
                        if (consumeItems) {
                            inventory.remove(1, name);
                        }
                    } else if (itemRecipe === undefined) {
                        missingMaterials.add(1, name);
                        if (! consumeItems) {
                            inventory.add(1, name);
                        }
                    } else {
                        itemRecipe.craft(inventory, craftedItems, missingMaterials);
                        if (consumeItems) {
                            inventory.remove(1, name);
                        }
                    }
                }
            }
            toCraftManifest.removeAll();
        }

        if (__toolsIncluded) {
            $(object.tools).each(function(i, tool) {
                if (! inventory.contains(1, tool)) {
                    toCraftManifest.add(1, tool);
                }
            });
            drainCraftingManifest(false);
        }

        $(object.input).each(function(i, input) {
            for (var j = 0; j < input.count; j++) {
                toCraftManifest.add(1, input.name);
            }
        });
        drainCraftingManifest(true);

        $(object.output).each(function(i, output) {
            craftedItems.add(output.count, output.name);
            inventory.add(output.count, output.name);
        });
    };

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

