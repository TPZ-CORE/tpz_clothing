local PlayerData = { 
	HasMenuActive = false, 
	HasNUIActive  = false,
    LocationIndex = nil,
	Clothing      = {},
	Loaded        = false
}

---------------------------------------------------------------
--[[ Local Functions ]]--
---------------------------------------------------------------

local function IsStoreOpen(storeConfig)

    if not storeConfig.Hours.Allowed then
        return true
    end

    local hour = GetClockHours()
    
    if storeConfig.Hours.Opening < storeConfig.Hours.Closing then
        -- Normal hours: Opening and closing on the same day (e.g., 08 to 20)
        if hour < storeConfig.Hours.Opening or hour >= storeConfig.Hours.Closing then
            return false
        end
    else
        -- Overnight hours: Closing time is on the next day (e.g., 21 to 05)
        if hour < storeConfig.Hours.Opening and hour >= storeConfig.Hours.Closing then
            return false
        end
    end

    return true

end


-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function GetPlayerData()
	return PlayerData
end

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler("tpz_core:isPlayerReady", function()
    Wait(2000)
    TriggerServerEvent("tpz_clothing:server:request")
end)


if Config.DevMode then

    Citizen.CreateThread(function ()
        
        Wait(2000)
        TriggerServerEvent("tpz_clothing:server:request")
    end)

end

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------
 
RegisterNetEvent("tpz_clothing:client:update")
AddEventHandler("tpz_clothing:client:update", function(cb)
	local actionType, data = cb.actionType, cb.data

	if actionType == "REQUEST" then
		PlayerData.Clothing = data
		PlayerData.Loaded   = true

        if Config.Debug then
            print('loaded clothing store data')
        end
        
    elseif actionType == 'INSERT_OUTFIT' then

        table.insert(PlayerData.Clothing.outfits, data )

    elseif actionType == 'INSERT_PURCHASED_ITEM' then

        if PlayerData.Clothing.purchased[data[1]] == nil then 
            PlayerData.Clothing.purchased[data[1]] = {}
        end

        table.insert(PlayerData.Clothing.purchased[data[1]], { id = data[2], palette = data[3] } )
        SendNUIMessage( { action = 'setOutfitComponentAsPurchased', bought_locale = Locales['NUI_SELECT_BOUGHT'] } )
    end

end)

RegisterNetEvent(Config.OpenWardrobeOutfitsEvent)
AddEventHandler(Config.OpenWardrobeOutfitsEvent, function()
    OpenWardrobe()
end)

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
    
    RegisterStoreLocationPrompts()
    
	while true do

        local sleep        = 1250
        local player       = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)
        local coords       = GetEntityCoords(player)

        if not PlayerData.Loaded or isPlayerDead or PlayerData.IsBusy or PlayerData.HasNUIActive then
            goto END
        end

        for storeId, locationConfig in pairs(Config.Stores) do

            local isAllowed = IsStoreOpen(locationConfig)

            if locationConfig.BlipData.Enabled then
    
                local ClosedHoursData = locationConfig.BlipData.DisplayClosedHours

                if isAllowed ~= locationConfig.IsAllowed and locationConfig.BlipHandle then

                    RemoveBlip(locationConfig.BlipHandle)
                    
                    Config.Stores[storeId].BlipHandle = nil
                    Config.Stores[storeId].IsAllowed = isAllowed

                end

                if (isAllowed and locationConfig.BlipHandle == nil) or (not isAllowed and ClosedHoursData and ClosedHoursData.Enabled and locationConfig.BlipHandle == nil ) then
                    local blipModifier = isAllowed and 'OPEN' or 'CLOSED'
                    AddBlip(storeId, blipModifier)

                    Config.Stores[storeId].IsAllowed = isAllowed
                end

            end

                local distance = #(coords - vector3(locationConfig.Coords.x, locationConfig.Coords.y, locationConfig.Coords.z))

                if locationConfig.ActionMarkers.Enabled and distance <= locationConfig.ActionMarkers.Distance then
                    sleep = 0
    
                    local RGBA = locationConfig.ActionMarkers.RGBA
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, locationConfig.Coords.x, locationConfig.Coords.y, locationConfig.Coords.z - 1.2, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 0.7, RGBA.r, RGBA.g, RGBA.b, RGBA.a, false, true, 2, false, false, false, false)
                end
    
                if distance <= locationConfig.ActionDistance then
                    sleep = 0
    
                    local Prompts, PromptList = GetStoreLocationPromptData()
    
                    local label = CreateVarString(10, 'LITERAL_STRING', Locales['CLOTHING_TITLE'])
                    PromptSetActiveGroupThisFrame(Prompts, label)
    
                    if PromptHasHoldModeCompleted(PromptList) then
    
                        PlayerData.LocationIndex = storeId

                        OpenCharacterCustomization(storeId)
                        Wait(1000)
                    end
    
                end


        end

        ::END::
		Wait(sleep)

	end
end)

Citizen.CreateThread(function()

	RegisterWardrobePrompts()

    while true do

        local sleep        = 1250
        local player       = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)
        local coords       = GetEntityCoords(player)

        if not PlayerData.Loaded or isPlayerDead or PlayerData.IsBusy then
            goto END
        end

        for locId, locationConfig in pairs(Config.Wardrobes) do

            local distance = #(coords - vector3(locationConfig.Coords.x, locationConfig.Coords.y, locationConfig.Coords.z))

            if locationConfig.ActionMarkers.Enabled and distance <= locationConfig.ActionMarkers.Distance then
                sleep = 0

                local RGBA = locationConfig.ActionMarkers.RGBA
                Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, locationConfig.ActionMarkers.Coords.x, locationConfig.ActionMarkers.Coords.y, locationConfig.ActionMarkers.Coords.z - 1.2, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 0.7, RGBA.r, RGBA.g, RGBA.b, RGBA.a, false, true, 2, false, false, false, false)
            end

            if distance <= locationConfig.ActionDistance then
                sleep = 0

                local Prompts, PromptsList = GetWardrobePromptData()

                local label = CreateVarString(10, 'LITERAL_STRING', Locales['WARDROBE_TITLE'])
                PromptSetActiveGroupThisFrame(Prompts, label)

                if PromptHasHoldModeCompleted(PromptsList) then
                 
                    OpenWardrobe()
                    Wait(1000)
                end

            end

        end

        ::END::
        Wait(sleep)

    end
    
end)

-- PUSH TO TALK.
CreateThread(function()
    repeat Wait(5000) until PlayerData.Loaded 
    local IS_NUI_FOCUSED = false

    while true do
        local sleep = 0

        if not PlayerData.HasNUIActive then

            if IS_NUI_FOCUSED then
                SetNuiFocusKeepInput(false)
                IS_NUI_FOCUSED = false
            end

            sleep = 1000

            goto END
        end

        if PlayerData.HasNUIActive then

            if not IS_NUI_FOCUSED then
                SetNuiFocusKeepInput(true)
                IS_NUI_FOCUSED = true
            end

            DisableAllControlActions(0)
            EnableControlAction(0, `INPUT_PUSH_TO_TALK`, true)
        end

        ::END::
        Wait(sleep)
    end
end)
