
local TPZ             = exports.tpz_core:getCoreAPI()
local MP              = exports.tpz_characters.getMPConfiguration() -- Returns tpz_characters MP Configuration file.
local ClothHashNames = exports.tpz_characters.getClothHashNamesList() -- Returns all the cloth hash names list.

local MenuData = {}

TriggerEvent("tpz_menu_base:getData", function(call)
    MenuData = call
end)


local ClothingList       = {}
local SkinData           = {}

local LoadedSkinData = false

local BlacklistedTypes = {
    ['eyes'] = true,
    ['heads'] = true,
    ['waist'] = true,
    ['bodies_lower'] = true,
    ['teeth'] = true,
    ['hair'] = true,
}

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local GetGender = function ()
    if IsPedMale(PlayerPedId()) then return "male" else return "female" end
end

local LoadSelectedListResults = function(sex)

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_clothing:getPlayerDefaultOutfit", function(data)

        local skin = json.decode(data)

        for index, type in pairs (ClothHashNames) do

            if type.is_multiplayer and type.ped_type == sex and type.category_hashname ~= nil and type.category_hashname ~= "" then
    
                if not MP.BlackListedHashDecSigns[type.hash_dec_signed] and BlacklistedTypes[string.lower(type.category_hashname)] == nil then

                    local _type = string.lower(type.category_hashname)

                    if ClothingList[_type] == nil then

                        SkinData[_type] = -1

                        ClothingList[_type]         = {}
                        ClothingList[_type].tag     = _type

                        ClothingList[_type].list    = {}
                        ClothingList[_type].max     = 0
                        ClothingList[_type].current = -1
                    end

                    ClothingList[_type].max = ClothingList[_type].max + 1

                    ClothingList[_type].list[ClothingList[_type].max]               = {}
                    ClothingList[_type].list[ClothingList[_type].max].hash          = type.hash
                    ClothingList[_type].list[ClothingList[_type].max].hashDecSigned = tonumber(type.hash_dec_signed)

                    if skin[_type] and tonumber(skin[_type]) == tonumber(type.hash_dec_signed) then
                        ClothingList[_type].current = ClothingList[_type].max
                        SkinData[_type] = tonumber(type.hash_dec_signed)
                    end

                    ClothingList[tonumber(type.hash_dec_signed)] = type.hash

                end
    
            end
    
        end
        
        LoadedSkinData = true

    end)

end

local CloseMenuProperly = function()
    MenuData.CloseAll()
    DestroyAllCams(true)

    TaskStandStill(PlayerPedId(), 1)

    local dict = Config.HandsUpAnimation.Dict
    local body = Config.HandsUpAnimation.Body

    if IsEntityPlayingAnim(PlayerPedId(), dict, body, 3) then
        ClearPedTasks(PlayerPedId())
        RemoveAnimDict(dict)
    end

    SkinData           = nil
    SkinData           = {}

    LoadedSkinData     = false
    
    ClothingList       = nil
    ClothingList       = {}

    local PlayerData = GetPlayerData()

    PlayerData.IsBusy = false
    PlayerData.HasStoreOpen = false

end

-----------------------------------------------------------
--[[ Menu Functions & Store Actions ]]--
-----------------------------------------------------------

function OpenCharacterCustomization()
    MenuData.CloseAll()
    
    local PlayerData = GetPlayerData()

    PlayerData.IsBusy       = true
    PlayerData.HasStoreOpen = true

    local _player = PlayerPedId()
    TaskStandStill(_player, -1)

    if not LoadedSkinData then

        LoadSelectedListResults(GetGender())
    end

    while not LoadedSkinData do
        Wait(250)
    end

    local elements = {

        { label = Locales['MAIN_MENU']['CLOTHING'].label,  value = "clothing", desc = Locales['MAIN_MENU']['CLOTHING'].desc, },
        { label = Locales['MAIN_MENU']['SAVE'].label,      value = "save",     desc = Locales['MAIN_MENU']['SAVE'].desc, },
        { label = Locales['MAIN_MENU']['EXIT'].label,      value = "exit",     desc = Locales['MAIN_MENU']['EXIT'].desc, },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'main',

    {
        title    = Locales['CLOTHING_TITLE'],
        subtext  = Locales['CUSTOMIZE_CLOTHING_DESCRIPTION'],
        align    = "left",
        elements = elements,
        lastmenu = "notMenu"
    },

    function(data, menu)

        if (data.current == "backup") then
            CloseMenuProperly() -- DOES NOT SAVE
            return
        end

        if data.current.value == "clothing" then
            OpenCharacterOutfitCustomization('clothing')

        elseif data.current.value == "save" then

            local inputData = {
                title        = Locales['SAVE_OUTFIT_TITLE'],
                desc         = Locales['SAVE_OUTFIT_DESCRIPTION'],
                buttonparam1 = Locales['ACCEPT_BUTTON'],
                buttonparam2 = Locales['DECLINE_BUTTON']
            }
                                        
            TriggerEvent("tpz_inputs:getTextInput", inputData, function(cb)

                if cb ~= "DECLINE" or cb ~= Locales['DECLINE_BUTTON'] then
                    TriggerServerEvent("tpz_clothing:server:saveOutfit", cb, SkinData)
                    SendNotification(nil, Locales['SAVED_OUTFIT'], "success")

                    CloseMenuProperly()
                end

            end) 


        elseif data.current.value == "exit" then
            CloseMenuProperly() -- DOES NOT SAVE
        end

    end,

    function(data, menu)
        CloseMenuProperly() -- DOES NOT SAVE
    end)

