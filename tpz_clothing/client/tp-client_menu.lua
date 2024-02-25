local MP = exports.tpz_characters.getMPConfiguration() -- Returns tpz_characters MP Configuration file.

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

local LoadSelectedListResults = function(_type, sex) 
    local maxIndex = 0

    _type = string.lower(_type)

    local ClothHashNames = exports.tpz_characters.getClothHashNamesList()

    for index, type in pairs (ClothHashNames) do

        if string.lower(type.category_hashname) == _type and type.is_multiplayer and type.ped_type == sex then

            if not MP.BlackListedHashDecSigns[type.hash_dec_signed] then

                maxIndex                                            = maxIndex + 1
                ClothingList[_type .. "-".. maxIndex]               = {}
                ClothingList[_type .. "-".. maxIndex].hashName      = type.hashname
                ClothingList[_type .. "-".. maxIndex].hash          = type.hash
                ClothingList[_type .. "-".. maxIndex].hashToString  = tostring(type.hash)
                ClothingList[_type .. "-".. maxIndex].hashDecSigned = tonumber(type.hash_dec_signed)
                ClothingList[_type .. "-".. maxIndex].index         = maxIndex

            end

        end

    end

    ClothingList[_type]         = {}
    ClothingList[_type].current = -1
    ClothingList[_type].max     = maxIndex
    ClothingList[_type].tag     = _type

end

local LoadSkinData = function(_type)

    _type = string.lower(_type)

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_clothing:getPlayerDefaultOutfit", function(data)

        local skin = json.decode(data)

        if skin[_type] then
            SkinData[_type] = skin[_type]

            ClothingList[_type].current = SkinData[_type]
        end

    end)

end

local CloseMenuProperly = function()
    local player = PlayerPedId()

    DestroyAllCams(true)

    MenuData.CloseAll()

    ClientData.IsBusy = false
    TaskStandStill(player, 1)

    if Config.HideHUD then ExecuteCommand(Config.HideHUD) end

    ClientData.HasStoreOpen = false

    local dict = Config.HandsUpAnimation.Dict
    local body = Config.HandsUpAnimation.Body

    if IsEntityPlayingAnim(player, dict, body, 3) then
        ClearPedTasks(player)
        RemoveAnimDict(dict)
    end

    SkinData           = nil
    SkinData           = {}

    LoadedSkinData     = false
end

-- We load customization elements (ONLY Clothing) directly from tpz_characters.
function LoadCustomizationElements()
    local sex = GetGender()

    for __, customization in pairs (MP.CustomizationElements) do

        if customization.action == 'clothing' then
            LoadSelectedListResults(customization.tag, sex)
        end

    end

    ClientData.Loaded = true

end

-----------------------------------------------------------
--[[ Menu Functions & Store Actions ]]--
-----------------------------------------------------------

function OpenCharacterCustomization()

    ClientData.IsBusy = true
    ClientData.HasStoreOpen = true

    local _player = PlayerPedId()
    TaskStandStill(_player, -1)

    if not LoadedSkinData then

        LoadedSkinData = true

        for __, customization in pairs (MP.CustomizationElements) do

            if customization.action == 'clothing' then
                LoadSkinData(customization.tag)
            end
    
        end

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
            --CloseMenuProperly() -- DOES NOT SAVE
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
        --CloseMenuProperly() -- DOES NOT SAVE
    end)

end

function OpenCharacterOutfitCustomization(actionType)
    MenuData.CloseAll()

    local _player = PlayerPedId()
    local sex     = GetGender()

    local elements = {}

    for _, element in pairs (MP.CustomizationElements) do

        if element.action == 'clothing' then

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
                        UpdateVariation(_player)
                        
                        ClothingList[tag].current = -1
                        SkinData[tag] = -1

                    elseif data.current.value > 0 then

                        local clothingData = ClothingList[tag .. "-" .. data.current.value]
                        local hash = clothingData.hash

                        Citizen.InvokeNative(0xD3A7B003ED343FD9, _player, hash, true, true, true)
                        UpdateVariation(_player)

                        if Config.Debug then
                            print("changed " .. tag .. ", to the following Hash Dec Signed: " .. clothingData.hashDecSigned )
                        end
        
                        ClothingList[tag].current = clothingData.index
                        SkinData[tag] = clothingData.index

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

    ClientData.IsBusy = true

    TaskStandStill(player, -1)

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
                ClientData.IsBusy = false
                TaskStandStill(player, 1)
                return
            end

            OpenSelectedWardrobeById(data.current.value, data.current.name, data.current.skincomp)


        end,
        function(data, menu)
            MenuData.CloseAll()
            ClientData.IsBusy = false
            TaskStandStill(player, 1)
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
            
            for index, cloth in pairs (ClothingList) do

                if decodedSkinComp[cloth.tag] and tonumber(decodedSkinComp[cloth.tag]) ~= -1 then

                    local clothingData = ClothingList[cloth.tag .. "-" .. decodedSkinComp[cloth.tag]]
                    local hash         = clothingData.hash
    
                    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, hash, true, true, true)
                    UpdateVariation(ped)
   
                end

                if tonumber(decodedSkinComp[cloth.tag]) == 0 or tonumber(decodedSkinComp[cloth.tag]) == -1 then
                    Citizen.InvokeNative(0xD710A5007C2AC539, ped, MP.DefaultHashList[cloth.tag], 0)
                    UpdateVariation(ped)
                end

                if cloth.tag == "gunbelts" and (tonumber(decodedSkinComp[cloth.tag]) == 0 or tonumber(decodedSkinComp[cloth.tag]) == -1) then
                    Citizen.InvokeNative(0xD710A5007C2AC539, ped, MP.DefaultHashList["gunbelts"], 1)
                    UpdateVariation(ped)
                end
        
            end

            MenuData.CloseAll()
            ClientData.IsBusy = false
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
            ClientData.IsBusy = false
            TaskStandStill(PlayerPedId(), 1)
        end


    end,

    function(data, menu)
        OpenWardrobe()
    end)


end