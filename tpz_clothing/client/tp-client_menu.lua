local MP             = exports.tpz_characters.getMPConfiguration() -- Returns tpz_characters MP Configuration file.
local ClothHashNames = exports.tpz_characters.getClothHashNamesList()

local MenuData = {}

TriggerEvent("tpz_menu_base:getData", function(call)
    MenuData = call
end)


local ClothingList       = {}
local SkinData           = {}

local LoadedSkinData = false

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local GetGender = function ()
    if IsPedMale(PlayerPedId()) then return "male" else return "female" end
end

local LoadSelectedListResults = function(sex)

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_clothing:getPlayerDefaultOutfit", function(data)

        local skin = json.decode(data)
        SkinData   = skin

        for index, type in pairs (ClothHashNames) do

            if type.is_multiplayer and type.ped_type == sex and type.category_hashname ~= nil and type.category_hashname ~= "" then
    
                if not MP.BlackListedHashDecSigns[type.hash_dec_signed] then

                    local _type = string.lower(type.category_hashname)

                    if ClothingList[_type] == nil then
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
                    end

                    ClothingList[tonumber(type.hash_dec_signed)] = type.hash
                        
                end
    
            end
    
        end
        
    end)

end

local CloseMenuProperly = function()
    MenuData.CloseAll()

    DestroyAllCams(true)

    TaskStandStill(PlayerPedId(), 1)

    if Config.HideHUD then ExecuteCommand(Config.HideHUD) end

    ClientData.HasStoreOpen = false

    local dict = Config.HandsUpAnimation.Dict
    local body = Config.HandsUpAnimation.Body

    if IsEntityPlayingAnim(PlayerPedId(), dict, body, 3) then
        ClearPedTasks(PlayerPedId())
        RemoveAnimDict(dict)
    end

    SkinData           = nil
    SkinData           = {}

    LoadedSkinData     = false

    ClientData.IsBusy = false
end

-----------------------------------------------------------
--[[ Menu Functions & Store Actions ]]--
-----------------------------------------------------------

function OpenCharacterCustomization()
    ClientData.IsBusy       = true
    ClientData.HasStoreOpen = true

    local _player = PlayerPedId()
    TaskStandStill(_player, -1)

    if not LoadedSkinData then

        LoadedSkinData = true
        LoadSelectedListResults(GetGender())
    end

    Wait(250)

    local elements = {

        { label = Locales['MAIN_MENU']['CLOTHING'].label,  value = "clothing", desc = Locales['MAIN_MENU']['CLOTHING'].desc, },
        { label = Locales['MAIN_MENU']['SAVE'].label,      value = "save",     desc = Locales['MAIN_MENU']['SAVE'].desc, },
        { label = Locales['MAIN_MENU']['EXIT'].label,      value = "exit",     desc = Locales['MAIN_MENU']['EXIT'].desc, },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'main',

    {
        title = Locales['CUSTOMIZE_TITLE'],

        subtext = Locales['CUSTOMIZE_DESCRIPTION'],
        align = "left",
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
                    TriggerServerEvent("tpz_clothing:save", cb, SkinData)

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
            title = Locales['CUSTOMIZE_TITLE'],

            subtext = Locales['CUSTOMIZE_DESCRIPTION'],
            align = "left",
            elements = elements,
            lastmenu = "OpenCharacterCustomization"
        },

        function(data, menu)

            if (data.current == "backup") then
                OpenCharacterCustomization()
                menu.close()
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
        menu.close()
    end)
end

-----------------------------------------------------------
--[[ Menu Functions & Wardrobe Actions ]]--
-----------------------------------------------------------