end

function OpenCharacterOutfitCustomization(actionType)
    MenuData.CloseAll()

    local _player = PlayerPedId()
    local sex     = GetGender()

    local elements = {}

    for _, element in pairs (MP.CustomizationElements) do

        if element.action == 'clothing' and ClothingList[element.tag] then

            element.desc = Locales['TOTAL_TYPES'] .. element.label .. " : " .. ClothingList[element.tag].max

            element.value = ClothingList[element.tag].current
    
            if not element.sex then
    
                element.max = ClothingList[element.tag].max
                table.insert(elements, element)
    
            elseif element.sex and element.sex == sex then
    
                element.max = ClothingList[element.tag].max
                table.insert(elements, element)
            end

        end

    end

    MenuData.Open('default', GetCurrentResourceName(), 'sub_' .. actionType,

        {
            title = Locales['CLOTHING_TITLE'],

            subtext = Locales['CUSTOMIZE_DESCRIPTION'],
            align = "left",
            elements = elements,
            lastmenu = "OpenCharacterCustomization"
        },

        function(data, menu)

            if (data.current == "backup") then
                OpenCharacterCustomization()
                return
            end

            for index, el in pairs (elements) do

                if data.current.tag == el.tag and tonumber(data.current.value) < tonumber(data.current.max) then

                    
                    local tag = data.current.tag

                    if data.current.value <= 0 then

                        Citizen.InvokeNative(0xD710A5007C2AC539, _player, MP.DefaultHashList[tag], 0)

                        if tag == 'gunbelts' then
                            Citizen.InvokeNative(0xD710A5007C2AC539, _player, 0x3F1F01E5, 0) 
                            Citizen.InvokeNative(0xD710A5007C2AC539, _player, 0xDA0E2C55, 0) 
                        end

                        UpdateVariation(_player)
                        
                        ClothingList[tag].current = -1
                        SkinData[tag] = -1

                    elseif data.current.value > 0 then

                        local clothingData = ClothingList[tag].list[data.current.value]
                        local hash = clothingData.hash

                        Citizen.InvokeNative(0xD3A7B003ED343FD9, _player, hash, true, true, true)
                        UpdateVariation(_player)

                        if Config.Debug then
                            print("changed " .. tag .. ", to the following Hash Dec Signed: " .. clothingData.hashDecSigned )
                        end
        
                        ClothingList[tag].current = data.current.value
                        SkinData[tag] = clothingData.hashDecSigned

                    end
                end

            end


        end,
    function(data, menu)
        OpenCharacterCustomization()
    end)
end

-----------------------------------------------------------
--[[ Menu Functions & Wardrobe Actions ]]--
-----------------------------------------------------------

