#
# Crafting Guide - fixtures.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Item    = require "./game/item"
Mod     = require "./game/mod"
ModPack = require "./game/mod_pack"
Recipe  = require "./game/recipe"
Stack   = require "./game/stack"

# Instance Creation Fixtures ###########################################################################################

exports.createModPack = createModPack = (attributes={})->
    attributes.id ?= _.uniqueId "mod-pack-"
    attributes.displayName ?= "Test ModPack"
    return new ModPack attributes

exports.createMod = createMod = (attributes={})->
    attributes.modPack ?= createModPack()
    attributes.id ?= _.uniqueId "mod-"
    attributes.displayName ?= "Test Mod"
    return new Mod attributes

exports.createItem = createItem = (attributes={})->
    attributes.mod ?= createMod()
    attributes.id ?= _.uniqueId "item-"
    attributes.displayName ?= _.uniqueId "Test Item "
    return new Item attributes

exports.createRecipe = createRecipe = (attributes={})->
    attributes.id ?= _.uniqueId "recipe-"
    attributes.output ?= createItem()
    return new Recipe attributes

exports.createStack = createStack = (attributes={})->
    attributes.item ?= createItem()
    attributes.quantity ?= 1
    return new Stack attributes

# Item Configuration Fixtures ##########################################################################################

exports.configureBucket = configureBucket = (mod)->
    bucket = mod.modPack.findItem "bucket"
    if not bucket?
        ironIngot     = configureIronIngot mod
        bucket        = createItem mod:mod, id:"bucket", displayName:"Bucket"
        craftingTable = configureCraftingTable mod

        recipe = createRecipe output:createStack item:bucket
        recipe.setInputAt 0, 0, createStack item:ironIngot
        recipe.setInputAt 1, 1, createStack item:ironIngot
        recipe.setInputAt 2, 0, createStack item:ironIngot
        recipe.addTool craftingTable

    return bucket

exports.configureCake = configureCake = (mod)->
    cake = mod.modPack.findItem "cake"
    if not cake?
        bucket        = configureBucket mod
        cake          = createItem mod:mod, id:"cake", displayName:"Cake"
        craftingTable = configureCraftingTable mod
        egg           = configureEgg mod
        milkBucket    = configureMilkBucket mod
        sugar         = configureSugar mod
        wheat         = configureWheat mod

        recipe = createRecipe output:createStack item:cake
        recipe.setInputAt 0, 0, createStack item:milkBucket
        recipe.setInputAt 1, 0, createStack item:milkBucket
        recipe.setInputAt 2, 0, createStack item:milkBucket
        recipe.setInputAt 0, 1, createStack item:sugar
        recipe.setInputAt 1, 1, createStack item:egg
        recipe.setInputAt 2, 1, createStack item:sugar
        recipe.setInputAt 0, 2, createStack item:wheat
        recipe.setInputAt 1, 2, createStack item:wheat
        recipe.setInputAt 2, 2, createStack item:wheat
        recipe.addTool craftingTable
        recipe.addExtra createStack item:bucket, quantity:3

    return cake

exports.configureCoal = configureCoal = (mod)->
    coal = mod.modPack.findItem "coal"
    if not coal?
        coal = createItem mod:mod, id:"coal", displayName:"Coal"
    return coal

exports.configureCobblestone = configureCobblestone = (mod)->
    cobblestone = mod.modPack.findItem "cobblestone"
    if not cobblestone?
        cobblestone = createItem mod:mod, displayName:"Cobblestone"
    return cobblestone

exports.configureCraftingTable = configureCraftingTable = (mod)->
    craftingTable = mod.modPack.findItem "crafting_table"
    if not craftingTable?
        craftingTable = createItem mod:mod, id:"crafting_table", displayName:"Crafting Table"
        oakPlanks     = configureOakPlank mod

        recipe = createRecipe output:createStack item:craftingTable
        recipe.setInputAt 0, 0, createStack item:oakPlanks
        recipe.setInputAt 1, 0, createStack item:oakPlanks
        recipe.setInputAt 0, 1, createStack item:oakPlanks
        recipe.setInputAt 1, 1, createStack item:oakPlanks

    return craftingTable

exports.configureEgg = configureEgg = (mod)->
    egg = mod.modPack.findItem "egg"
    if not egg?
        egg = createItem mod:mod, id:"egg", displayName:"Egg"
    return egg

