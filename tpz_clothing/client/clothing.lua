
local TPZ = exports.tpz_core:getCoreAPI()

local SELECTED_CATEGORY_TYPE  = nil
local SELECTED_CATEGORY_LABEL = nil

local PREVIOUS_SELECTED_SKIN_COMP_CATEGORY = nil
local PREVIOUS_SELECTED_SKIN_COMP_DATA = nil 

local PlayerSkin = nil -- The selected outfits only, when saving, it replaces or adds the bought ones.
local Clothing = {}

local modules = nil

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local function GetGender()
    local Gender = IsPedMale(PlayerPedId()) and "Male" or "Female"
    return Gender
end

local HasBoughtComponent = function(category, index, palette)
    local PlayerData = GetPlayerData()

    if PlayerData.Clothing.purchased[category] == nil then 
        return 0
    end

    for _, outfit in pairs (PlayerData.Clothing.purchased[category]) do

        if tonumber(outfit.id) == index and tonumber(outfit.palette) == palette then  
            return 1
        end

    end

    return 0

end

local GetLabelNameFromClothingCategory = function(category)

	for _, cloth in pairs (Config.ClothingCategories) do 

		if category == cloth.category then
			return cloth.label

		end

	end

	return 'N/A'

end

-----------------------------------------------------------
--[[ Public Getters & Setters ]]--
-----------------------------------------------------------

function GetClothing()
    return Clothing
end

function GetPlayerSkinData()
    return PlayerSkin
end

function ClearPlayerSkin()
    PlayerSkin = nil 
end

--- organise and included data for clothing table
function LoadClothingData(targetSkinComp)

    -- loading core modules.
    modules = exports.tpz_core:getCoreAPI().modules() -- core modules getter.

    if PlayerSkin == nil then
        -- loading player skin comp.
        local data     = TPZ.GetPlayerClientData()
        local skinComp = json.decode(data.skinComp)

        PlayerSkin     = skinComp
    end

    if targetSkinComp ~= nil then

        local data     = TPZ.GetPlayerClientData()
        local skinComp = json.decode(data.skinComp)

        for category, data in pairs (targetSkinComp) do

            skinComp[category] = data

        end

        PlayerSkin = skinComp
    end

    -- loading clothing components.
    local cb = {}
    local playerComponents = exports.tpz_core:getCoreAPI().modules().file.load("component.data.playerComponents")

    while playerComponents == nil do 
        Wait(100)
    end
    
    local gender = GetGender()

    for category, value in pairs(playerComponents[gender]) do

        local categoryTable = {}

        for _, v in ipairs(value) do

            local typeTable = {}

            for _, va in ipairs(v) do
                table.insert(typeTable, { hex = va.hash, remove = va.remove, showSkin = va.showSkin or false, needsFix = va.needsFix or false })
            end

            table.insert(categoryTable, typeTable)
        end


        cb[category] = categoryTable
    end
   
    Clothing = cb

    return cb
end


function GetSelectedCategoryType()
    return SELECTED_CATEGORY_TYPE
end

-----------------------------------------------------------
--[[ Clothing Functions ]]--
-----------------------------------------------------------

LoadSelectedCategoryClothingData = function(category, title)
    local PlayerData    = GetPlayerData()
    local LocationIndex = GetPlayerData().LocationIndex
    SELECTED_CATEGORY_TYPE = string.lower(category)

	local componentData = PlayerSkin[category] or { id = 0, palette = 1, tint0 = 0, tint1 = 0, tint2 = 0 }
	local title = GetLabelNameFromClothingCategory(category)

    SendNUIMessage( { action = 'selectedCategory', 

        result = {
            max          = #Clothing[SELECTED_CATEGORY_TYPE],
			current      = componentData.id,
			title        = title,
        }
    })

    if PlayerSkin[category] then
        PREVIOUS_SELECTED_SKIN_COMP_CATEGORY = category
        PREVIOUS_SELECTED_SKIN_COMP_DATA = PlayerSkin[category]
        
        local bought = HasBoughtComponent(category, PlayerSkin[category].id, PlayerSkin[category].palette)

        if bought == 0 and PlayerSkin[category].id ~= 0 then 

            if PlayerData.Clothing.purchased[category] == nil then 
                PlayerData.Clothing.purchased[category] = {}
            end

            table.insert(PlayerData.Clothing.purchased[category], { id = PlayerSkin[category].id, palette = PlayerSkin[category].palette })
            TriggerServerEvent("tpz_clothing:server:buy", category, PlayerSkin[category].id, PlayerSkin[category].palette, 1)

        end

    end

	componentData.actionType = 'COMPONENT'
    LoadSelectedOutfitById(componentData, true)

