local MP = exports.tpz_characters.getMPConfiguration() -- Returns tpz_characters MP Configuration file.

local MenuData = {}

TriggerEvent("tpz_menu_base:getData", function(call)
    MenuData = call
end)

local SkinData                    = {}
local LoadedCustomizationElements = false

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local GetAlbedo = function ()
    if IsPedMale(PlayerPedId()) then
        return joaat("mp_head_mr1_sc08_c0_000_ab")
    else 
        return joaat("mp_head_fr1_sc08_c0_000_ab")
    end
end

local CloseMenuProperly = function()
    MenuData.CloseAll()

    DestroyAllCams(true)

    TaskStandStill(PlayerPedId(), 1)

    if Config.HideHUD then ExecuteCommand(Config.HideHUD) end

    local dict = Config.HandsUpAnimation.Dict
    local body = Config.HandsUpAnimation.Body

    if IsEntityPlayingAnim(PlayerPedId(), dict, body, 3) then
        ClearPedTasks(PlayerPedId())
        RemoveAnimDict(dict)
    end

    ClientData.IsBusy = false
    ClientData.HasStoreOpen = false

    SkinData           = nil
    SkinData           = {}

    LoadedCustomizationElements = false
end

-- We load makeup customization elements directly from tpz_characters.
function LoadCustomizationElements()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_clothing:getPlayerDefaultOutfit", function(data)

        local skin = json.decode(data)

        for key, value in pairs(MP.Overlays) do
    
            if MP.MakeupOverlayTypes[key] then
                
                local overlay = MP.MakeupOverlayTypes[key]
    
                SkinData[overlay.txt_id] = -1
                SkinData[overlay.color] = 0

                if skin[overlay.txt_id] then
                    SkinData[overlay.txt_id] = skin[overlay.txt_id]
                end

                if skin[overlay.color] then
                    SkinData[overlay.color] = skin[overlay.color]
                end
    
                if overlay.color2 and overlay.color3 then
                    SkinData[overlay.color2] = 0
                    SkinData[overlay.color3] = 0

                    if skin[overlay.color2] then
                        SkinData[overlay.color2] = skin[overlay.color2]
                    end

                    if skin[overlay.color3] then
                        SkinData[overlay.color3] = skin[overlay.color3]
                    end

                end
    
                if overlay.variant then
                    SkinData[overlay.variant] = 0

                    if skin[overlay.variant] then
                        SkinData[overlay.variant] = skin[overlay.variant]
                    end

                end
    
                SkinData[overlay.opacity] = 0
                SkinData[overlay.visibility] = 0

                if skin[overlay.opacity] then
                    SkinData[overlay.opacity] = skin[overlay.opacity]
                end

                if skin[overlay.visibility] then
                    SkinData[overlay.visibility] = skin[overlay.visibility]
                end

            end
    
        end

        LoadedCustomizationElements = true

    end)

end

-----------------------------------------------------------
--[[ Menu Functions & Store Actions ]]--
-----------------------------------------------------------

