
Prompts       = GetRandomIntInRange(0, 0xffffff)
PromptsList   = {}


StorePrompts       = GetRandomIntInRange(0, 0xffffff)
StorePromptsList   = {}

--[[-------------------------------------------------------
 Handlers
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
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

    Citizen.InvokeNative(0x00EDE88D4D13CF59, Prompts) -- UiPromptDelete
    Citizen.InvokeNative(0x00EDE88D4D13CF59, StorePrompts) -- UiPromptDelete

    DestroyAllCams(true)
end)

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

RegisterPrompts = function()

    for index, tprompt in pairs (Config.Prompts) do

        local str = tprompt.label
        local keyPress = Config.Keys[tprompt.key]
    
        local _prompt = PromptRegisterBegin()
        PromptSetControlAction(_prompt, keyPress)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(_prompt, str)
        PromptSetEnabled(_prompt, 0)
        PromptSetVisible(_prompt, 1)
        PromptSetStandardMode(_prompt, 1)
        PromptSetHoldMode(_prompt, 500)
        PromptSetGroup(_prompt, Prompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, _prompt, true)
        PromptRegisterEnd(_prompt)
    
        table.insert(PromptsList, {prompt = _prompt, type = index })
    end

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



--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

Citizen.CreateThread(function ()
    for index, blip in pairs (Config.Stores) do

        if blip.BlipData and blip.BlipData.Enabled then

            local blipHandle = N_0x554d9d53f696d002(1664425300, blip.Coords.x, blip.Coords.y, blip.Coords.z)
    
            SetBlipSprite(blipHandle, blip.BlipData.Sprite, 1)
            SetBlipScale(blipHandle, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, blipHandle, blip.BlipData.Title)

                    
            Config.Stores[index].BlipHandle = blipHandle

        end

    end

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

IsPedReadyToRender = function()
    Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId())
    while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId()) do
        Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId())
        Wait(0)
    end
end

UpdateVariation = function(ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    IsPedReadyToRender()
end

ApplyComponentToPed = function(ped, comp)

    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, comp, false, true, true)
    Citizen.InvokeNative(0x66b957aac2eaaeab, ped, comp, 0, 0, 1, 1) -- _UPDATE_SHOP_ITEM_WEARABLE_STATE
    Citizen.InvokeNative(0xAAB86462966168CE, ped, 1)
    UpdateVariation(ped)
end


StartCam = function(x, y, z, rotx, roty, rotz, fov)

	Citizen.InvokeNative(0x17E0198B3882C2CB, PlayerPedId())
	DestroyAllCams(true)

    local cameraHandler = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, rotx, roty, rotz, fov, true, 0)
    
	SetCamActive(cameraHandler, true)

	RenderScriptCams(true, true, 500, true, true)

end

-- @GetTableLength returns the length of a table.
GetTableLength = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