function OpenWardrobe()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_clothing:callbacks:getPlayerOutfits", function(outfits)

        if TPZ.GetTableLength(outfits) <= 0 then
            SendNotification(nil, Locales['NO_OUTFITS_AVAILABLE'], "error")
            return
        end

        MenuData.CloseAll()

        local elements = {}

        for _, outfit in pairs (outfits) do
            table.insert(elements, { name = outfit.title, skincomp = outfit.comps, label =  _ .. ". " .. outfit.title, value = outfit.id})
        end

        table.insert(elements, { label = Locales['WARDROBE_MENU']['BACK'].label, value = "back",  desc = Locales['WARDROBE_MENU']['BACK'].desc, })

        MenuData.Open('default', GetCurrentResourceName(), 'wardrobe_outfits',

        {
            title = Locales['WARDROBE_MENU']['OUTFITS'].label,

            subtext = "",
            align = "left",
            elements = elements,
        },

        function(data, menu)

            if (data.current == "backup") or (data.current.value == 'back') then
                OpenWardrobe()
                return
            end

            OpenSelectedWardrobeOutfitById(data.current.value, data.current.name, data.current.skincomp)

        end,
        function(data, menu)
            OpenWardrobe()
        end)

    end, { type = "outfits" })

end

function OpenSelectedWardrobeOutfitById(outfitId, outfitName, skinComp)
    MenuData.CloseAll()
    
    local elements = {

        { label = Locales['WARDROBE_MENU']['APPLY'].label,        value = "apply",   desc = Locales['WARDROBE_MENU']['APPLY'].desc, },
        { label = Locales['WARDROBE_MENU']['SET_DEFAULT'].label,  value = "default", desc = Locales['WARDROBE_MENU']['SET_DEFAULT'].desc, },
        { label = Locales['WARDROBE_MENU']['RENAME'].label,       value = "rename",  desc = Locales['WARDROBE_MENU']['RENAME'].desc, },
        { label = Locales['WARDROBE_MENU']['DELETE'].label,       value = "delete",  desc = Locales['WARDROBE_MENU']['DELETE'].desc, },

        { label = Locales['WARDROBE_MENU']['BACK'].label,         value = "back",    desc = Locales['WARDROBE_MENU']['BACK'].desc, },
    }
    
    MenuData.Open('default', GetCurrentResourceName(), 'wardrobe_outfits_options',

    {
        title = outfitName,

        subtext = "",
        align = "left",
        elements = elements,
    },

    function(data, menu)

        if (data.current == "backup") or (data.current.value == 'back') then
            OpenWardrobe()
            return
        end

        if data.current.value == 'apply' then

            local ped = PlayerPedId()

            local decodedSkinComp = json.decode(skinComp)

            for _, cloth in pairs (MP.CustomizationElements) do

                if BlacklistedTypes[cloth.tag] == nil then
                    
                    Citizen.InvokeNative(0xD710A5007C2AC539, ped, MP.DefaultHashList[cloth.tag], 0)

                    if decodedSkinComp[cloth.tag] == 0 or decodedSkinComp[cloth.tag] == -1 then
          
                        if cloth.tag == 'gunbelts' then
                            Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x3F1F01E5, 0) 
                            Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0xDA0E2C55, 0) 
                        end
    
                    end
                    
                    if decodedSkinComp[cloth.tag] and tonumber(decodedSkinComp[cloth.tag]) ~= -1 then
    
                        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, tonumber(decodedSkinComp[cloth.tag]), true, true, true)
                    end

                end
        
            end

            if decodedSkinComp["vests"] ~= 0 and decodedSkinComp["vests"] ~= -1 then
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, MP.DefaultHashList["vests"], 0)
                Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, tonumber(decodedSkinComp["vests"]), true, true, true)
            end

            if decodedSkinComp["hats"] ~= 0 and decodedSkinComp["hats"] ~= -1 then
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, MP.DefaultHashList["hats"], 0)
                Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, tonumber(decodedSkinComp["hats"]), true, true, true)
            end
            
            UpdateVariation(ped)
            MenuData.CloseAll()

            TaskStandStill(ped, 1)
            PlayerData.IsBusy = false

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

                    TriggerServerEvent("tpz_clothing:server:renameOutfit", outfitId, cb)
                    SendNotification(nil, Locales['RENAMED_OUTFIT'], "success")

                    Wait(500)
                    OpenWardrobe()
                end

            end) 

        elseif data.current.value == 'default' then

            TriggerServerEvent("tpz_clothing:server:setDefaultOutfit", skinComp)
            SendNotification(nil, Locales['REPLACED_OUTFIT'], "success")

        elseif data.current.value == 'delete' then

            TriggerServerEvent("tpz_clothing:server:deleteOutfit", outfitId)
            SendNotification(nil, Locales['DELETED_OUTFIT'], "success")

            MenuData.CloseAll()
            TaskStandStill(PlayerPedId(), 1)
            PlayerData.IsBusy = false
        end


    end,

    function(data, menu)
        OpenWardrobe()
    end)


end