end


LoadSelectedOutfitById = function(data, firstLoad)
    local texture_id, palette, tint0, tint1, tint2, actionType = data.id, data.palette or 1, data.tint0, data.tint1, data.tint2, data.actionType
    local player = PlayerPedId()

	if PlayerSkin[SELECTED_CATEGORY_TYPE] == nil then
		PlayerSkin[SELECTED_CATEGORY_TYPE] = {}
	end

	PlayerSkin[SELECTED_CATEGORY_TYPE] = { id = texture_id, palette = palette, tint0 = tint0, tint1 = tint1, tint2 = tint2, drawable = 0, albedo = 0, normal = 0, material = 0}

    local bought = HasBoughtComponent(SELECTED_CATEGORY_TYPE, texture_id, palette)

    if texture_id == 0 then
        bought = -1
    end

	SendNUIMessage( { 
        action = 'setOutfitComponentInformation', 
        current = palette, 
		tint0   = PlayerSkin[SELECTED_CATEGORY_TYPE].tint0,
		tint1   = PlayerSkin[SELECTED_CATEGORY_TYPE].tint1,
		tint2   = PlayerSkin[SELECTED_CATEGORY_TYPE].tint2,
        max = (Clothing[SELECTED_CATEGORY_TYPE][texture_id] and #Clothing[SELECTED_CATEGORY_TYPE][texture_id] or 1),
        bought = bought,
        bought_locale = Locales['NUI_SELECT_BOUGHT'],
        buy_locale    = Locales['NUI_SELECT_BUY'],
        not_for_sell_locale = Locales['NUI_SELECT_NOT_FOR_SELL'],
        cost_locale   = string.format(Locales['NUI_SELECT_COST'], Locales[SELECTED_CATEGORY_TYPE], string.format("%.2f", Config.OutfitCosts[SELECTED_CATEGORY_TYPE]))
    })

    if actionType == 'COMPONENT' or actionType == 'PALETTE' then

        if texture_id ~= 0 then

            local outfitHash = Clothing[SELECTED_CATEGORY_TYPE][texture_id][palette].hex

            modules.IsPedReadyToRender()
            modules.ApplyShopItemToPed(outfitHash)

        else
			PlayerSkin[SELECTED_CATEGORY_TYPE] = { id = 0, palette = 1, tint0 = 0, tint1 = 0, tint2 = 0, drawable = 0, albedo = 0, normal = 0, material = 0}
            RemoveTagFromMetaPed(player, Config.ComponentCategories[SELECTED_CATEGORY_TYPE])
        end

    elseif actionType == 'TINT' and texture_id ~= 0 then
        modules.IsPedReadyToRender()

		local TagData = GetMetaPedData(SELECTED_CATEGORY_TYPE == "Boots" and "boots" or SELECTED_CATEGORY_TYPE)

		if TagData then
			local palette = Config.clothesPalettes[palette]
			
			PlayerSkin[SELECTED_CATEGORY_TYPE].drawable = TagData.drawable
			PlayerSkin[SELECTED_CATEGORY_TYPE].albedo   = TagData.albedo
			PlayerSkin[SELECTED_CATEGORY_TYPE].normal   = TagData.normal
			PlayerSkin[SELECTED_CATEGORY_TYPE].material = TagData.material

			SetMetaPedTag(PlayerPedId(), TagData.drawable, TagData.albedo, TagData.normal, TagData.material, palette, tint0, tint1, tint2)
		end
    end

    modules.UpdatePedVariation()

	FixCategoryClothingProperly(SELECTED_CATEGORY_TYPE)
end

BuySelectedCategoryItem = function(data)
    local texture_id, palette = data.id, data.palette

    if texture_id == 0 then 
        return 
    end

    local bought = HasBoughtComponent(SELECTED_CATEGORY_TYPE, texture_id, palette)

    if bought == 1 then 
        return 
    end

    TriggerServerEvent("tpz_clothing:server:buy", SELECTED_CATEGORY_TYPE, texture_id, palette)

end

-- When returning back to the categories, we check if the item the player has selected and wearing has been bought
-- if this item has not been bought, we reset the item back to the one the player was wearing.
-- ONLY if the player has bought this outfit can still be wearing it when going back to other outfit categories.
CheckBackOutfitCategoryPurchase = function(texture_id, palette)
    local category = SELECTED_CATEGORY_TYPE

    local bought   = HasBoughtComponent(category, texture_id, palette)

    if bought == 1 or texture_id == 0 then 

        return
    end

    local ped = PlayerPedId()

    modules.IsPedReadyToRender(ped)
    RemoveTagFromMetaPed(ped, Config.ComponentCategories[category])
    modules.UpdatePedVariation()

    Wait(150)

    if PREVIOUS_SELECTED_SKIN_COMP_CATEGORY == category then

        local data = PREVIOUS_SELECTED_SKIN_COMP_DATA

        if data.id ~= 0 then

            local outfitHash = Clothing[category][data.id][data.palette].hex

            modules.IsPedReadyToRender(ped)
            modules.ApplyShopItemToPed(outfitHash, ped)

            if data.drawable ~= 0 then
                local palette = Config.clothesPalettes[data.palette]
                
                SetMetaPedTag(ped, data.drawable, data.albedo, data.normal, data.material, palette, data.tint0, data.tint1, data.tint2)
            end

            modules.UpdatePedVariation(ped)
            
            FixCategoryClothingProperly(category, PlayerSkin, ped)

        end

    end

    PlayerSkin[SELECTED_CATEGORY_TYPE] = PREVIOUS_SELECTED_SKIN_COMP_DATA

    PREVIOUS_SELECTED_SKIN_COMP_CATEGORY = nil
    PREVIOUS_SELECTED_SKIN_COMP_DATA = nil

end


ResetOutfitByCategoryName = function()
    local ped  = PlayerPedId()
    local data = PREVIOUS_SELECTED_SKIN_COMP_DATA

    modules.IsPedReadyToRender()

    if data.id ~= 0 then

        local outfitHash = Clothing[SELECTED_CATEGORY_TYPE][data.id][data.palette].hex

        modules.ApplyShopItemToPed(outfitHash)

        if data.drawable ~= 0 then

            local palette = Config.clothesPalettes[data.palette]
        
            SetMetaPedTag(ped, data.drawable, data.albedo, data.normal, data.material, palette, data.tint0, data.tint1, data.tint2)
        end
        
    else
        RemoveTagFromMetaPed(ped, Config.ComponentCategories[SELECTED_CATEGORY_TYPE])
    end

    modules.UpdatePedVariation()

    FixCategoryClothingProperly(SELECTED_CATEGORY_TYPE, PlayerSkin, ped)

    SendNUIMessage( { 
        action = 'setOutfitComponentInformation',
        texture_id = data.id, 
        current = data.palette, 
		tint0   = data.tint0,
		tint1   = data.tint1,
		tint2   = data.tint2,
        max_textures = #Clothing[SELECTED_CATEGORY_TYPE],
        max = (Clothing[SELECTED_CATEGORY_TYPE][data.id] and #Clothing[SELECTED_CATEGORY_TYPE][data.id] or 1),
        bought = 1,
        bought_locale = Locales['NUI_SELECT_BOUGHT'],
        buy_locale    = Locales['NUI_SELECT_BUY'],
        not_for_sell_locale = Locales['NUI_SELECT_NOT_FOR_SELL'],
        cost_locale   = string.format(Locales['NUI_SELECT_COST'], Locales[SELECTED_CATEGORY_TYPE], string.format("%.2f", Config.OutfitCosts[SELECTED_CATEGORY_TYPE]))
    })


end

SetDefaultOutfitCategory = function(data)
    TriggerServerEvent("tpz_clothing:server:set_default_category_outfit", SELECTED_CATEGORY_TYPE, data)
end