exports.configureFurnace = configureFurnace = (mod)->
    furnace = mod.modPack.findItem "furnace"
    if not furnace?
        cobblestone   = configureCobblestone mod
        craftingTable = configureCraftingTable mod
        furnace       = createItem mod:mod, displayName:"Furnace"

        recipe = createRecipe output:createStack item:furnace
        recipe.setInputAt 0, 0, createStack item:cobblestone
        recipe.setInputAt 1, 0, createStack item:cobblestone
        recipe.setInputAt 2, 0, createStack item:cobblestone
        recipe.setInputAt 0, 1, createStack item:cobblestone
        recipe.setInputAt 2, 1, createStack item:cobblestone
        recipe.setInputAt 0, 2, createStack item:cobblestone
        recipe.setInputAt 1, 2, createStack item:cobblestone
        recipe.setInputAt 2, 2, createStack item:cobblestone
        recipe.addTool craftingTable

    return furnace

exports.configureIronIngot = configureIronIngot = (mod)->
    ironIngot = mod.modPack.findItem "iron_ingot"
    if not ironIngot?
        coal      = configureCoal mod
        furnace   = configureFurnace mod
        ironIngot = createItem mod:mod, id:"iron_ingot", displayName:"Iron Ingot"
        ironOre   = configureIronOre mod

        recipe = createRecipe output:createStack item:ironIngot, quantity:8
        recipe.setInputAt 1, 0, createStack item:ironOre, quantity:8
        recipe.setInputAt 1, 2, createStack item:coal
        recipe.addTool furnace

    return ironIngot

exports.configureIronBlock = configureIronBlock = (mod)->
    ironBlock = mod.modPack.findItem "iron_block"
    if not ironBlock?
        craftingTable = configureCraftingTable mod
        ironBlock = createItem mod:mod, id:"iron_block", displayName:"Iron Block"
        ironIngot = configureIronIngot mod

        recipe = createRecipe output:createStack item:ironBlock
        for x in [0..2]
            for y in [0..2]
                recipe.setInputAt x, y, createStack item:ironIngot
        recipe.addTool craftingTable

        recipe = createRecipe output:createStack item:ironIngot, quantity:9
        recipe.setInputAt 1, 1, createStack item:ironBlock

    return ironBlock

exports.configureIronSword = configureIronSword = (mod)->
    ironSword = mod.modPack.findItem "iron_sword"
    if not ironSword?
        craftingTable = configureCraftingTable mod
        ironIngot     = configureIronIngot mod
        ironSword     = createItem mod:mod, id:"iron_sword", displayName:"Iron Sword"
        stick         = configureStick mod

        recipe = createRecipe output:createStack item:ironSword
        recipe.setInputAt 1, 0, createStack item:ironIngot
        recipe.setInputAt 1, 1, createStack item:ironIngot
        recipe.setInputAt 1, 2, createStack item:stick
        recipe.addTool craftingTable

    return ironSword

exports.configureIronShovel = configureIronShovel = (mod)->
    ironShovel = mod.modPack.findItem "iron_shovel"
    if not ironShovel?
        craftingTable = configureCraftingTable mod
        ironIngot     = configureIronIngot mod
        ironShovel    = createItem mod:mod, id:"iron_shovel", displayName:"Iron Shovel"
        stick         = configureStick mod

        recipe = createRecipe output:createStack item:ironShovel
        recipe.setInputAt 1, 0, createStack item:ironIngot
        recipe.setInputAt 1, 1, createStack item:stick
        recipe.setInputAt 1, 2, createStack item:stick
        recipe.addTool craftingTable

    return ironShovel

exports.configureIronOre = configureIronOre = (mod)->
    ironOre = mod.modPack.findItem "iron_ore"
    if not ironOre?
        ironOre = createItem mod:mod, id:"iron_ore", displayName:"Iron Ore"
    return ironOre

exports.configureMilk = configureMilk = (mod)->
    milk = mod.modPack.findItem "milk"
    if not milk?
        milk = createItem mod:mod, id:"milk", displayName:"Milk"
    return milk

