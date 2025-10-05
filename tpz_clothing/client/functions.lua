
local WardrobePrompts, StoreLocationPrompts, StorePrompts = GetRandomIntInRange(0, 0xffffff), GetRandomIntInRange(0, 0xffffff), GetRandomIntInRange(0, 0xffffff)
local WardrobePromptsList, StoreLocationPromptsList, StorePromptsList = {}, {}, {}

--[[-------------------------------------------------------
 Handlers
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    Citizen.InvokeNative(0x00EDE88D4D13CF59, WardrobePrompts) -- UiPromptDelete
    Citizen.InvokeNative(0x00EDE88D4D13CF59, StoreLocationPrompts) -- UiPromptDelete
    Citizen.InvokeNative(0x00EDE88D4D13CF59, StorePrompts) -- UiPromptDelete

    local PlayerData = GetPlayerData()

    if PlayerData.IsBusy then
        DestroyAllCams(true)
    end

    for i, v in pairs(Config.Stores) do
        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end
    end

    for i, v in pairs(Config.Wardrobes) do
        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end
    end

end)

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

RegisterWardrobePrompts = function()

    local str = Config.Prompts["OPEN_WARDROBE"].label
    local keyPress = Config.Keys[Config.Prompts["OPEN_WARDROBE"].key]
    
    local _prompt = PromptRegisterBegin()
    PromptSetControlAction(_prompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(_prompt, str)
    PromptSetEnabled(_prompt, 1)
    PromptSetVisible(_prompt, 1)
    PromptSetStandardMode(_prompt, 1)
    PromptSetHoldMode(_prompt, 500)
    PromptSetGroup(_prompt, WardrobePrompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, _prompt, true)
    PromptRegisterEnd(_prompt)
    
    WardrobePromptsList = _prompt

end

function GetWardrobePromptData()
    return WardrobePrompts, WardrobePromptsList
end

RegisterStoreLocationPrompts = function()

    local str = Config.Prompts["OPEN_STORE"].label
    local keyPress = Config.Keys[Config.Prompts["OPEN_STORE"].key]
    
    local _prompt = PromptRegisterBegin()
    PromptSetControlAction(_prompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(_prompt, str)
    PromptSetEnabled(_prompt, 1)
    PromptSetVisible(_prompt, 1)
    PromptSetStandardMode(_prompt, 1)
    PromptSetHoldMode(_prompt, 500)
    PromptSetGroup(_prompt, StoreLocationPrompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, _prompt, true)
    PromptRegisterEnd(_prompt)
    
    StoreLocationPromptsList = _prompt

end

function GetStoreLocationPromptData()
    return StoreLocationPrompts, StoreLocationPromptsList
end

CreateStorePrompts = function()

    for index, tprompt in pairs (Config.CameraAdjustmentPrompts) do

        local str = tprompt.label
        local keyPress  = Config.Keys[tprompt.key1]
        local keyPress2 = Config.Keys[tprompt.key2]

        local dPrompt = PromptRegisterBegin()
        PromptSetControlAction(dPrompt, keyPress)

        if keyPress2 then
            PromptSetControlAction(dPrompt, keyPress2)
        end
        
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(dPrompt, str)
        PromptSetEnabled(dPrompt, 1)
        PromptSetVisible(dPrompt, 1)
        PromptSetStandardMode(dPrompt, 0)
        PromptSetHoldMode(dPrompt, false)
        PromptSetGroup(dPrompt, StorePrompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
        PromptRegisterEnd(dPrompt)
    
        table.insert(StorePromptsList, {prompt = dPrompt, type = index})
    end

end

function GetStorePromptData()
    return StorePrompts, StorePromptsList
end

--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

Citizen.CreateThread(function ()

    for index, blip in pairs (Config.Wardrobes) do

        if blip.BlipData and blip.BlipData.Enabled then

            local blipHandle = N_0x554d9d53f696d002(1664425300, blip.Coords.x, blip.Coords.y, blip.Coords.z)
    
            SetBlipSprite(blipHandle, blip.BlipData.Sprite, 1)
            SetBlipScale(blipHandle, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, blipHandle, blip.BlipData.Title)

                    
            Config.Wardrobes[index].BlipHandle = blipHandle

        end

    end

end)

function AddBlip(Store, StatusType)

    if Config.Stores[Store].BlipData then

        local BlipData = Config.Stores[Store].BlipData

        local sprite, blipModifier = BlipData.Sprite, 'BLIP_MODIFIER_MP_COLOR_32'

        if BlipData.OpenBlipModifier then
            blipModifier = BlipData.OpenBlipModifier
        end

        if StatusType == 'CLOSED' then
            sprite = BlipData.DisplayClosedHours.Sprite
            blipModifier = BlipData.DisplayClosedHours.BlipModifier
        end
        
        Config.Stores[Store].BlipHandle = N_0x554d9d53f696d002(1664425300, Config.Stores[Store].Coords.x, Config.Stores[Store].Coords.y, Config.Stores[Store].Coords.z)

        SetBlipSprite(Config.Stores[Store].BlipHandle, sprite, 1)
        SetBlipScale(Config.Stores[Store].BlipHandle, 0.2)

        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.Stores[Store].BlipHandle, GetHashKey(blipModifier))

        Config.Stores[Store].BlipHandleModifier = blipModifier

        Citizen.InvokeNative(0x9CB1A1623062F402, Config.Stores[Store].BlipHandle, BlipData.Name)

    end
end

--[[-------------------------------------------------------
 NPC Management
]]---------------------------------------------------------

LoadModel = function(model)
    local model = GetHashKey(model)
    RequestModel(model)

    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(100)
    end
end


--[[-------------------------------------------------------
 General
]]---------------------------------------------------------

StartCam = function(x, y, z, rotx, roty, rotz, fov)

	Citizen.InvokeNative(0x17E0198B3882C2CB, PlayerPedId())
	DestroyAllCams(true)

    local cameraHandler = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, rotx, roty, rotz, fov, true, 0)
    
	SetCamActive(cameraHandler, true)

	RenderScriptCams(true, true, 500, true, true)

end

AdjustEntityPedHeading = function(amount)
	CurrentHeading = CurrentHeading + amount
	SetPedDesiredHeading(PlayerPedId(), CurrentHeading)
end
