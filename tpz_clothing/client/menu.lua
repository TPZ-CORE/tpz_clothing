
local TPZ      = exports.tpz_core:getCoreAPI()
local MenuData = {}

TriggerEvent("tpz_menu_base:getData", function(call)
    MenuData = call
end)

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local CloseMenuProperly = function()
    MenuData.CloseAll()
    TaskStandStill(PlayerPedId(), 1)

    local PlayerData = GetPlayerData()

    PlayerData.HasMenuActive = false

    TriggerServerEvent("tpz_clothing:server:save")

end

local SetOutfitNameByDate = function(date, name)
    local PlayerData = GetPlayerData()

    for _, outfit in pairs (PlayerData.Clothing.outfits) do

        if tostring(outfit.date) == tostring(date) then
            outfit.name = name
        end

    end

end

local DeleteOutfitByDate = function(date, name)
    local PlayerData = GetPlayerData()

    for _, outfit in pairs (PlayerData.Clothing.outfits) do

        if tostring(outfit.date) == tostring(date) then
            table.remove(PlayerData.Clothing.outfits, _)
        end

    end

end

local GetOutfitDataByDate = function(date)
    local PlayerData = GetPlayerData()

    for _, outfit in pairs (PlayerData.Clothing.outfits) do

        if tostring(outfit.date) == tostring(date) then
            return outfit
        end

    end

    return nil

end


-----------------------------------------------------------
--[[ Menu Functions & Wardrobe Actions ]]--
-----------------------------------------------------------

function OpenWardrobe()
    local PlayerData = GetPlayerData()

    PlayerData.HasMenuActive = true

    TaskStandStill(PlayerPedId(), -1)

    if TPZ.GetTableLength(PlayerData.Clothing.outfits) <= 0 then
        SendNotification(nil, Locales['NO_OUTFITS_AVAILABLE'], "error")
        return
    end

    MenuData.CloseAll()

    local elements = {}

    for index, outfit in pairs (PlayerData.Clothing.outfits) do
        table.insert(elements, { name = outfit.name, label =  index .. ". " .. outfit.name, value = outfit.date})
    end

    table.insert(elements, { label = Locales['WARDROBE_MENU_EXIT'], value = "exit",  desc = Locales['WARDROBE_MENU_EXIT_DESC'], })

    MenuData.Open('default', GetCurrentResourceName(), 'wardrobe_outfits',

    {
        title = Locales['WARDROBE_MENU_OUTFITS'],

        subtext = "",
        align = Config.WardrobeMenuAlign,
        elements = elements,
    },

    function(data, menu)

        if (data.current == "backup") or (data.current.value == 'exit') then
            CloseMenuProperly()
            return
        end

        OpenSelectedWardrobeOutfitById(data.current.value, data.current.name)

    end,
    function(data, menu)
        CloseMenuProperly()
    end)

end

function OpenSelectedWardrobeOutfitById(outfitId, outfitName)
    local PlayerData = GetPlayerData()

    MenuData.CloseAll()
    
    local elements = {

        { label = Locales['WARDROBE_MENU_APPLY'],        value = "apply",   desc = Locales['WARDROBE_MENU_APPLY_DESC'], },
        { label = Locales['WARDROBE_MENU_SET_DEFAULT'],  value = "default", desc = Locales['WARDROBE_MENU_SET_DEFAULT_DESC'], },
        { label = Locales['WARDROBE_MENU_RENAME'],       value = "rename",  desc = Locales['WARDROBE_MENU_RENAME_DESC'], },
        { label = Locales['WARDROBE_MENU_DELETE'],       value = "delete",  desc = Locales['WARDROBE_MENU_DELETE_DESC'], },

        { label = Locales['WARDROBE_MENU_BACK'],         value = "back",    desc = Locales['WARDROBE_MENU_BACK_DESC'], },
    }
    
    MenuData.Open('default', GetCurrentResourceName(), 'wardrobe_outfits_options',

    {
        title = outfitName,

        subtext = "",
        align = Config.WardrobeMenuAlign,
        elements = elements,
    },

    function(data, menu)

        if (data.current == "backup") or (data.current.value == 'back') then
            OpenWardrobe()
            return
        end

        if data.current.value == 'apply' then

            modules = exports.tpz_core:getCoreAPI().modules() -- core modules getter.

            ClearPlayerSkin() -- clears clothing data for the stores.

            local OutfitData = GetOutfitDataByDate(outfitId)
            local Clothing   = LoadClothingData(OutfitData.comps)

            local ped        = PlayerPedId()

            for _category, _ in pairs (Config.ComponentCategories) do

                if OutfitData.comps[_category] ~= nil then
                    local category, data = _category, OutfitData.comps[_category]

                    modules.IsPedReadyToRender()
    
                    if data.id ~= 0 then
    
                        local outfitHash = Clothing[category][data.id][data.palette].hex
    
                        modules.ApplyShopItemToPed(outfitHash)
    
                        if data.drawable ~= 0 then
    
                            local palette = Config.clothesPalettes[data.palette]
                        
                            SetMetaPedTag(ped, data.drawable, data.albedo, data.normal, data.material, palette, data.tint0, data.tint1, data.tint2)
                        end
                        
                    else
                        RemoveTagFromMetaPed(ped, Config.ComponentCategories[category])
                    end
    
                    modules.UpdatePedVariation()
    
                    FixCategoryClothingProperly(category, OutfitData.comps, ped)
    
                else
                    RemoveTagFromMetaPed(ped, Config.ComponentCategories[_category])
                end

            end

        elseif data.current.value == 'rename' then

            local inputData = {
                title        = Locales['RENAME_OUTFIT_TITLE'],
                desc         = Locales['RENAME_OUTFIT_DESCRIPTION'],
                buttonparam1 = Locales['ACCEPT_BUTTON'],
                buttonparam2 = Locales['DECLINE_BUTTON']
            }
                                        
            TriggerEvent("tpz_inputs:getTextInput", inputData, function(cb)

                if cb ~= "DECLINE" or cb ~= Locales['DECLINE_BUTTON'] then
                    MenuData.CloseAll()

                    TriggerServerEvent("tpz_clothing:server:wardrobes:update", 'RENAME', { outfitId, cb })
                    SendNotification(nil, Locales['RENAMED_OUTFIT'], "success")

                    SetOutfitNameByDate(outfitId, cb)
                    OpenWardrobe()
                end

            end) 

        elseif data.current.value == 'default' then

            TriggerServerEvent("tpz_clothing:server:wardrobes:update", 'SET_DEFAULT', { outfitId })
            SendNotification(nil, Locales['REPLACED_OUTFIT'], "success")

        elseif data.current.value == 'delete' then

            TriggerServerEvent("tpz_clothing:server:wardrobes:update", 'DELETE', { outfitId })
            SendNotification(nil, Locales['DELETED_OUTFIT'], "success")

            DeleteOutfitByDate(outfitId)

            if TPZ.GetTableLength(PlayerData.Clothing.outfits) <= 0 then
                CloseMenuProperly()
                return
            end

            OpenWardrobe()
        end


    end,

    function(data, menu)
        OpenWardrobe()
    end)

end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    local PlayerData = GetPlayerData()

    if PlayerData.HasMenuActive then
    
        MenuData.CloseAll()
        TaskStandStill(PlayerPedId(), 1)
    end

end)