function OpenWardrobe()
    MenuData.CloseAll()

    local player = PlayerPedId()

    TaskStandStill(player, -1)
    ClientData.IsBusy = true

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_clothing:getPlayerOutfits", function(outfits)

        local elements = {}

        for _, outfit in pairs (outfits) do
            table.insert(elements, { name = outfit.title, skincomp = outfit.comps, label =  _ .. ". " .. outfit.title, value = outfit.id})
        end

        table.insert(elements, { label = Locales['WARDROBE_MENU']['EXIT'].label, value = "exit",  desc = Locales['WARDROBE_MENU']['EXIT'].desc, })

        MenuData.Open('default', GetCurrentResourceName(), 'wardrobe_main',

        {
            title = Locales['WARDROBE_TITLE'],

            subtext = "",
            align = "left",
            elements = elements,
        },

        function(data, menu)

            if (data.current == "backup") or (data.current.value == 'exit') then
                MenuData.CloseAll()

                TaskStandStill(player, 1)
                ClientData.IsBusy = false
                return
            end

            OpenSelectedWardrobeById(data.current.value, data.current.name, data.current.skincomp)


        end,
        function(data, menu)
            MenuData.CloseAll()

            TaskStandStill(player, 1)
            ClientData.IsBusy = false
        end)

    end)

end

function OpenSelectedWardrobeById(outfitId, outfitName, skinComp)
    MenuData.CloseAll()
    
    local elements = {

        { label = Locales['WARDROBE_MENU']['APPLY'].label,        value = "apply",   desc = Locales['WARDROBE_MENU']['APPLY'].desc, },
        { label = Locales['WARDROBE_MENU']['SET_DEFAULT'].label,  value = "default", desc = Locales['WARDROBE_MENU']['SET_DEFAULT'].desc, },
        { label = Locales['WARDROBE_MENU']['RENAME'].label,       value = "rename",  desc = Locales['WARDROBE_MENU']['RENAME'].desc, },
        { label = Locales['WARDROBE_MENU']['DELETE'].label,       value = "delete",  desc = Locales['WARDROBE_MENU']['DELETE'].desc, },

        { label = Locales['WARDROBE_MENU']['BACK'].label,         value = "back",    desc = Locales['WARDROBE_MENU']['BACK'].desc, },
    }
    
    MenuData.Open('default', GetCurrentResourceName(), 'wardrobe_options',

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

                if decodedSkinComp[cloth.tag] and tonumber(decodedSkinComp[cloth.tag]) ~= -1 then

                    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, tonumber(decodedSkinComp[cloth.tag]), true, true, true)
                end
        
                if decodedSkinComp[cloth.tag] == 0 or decodedSkinComp[cloth.tag] == -1 then
                    Citizen.InvokeNative(0xD710A5007C2AC539, ped, MP.DefaultHashList[cloth.tag], 0)
        
                    if cloth.tag == 'gunbelts' then
                        Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x3F1F01E5, 0) 
                        Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0xDA0E2C55, 0) 
                    end

                end

            end

            -- We manually load pants, vests and hats because they don't load properly when looped and loaded
            -- before some other clothing types.
            if decodedSkinComp["pants"] ~= 0 and decodedSkinComp["pants"] ~= -1 then
                Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, tonumber(decodedSkinComp["pants"]), true, true, true)
            end

            if decodedSkinComp["vests"] ~= 0 and decodedSkinComp["vests"] ~= -1 then
                Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, tonumber(decodedSkinComp["vests"]), true, true, true)
            end

            if decodedSkinComp["hats"] ~= 0 and decodedSkinComp["hats"] ~= -1 then
                Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, tonumber(decodedSkinComp["hats"]), true, true, true)
            end
            
            UpdateVariation(ped)

            MenuData.CloseAll()

            TaskStandStill(ped, 1)

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

                    TriggerServerEvent("tpz_clothing:rename", outfitId, cb)

                    SendNotification(nil, Locales['RENAMED_OUTFIT'], "success")

                    Wait(500)
                    OpenWardrobe()
                end

            end) 

        elseif data.current.value == 'default' then

            TriggerServerEvent("tpz_clothing:replace", skinComp)

            SendNotification(nil, Locales['REPLACED_OUTFIT'], "success")

        elseif data.current.value == 'delete' then

            TriggerServerEvent("tpz_clothing:delete", outfitId)

            SendNotification(nil, Locales['DELETED_OUTFIT'], "success")

            MenuData.CloseAll()

            TaskStandStill(PlayerPedId(), 1)
        end


    end,

    function(data, menu)
        OpenWardrobe()
    end)


end