function OpenCharacterMakeupCustomization()
    MenuData.CloseAll()

    ClientData.IsBusy = true
    ClientData.HasStoreOpen = true

    local _player = PlayerPedId()
    TaskStandStill(_player, -1)

    if not LoadedCustomizationElements then
        LoadCustomizationElements()
    end

    while not LoadedCustomizationElements do
        Wait(250)
    end

    local elements = {

        { label = Locales['MAIN_MENU']['MAKEUP'].label,      value = "makeup",   desc = Locales['MAIN_MENU']['MAKEUP'].desc, },
        { label = Locales['MAIN_MENU']['SAVE_MAKEUP'].label, value = "save",     desc = Locales['MAIN_MENU']['SAVE_MAKEUP'].desc, },
        { label = Locales['MAIN_MENU']['EXIT'].label,        value = "exit",     desc = Locales['MAIN_MENU']['EXIT'].desc, },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'main_makeup',

    {
        title = Locales['MAKEUP_TITLE'],

        subtext = Locales['CUSTOMIZE_MAKEUP_DESCRIPTION'],
        align = "left",
        elements = elements,
        lastmenu = "notMenu"
    },

    function(data, menu)

        if (data.current == "backup") then
            --CloseMenuProperly() -- DOES NOT SAVE
            return
        end

        if data.current.value == "makeup" then
            OpenMakeupCustomizationList()

        elseif data.current.value == "save" then

            local inputData = {
                title        = Locales['SAVE_MAKEUP_TITLE'],
                desc         = Locales['SAVE_MAKEUP_DESCRIPTION'],
                buttonparam1 = Locales['ACCEPT_BUTTON'],
                buttonparam2 = Locales['DECLINE_BUTTON']
            }
                                        
            TriggerEvent("tpz_inputs:getTextInput", inputData, function(cb)

                if cb ~= "DECLINE" or cb ~= Locales['DECLINE_BUTTON'] then

                    TriggerServerEvent("tpz_clothing:save", "makeup", cb, SkinData)

                    SendNotification(nil, Locales['SAVED_MAKEUP'], "success")

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

function OpenMakeupCustomizationList()
    MenuData.CloseAll()

    local _player = PlayerPedId()
    local albedo  = GetAlbedo()

    local elements = {}

    for key, value in pairs(MP.Overlays) do

        if MP.MakeupOverlayTypes[key] then
            
            local overlay = MP.MakeupOverlayTypes[key]

            -- *texture
            table.insert(elements, {
                label = overlay.label .. ' ' .. Locales['MAKEUP']['TEXTURES'],
                value = SkinData[overlay.txt_id],
                min = 0,
                max = #value,
                type = "slider",
                txt_id = overlay.txt_id,
                opac = overlay.opacity,
                color = overlay.color,
                variant = overlay.variant,
                visibility = overlay.visibility,
                desc = Locales['TOTAL_TYPES'] .. " " .. overlay.label .. " : " .. #value,
                name = key,
                tag = "texture"
            })

            --*Color
            local ColorValue = 0
            for x, color in pairs(MP.ColorPalettes[key]) do
                if GetHashKey(color) == SkinData[overlay.color] then
                    ColorValue = x
                end
            end

            table.insert(elements, {
                label = overlay.label .. ' ' .. Locales['MAKEUP']['COLORS'],
                value = ColorValue,
                min = 0,
                max = 10,
                comp = MP.ColorPalettes[key],
                type = "slider",
                txt_id = overlay.txt_id,
                opac = overlay.opacity,
                color = overlay.color,
                visibility = overlay.visibility,
                variant = overlay.variant,
                desc = Locales['TOTAL_TYPES'] .. " " .. overlay.label .. " : " .. 10,
                name = key,
                tag = "color"
            })

            -- if key == "lipsticks" or key == "eyeliners" then
            if key == "lipsticks" then
                local Color2Value = 0
                for x, color in pairs(MP.ColorPalettes[key]) do
                    if GetHashKey(color) == SkinData[overlay.color2] then
                        Color2Value = x
                    end
                end

                --*Color 2
                table.insert(elements, {
                    label = overlay.label .. ' ' .. Locales['MAKEUP']['SECONDARY_COLORS'],
                    value = Color2Value,
                    min = 0,
                    max = 10,
                    type = "slider",
                    comp = MP.ColorPalettes[key],
                    txt_id = overlay.txt_id,
                    opac = overlay.opacity,
                    color = overlay.color,
                    color2 = overlay.color2,
                    color3 = overlay.color3,
                    variant = overlay.variant,
                    visibility = overlay.visibility,
                    desc = Locales['TOTAL_TYPES'] .. " " .. overlay.label .. " : " .. 10,
                    name = key,
                    tag = "color2"
                })
            end

            if key == "lipsticks" or key == "shadows" or key == "eyeliners" then
                --*Variant
                table.insert(elements, {
                    label = overlay.label .. ' ' .. Locales['MAKEUP']['VARIANTS'],
                    value = SkinData[overlay.variant] or 0,
                    min = 0,
                    max = overlay.varvalue,
                    type = "slider",
                    comp = MP.ColorPalettes[key],
                    txt_id = overlay.txt_id,
                    opac = overlay.opacity,
                    color = overlay.color,
                    color2 = overlay.color2,
                    color3 = overlay.color3,
                    variant = overlay.variant,
                    visibility = overlay.visibility,
                    desc = Locales['TOTAL_TYPES'] .. " " .. overlay.label .. " : " .. overlay.varvalue,
                    name = key,
                    tag = "variant"
                })
            end

            --* opacity
            table.insert(elements, {
                label = overlay.label .. ' ' .. Locales['MAKEUP']['OPACITY'],
                value = SkinData[overlay.opacity],
                min = 0,
                max = 0.9,
                hop = 0.1,
                type = "slider",
                txt_id = overlay.txt_id,
                opac = overlay.opacity,
                color = overlay.color,
                variant = overlay.variant,
                visibility = overlay.visibility,
                desc = Locales['TOTAL_TYPES'] .. " " .. overlay.label .. " : 0.9",
                name = key,
                tag = "opacity"
            })
        end
    end

    MenuData.Open('default', GetCurrentResourceName(), 'sub_makeup',

        {
            title = Locales['MAKEUP_TITLE'],

            subtext = Locales['CUSTOMIZE_MAKEUP_DESCRIPTION'],
            align = "left",
            elements = elements,
            lastmenu = "OpenCustomizationMenu"
        },

        function(data, menu)

            if (data.current == "backup") then
                OpenCharacterMakeupCustomization()
                return
            end

            if data.current.tag == "texture" then
                --* texture id
                if data.current.value <= 0 then
                    SkinData[data.current.visibility] = 0
                else
                    SkinData[data.current.visibility] = 1
                end
                SkinData[data.current.txt_id] = data.current.value
                exports.tpz_characters:toggleOverlayChange(data.current.name, SkinData[data.current.visibility],
                    SkinData[data.current.txt_id], 1, 0, 0,
                    1.0, 0, 1, SkinData[data.current.color], SkinData[data.current.color2] or 0,
                    SkinData[data.current.color3] or 0, SkinData[data.current.variant] or 1,
                    SkinData[data.current.opac], albedo)
            end

            if data.current.tag == "color" then
                --* color
                SkinData[data.current.color] = data.current.comp[data.current.value]
                exports.tpz_characters:toggleOverlayChange(data.current.name, SkinData[data.current.visibility],
                    SkinData[data.current.txt_id], 1, 0, 0,
                    1.0, 0, 1, SkinData[data.current.color], SkinData[data.current.color2] or 0,
                    SkinData[data.current.color3] or 0, SkinData[data.current.variant] or 1,
                    SkinData[data.current.opac], albedo)
            end

            if data.current.tag == "color2" then
                --* color secondary
                SkinData[data.current.color2] = data.current.comp[data.current.value]
                exports.tpz_characters:toggleOverlayChange(data.current.name, SkinData[data.current.visibility],
                    SkinData[data.current.txt_id], 1, 0, 0,
                    1.0, 0, 1, SkinData[data.current.color], SkinData[data.current.color2] or 0,
                    SkinData[data.current.color3] or 0, SkinData[data.current.variant] or 1, SkinData
                    [data.current.opac], albedo)
            end

            if data.current.tag == "variant" then
                --* variant
                SkinData[data.current.variant] = data.current.value
                exports.tpz_characters:toggleOverlayChange(data.current.name, SkinData[data.current.visibility],
                    SkinData[data.current.txt_id], 1, 0, 0,
                    1.0, 0, 1, SkinData[data.current.color], SkinData[data.current.color2] or 0,
                    SkinData[data.current.color3] or 0, SkinData[data.current.variant] or 1,
                    SkinData[data.current.opac], albedo)
            end

            if data.current.tag == "opacity" then
                --* opacity
                if data.current.value <= 0 then
                    SkinData[data.current.visibility] = 0
                else
                    SkinData[data.current.visibility] = 1
                end

                SkinData[data.current.opac] = data.current.value
                exports.tpz_characters:toggleOverlayChange(data.current.name, SkinData[data.current.visibility],
                    SkinData[data.current.txt_id], 1, 0, 0,
                    1.0, 0, 1, SkinData[data.current.color], SkinData[data.current.color2] or 0,
                    SkinData[data.current.color3] or 0, SkinData[data.current.variant] or 1,
                    SkinData[data.current.opac], albedo)
            end


        end,
    function(data, menu)
        OpenCharacterMakeupCustomization()
    end)
end

-----------------------------------------------------------
--[[ Menu Functions & Wardrobe Actions ]]--
-----------------------------------------------------------

function OpenMakeupOutfits()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_clothing:getPlayerOutfits", function(makeupOutfits)

        local length = GetTableLength(makeupOutfits)

        if length <= 0 then
            SendNotification(nil, Locales['NO_MAKEUP_OUTFITS_AVAILABLE'], "error")
            return
        end

        MenuData.CloseAll()

        local elements = {}

        for _, outfit in pairs (makeupOutfits) do
            table.insert(elements, { name = outfit.title, skincomp = outfit.comps, label =  _ .. ". " .. outfit.title, value = outfit.id})
        end

        table.insert(elements, { label = Locales['WARDROBE_MENU']['BACK'].label, value = "back",  desc = Locales['WARDROBE_MENU']['BACK'].desc, })

        MenuData.Open('default', GetCurrentResourceName(), 'wardrobe_makeup_outfits',

        {
            title = Locales['WARDROBE_MENU']['MAKEUP'].label,

            subtext = "",
            align = "left",
            elements = elements,
        },

        function(data, menu)

            if (data.current == "backup") or (data.current.value == 'back') then
                OpenWardrobe()
                return
            end

            OpenSelectedWardrobeById(data.current.value, data.current.name, data.current.skincomp)

        end,
        function(data, menu)
            OpenWardrobe()
        end)

    end, { type = "makeup" })
end

function OpenSelectedWardrobeById(makeupId, makeupName, skinComp)
    MenuData.CloseAll()

    local albedo  = GetAlbedo()
    
    local elements = {

        { label = Locales['WARDROBE_MENU']['APPLY_MAKEUP'].label,        value = "apply",   desc = Locales['WARDROBE_MENU']['APPLY'].desc, },
        { label = Locales['WARDROBE_MENU']['SET_DEFAULT_MAKEUP'].label,  value = "default", desc = Locales['WARDROBE_MENU']['SET_DEFAULT'].desc, },
        { label = Locales['WARDROBE_MENU']['RENAME_MAKEUP'].label,       value = "rename",  desc = Locales['WARDROBE_MENU']['RENAME'].desc, },
        { label = Locales['WARDROBE_MENU']['DELETE_MAKEUP'].label,       value = "delete",  desc = Locales['WARDROBE_MENU']['DELETE'].desc, },

        { label = Locales['WARDROBE_MENU']['BACK'].label,         value = "back",    desc = Locales['WARDROBE_MENU']['BACK'].desc, },
    }
    
    MenuData.Open('default', GetCurrentResourceName(), 'wardrobe_makeup_options',

    {
        title = makeupName,

        subtext = "",
        align = "left",
        elements = elements,
    },

    function(data, menu)

        if (data.current == "backup") or (data.current.value == 'back') then
            OpenMakeupOutfits()
            return
        end

        if data.current.value == 'apply' then

            local ped = PlayerPedId()

            local decodedSkinComp = json.decode(skinComp)
            
            for tag, overlayData in pairs(MP.Overlays) do

                -- Load makeup
                if MP.MakeupOverlayTypes[tag] then
                    
                    local overlay = MP.MakeupOverlayTypes[tag]
        
                    exports.tpz_characters:toggleOverlayChange(tag, decodedSkinComp[overlay.visibility],
                    decodedSkinComp[overlay.txt_id], 1, 0, 0,
        
                    1.0, 0, 1, decodedSkinComp[overlay.color] or 0, decodedSkinComp[overlay.color2] or 0,
        
                    decodedSkinComp[overlay.color3] or 0, decodedSkinComp[overlay.variant] or 1,
                    decodedSkinComp[overlay.opacity], albedo)
        
                end
        
            end

            MenuData.CloseAll()
            ClientData.IsBusy = false
            TaskStandStill(ped, 1)

        elseif data.current.value == 'rename' then

            local inputData = {
                title        = Locales['RENAME_MAKEUP_TITLE'],
                desc         = Locales['RENAME_MAKEUP_DESCRIPTION'],
                buttonparam1 = Locales['ACCEPT_BUTTON'],
                buttonparam2 = Locales['DECLINE_BUTTON']
            }
                                        
            TriggerEvent("tpz_inputs:getTextInput", inputData, function(cb)

                if cb ~= "DECLINE" or cb ~= Locales['DECLINE_BUTTON'] then
                    MenuData.CloseAll()

                    TriggerServerEvent("tpz_clothing:rename", "makeup", makeupId, cb)

                    SendNotification(nil, Locales['RENAMED_MAKEUP'], "success")

                    Wait(500)
                    OpenMakeupOutfits()
                end

            end) 

        elseif data.current.value == 'default' then

            TriggerServerEvent("tpz_clothing:replace", skinComp)

            SendNotification(nil, Locales['REPLACED_MAKEUP'], "success")

        elseif data.current.value == 'delete' then

            TriggerServerEvent("tpz_clothing:delete", "makeup", makeupId)

            SendNotification(nil, Locales['DELETED_MAKEUP'], "success")

            MenuData.CloseAll()
            ClientData.IsBusy = false
            TaskStandStill(PlayerPedId(), 1)
        end


    end,

    function(data, menu)
        OpenMakeupOutfits()
    end)


end