exports.configureMilkBucket = configureMilkBucket = (mod)->
    milkBucket = mod.modPack.findItem "milk_bucket"
    if not milkBucket?
        bucket     = configureBucket mod
        milk       = configureMilk mod
        milkBucket = createItem mod:mod, id:"milkBucket", displayName:"Milk Bucket"

        recipe = createRecipe output:createStack item:milkBucket
        recipe.setInputAt 1, 0, createStack item:milk
        recipe.setInputAt 1, 1, createStack item:bucket

    return milkBucket

exports.configureOakPlank = configureOakPlank = (mod)->
    oakPlanks = mod.modPack.findItem "oak_planks"
    if not oakPlanks?
        oakPlanks = createItem mod:mod, id:"oak_planks", displayName:"Oak Planks"
        oakWood   = configureOakWood mod

        recipe = createRecipe output:createStack item:oakPlanks, quantity:4
        recipe.setInputAt 1, 1, createStack item:oakWood

    return oakPlanks

exports.configureOakWood = configureOakWood = (mod)->
    oakWood = mod.modPack.findItem "oak_wood"
    if not oakWood?
        oakWood = createItem mod:mod, id:"oak_wood", displayName:"Oak Wood"
    return oakWood

exports.configureObsidian = configureObsidian = (mod)->
    obsidian = mod.modPack.findItem "obsidian"
    if not obsidian?
        obsidian = createItem mod:mod, id:"obsidian", displayName:"Obsidian"
    return obsidian

exports.configureRedstoneDust = configureRedstoneDust = (mod)->
    redstoneDust = mod.modPack.findItem "redstone_dust"
    if not redstoneDust?
        redstoneDust = createItem mod:mod, id:"redstone_dust", displayName:"Redstone Dust"
    return redstoneDust

exports.configureStick = configureStick = (mod)->
    stick = mod.modPack.findItem "stick"
    if not stick?
        oakPlanks = configureOakPlank mod
        stick     = createItem mod:mod, id:"stick", displayName:"Stick"

        recipe = createRecipe output:createStack item:stick, quantity:4
        recipe.setInputAt 0, 0, createStack item:oakPlanks
        recipe.setInputAt 0, 1, createStack item:oakPlanks

    return stick

exports.configureSugar = configureSugar = (mod)->
    sugar = mod.modPack.findItem "sugar"
    if not sugar?
        sugar     = createItem mod:mod, id:"sugar", displayName:"Sugar"
        sugarCane = configureSugarCane mod

        recipe = createRecipe output:createStack item:sugar
        recipe.setInputAt 1, 1, createStack item:sugarCane

    return sugar

exports.configureSaw = configureSaw = (mod)->
    saw = mod.modPack.findItem "saw"
    if not saw?
        craftingTable = configureCraftingTable mod
        ironBlock     = configureIronBlock mod
        ironIngot     = configureIronIngot mod
        oakPlank      = configureOakPlank mod
        oakWood       = configureOakWood mod
        redstoneDust  = configureRedstoneDust mod
        saw           = createItem mod:mod, id:"saw", displayName:"Saw"

        recipe = createRecipe output:createStack item:saw
        recipe.setInputAt 0, 0, createStack item:oakPlank
        recipe.setInputAt 1, 0, createStack item:ironIngot
        recipe.setInputAt 2, 0, createStack item:oakPlank
        recipe.setInputAt 0, 1, createStack item:oakPlank
        recipe.setInputAt 1, 1, createStack item:ironBlock
        recipe.setInputAt 2, 1, createStack item:oakPlank
        recipe.setInputAt 0, 2, createStack item:oakPlank
        recipe.setInputAt 1, 2, createStack item:redstoneDust
        recipe.setInputAt 2, 2, createStack item:oakPlank
        recipe.addTool craftingTable

        recipe = createRecipe output:createStack item:oakPlank, quantity:8
        recipe.setInputAt 1, 1, createStack item:oakWood
        recipe.addTool saw

    return saw

exports.configureSugarCane = configureSugarCane = (mod)->
    sugarCane = mod.modPack.findItem "sugar_cane"
    if not sugarCane?
        sugarCane = createItem mod:mod, id:"sugar_cane", displayName:"Sugar Cane"
    return sugarCane

exports.configureWheat = configureWheat = (mod)->
    wheat = mod.modPack.findItem "wheat"
    if not wheat?
        wheat = createItem mod:mod, id:"wheat", displayName:"Wheat"
    return wheat
