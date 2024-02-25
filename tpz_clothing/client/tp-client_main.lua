ClientData = { IsBusy = false, HasStoreOpen = false, Loaded = false}

local CameraHandler           = {coords = nil, zoom = 0, z = 0 }
local CurrentHeading          = 0

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local function AdjustEntityPedHeading(amount)
	CurrentHeading = CurrentHeading + amount
	SetPedDesiredHeading(PlayerPedId(), CurrentHeading)
end

-----------------------------------------------------------
--[[ Exports ]]--
-----------------------------------------------------------

exports('openWardrobe', function()
	TriggerEvent("tpz_clothing:openWardrobe")
end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

-- Loaded the LoadCustomizationElements function on character select.
AddEventHandler("tpz_core:isPlayerReady", function()
    LoadCustomizationElements()
end)

 
RegisterNetEvent("tpz_clothing:openWardrobe")
AddEventHandler("tpz_clothing:openWardrobe", function()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_clothing:getPlayerOutfits", function(data)

        local length = GetTableLength(data)

        if length <= 0 then
            SendNotification(nil, Locales['NO_OUTFITS_AVAILABLE'], "error")
            return
        end

        OpenWardrobe()

    end)

end)

if Config.DevMode then

    Citizen.CreateThread(function ()
 
        Wait(2000)
 
        TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_core:getPlayerData", function(data)
        
            -- We get the player data to check if player has loaded or not before calling LoadCustomizationElements() function.
            if data == nil then
                return
            end

           LoadCustomizationElements()
        end)

    end)

end
-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()

    RegisterPrompts()

    while true do
        Citizen.Wait(0)

        local sleep        = true

        local player       = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)

        if not isPlayerDead and not ClientData.IsBusy and ClientData.Loaded then
            local coords = GetEntityCoords(player)

            for locId, locationConfig in pairs(Config.Stores) do

                local coordsDist = vector3(coords.x, coords.y, coords.z)
                local coordsLoc  = vector3(locationConfig.Coords.x, locationConfig.Coords.y, locationConfig.Coords.z)
                local distance   = #(coordsDist - coordsLoc)

                if locationConfig.ActionMarkers.Enabled and distance <= locationConfig.ActionMarkers.Distance then
                    sleep = false

                    local RGBA = locationConfig.ActionMarkers.RGBA
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, locationConfig.Coords.x, locationConfig.Coords.y, locationConfig.Coords.z - 1.2, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 0.7, RGBA.r, RGBA.g, RGBA.b, RGBA.a, false, true, 2, false, false, false, false)
                end
    
                if distance <= locationConfig.ActionDistance then
                    sleep = false

                    local label = CreateVarString(10, 'LITERAL_STRING', Locales['CUSTOMIZE_TITLE'])
                    PromptSetActiveGroupThisFrame(Prompts, label)

                    for i, prompt in pairs (PromptsList) do

                        PromptSetVisible(prompt.prompt, 0)
                        PromptSetEnabled(prompt.prompt, 0)

                        if prompt.type == 'OPEN_STORE' then
                            PromptSetVisible(prompt.prompt, 1)
                            PromptSetEnabled(prompt.prompt, 1)
                        end

                        if PromptHasHoldModeCompleted(prompt.prompt) then

                            if prompt.type == "OPEN_STORE" then

                                SetEntityHeading(player, locationConfig.Coords.h)

                                CurrentHeading = locationConfig.Coords.h

                                if Config.HideHUD then ExecuteCommand(Config.HideHUD) end

                                local cameraCoords = locationConfig.CameraCoords
                                StartCam(cameraCoords.x, cameraCoords.y, cameraCoords.z, cameraCoords.rotx, cameraCoords.roty,
                                cameraCoords.rotz, cameraCoords.zoom)

                                CameraHandler.coords = {
                                    x = cameraCoords.x, y = cameraCoords.y, z = cameraCoords.z, rotx = cameraCoords.rotx, roty = cameraCoords.roty,
                                    rotz = cameraCoords.rotz, fov = cameraCoords.fov
                                }
                            
                                CameraHandler.z    = cameraCoords.z
                                CameraHandler.zoom = cameraCoords.zoom

                                OpenCharacterCustomization()

                            end

                            Wait(1000)
                        end

                    end
                end

            end

        end

        if sleep then
            Citizen.Wait(1000)
        end

    end
    
end)

Citizen.CreateThread(function()

    RegisterPrompts()

    while true do
        Citizen.Wait(0)

        local sleep        = true

        local player       = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)

        if not isPlayerDead and not ClientData.IsBusy then
            local coords = GetEntityCoords(player)

            for locId, locationConfig in pairs(Config.Wardrobes) do

                local coordsDist = vector3(coords.x, coords.y, coords.z)
                local coordsLoc  = vector3(locationConfig.Coords.x, locationConfig.Coords.y, locationConfig.Coords.z)
                local distance   = #(coordsDist - coordsLoc)

                if locationConfig.ActionMarkers.Enabled and distance <= locationConfig.ActionMarkers.Distance then
                    sleep = false

                    local RGBA = locationConfig.ActionMarkers.RGBA
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, locationConfig.Coords.x, locationConfig.Coords.y, locationConfig.Coords.z - 1.2, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 0.7, RGBA.r, RGBA.g, RGBA.b, RGBA.a, false, true, 2, false, false, false, false)
                end
    
                if distance <= locationConfig.ActionDistance then
                    sleep = false

                    local label = CreateVarString(10, 'LITERAL_STRING', Locales['WARDROBE_TITLE'])
                    PromptSetActiveGroupThisFrame(Prompts, label)

                    for i, prompt in pairs (PromptsList) do

                        PromptSetVisible(prompt.prompt, 0)
                        PromptSetEnabled(prompt.prompt, 0)

                        if prompt.type == 'OPEN_WARDROBE' then
                            PromptSetVisible(prompt.prompt, 1)
                            PromptSetEnabled(prompt.prompt, 1)
                        end

                        if PromptHasHoldModeCompleted(prompt.prompt) then

                            if prompt.type == "OPEN_WARDROBE" then
                                TriggerEvent("tpz_clothing:openWardrobe")
                            end

                            Wait(1000)
                        end

                    end
                end

            end

        end

        if sleep then
            Citizen.Wait(1000)
        end

    end
    
end)

-----------------------------------------------------------
--[[ Store Camera Adjustments ]]--
-----------------------------------------------------------


Citizen.CreateThread(function()

    CreateStorePrompts()

    while true do
        Citizen.Wait(0)

        if ClientData.HasStoreOpen then
            
            local playerPed = PlayerPedId()

            -- Displaying prompt label and keys.
            local label = CreateVarString(10, 'LITERAL_STRING', Locales['CAMERA_ADJUSTMENTS'])
            PromptSetActiveGroupThisFrame(StorePrompts, label)
    
            -- Pressed right key.
            if IsControlPressed(2, 0x7065027D) then
                AdjustEntityPedHeading(-5.0)
            end
    
            -- Pressed left key.
            if IsControlPressed(2, 0xB4E465B4) then
                AdjustEntityPedHeading(5.0)
            end

            -- UP CAMERA
            if IsControlPressed(2, 0x8FD015D8) then
                CameraHandler.z = CameraHandler.coords.z

                StartCam(CameraHandler.coords.x, CameraHandler.coords.y, CameraHandler.coords.z, CameraHandler.coords.rotx, CameraHandler.coords.roty,
                CameraHandler.coords.rotz, CameraHandler.zoom)

            end

            -- DOWN CAMERA
            if IsControlPressed(2, 0xD27782E3) then
                CameraHandler.z = CameraHandler.coords.z - 1.0

                StartCam(CameraHandler.coords.x, CameraHandler.coords.y, CameraHandler.coords.z - 1.0, CameraHandler.coords.rotx, CameraHandler.coords.roty,
                CameraHandler.coords.rotz, CameraHandler.zoom)

            end

            if IsControlPressed(2, 0x8BDE7443) then -- zoom out

                if CameraHandler.zoom < 104.0 then -- Zoom out limit

                    CameraHandler.zoom = CameraHandler.zoom + 4.0
 
                    StartCam(CameraHandler.coords.x, CameraHandler.coords.y, CameraHandler.z, CameraHandler.coords.rotx, CameraHandler.coords.roty,
                    CameraHandler.coords.rotz, CameraHandler.zoom)
                end
            end

            if IsControlPressed(2, 0x62800C92) then -- zoom in

                if CameraHandler.zoom > 8.0 then -- Zoom in limit

                    CameraHandler.zoom = CameraHandler.zoom - 4.0

                    StartCam(CameraHandler.coords.x, CameraHandler.coords.y, CameraHandler.z, CameraHandler.coords.rotx, CameraHandler.coords.roty,
                    CameraHandler.coords.rotz, CameraHandler.zoom)
                end

            end

            -- Pressed X key.
            if IsControlPressed(2, 0x8CC9CD42) then

                local dict = Config.HandsUpAnimation.Dict
                local body = Config.HandsUpAnimation.Body

                RequestAnimDict(dict)
    
                while not HasAnimDictLoaded(dict) do
                    RequestAnimDict(dict)
                    Citizen.Wait(10)
                end

                if IsEntityPlayingAnim(playerPed, dict, body, 3) then
                    ClearPedTasks(playerPed)
                    RemoveAnimDict(dict)
                    TaskStandStill(playerPed, -1)
                    
                else
                    TaskPlayAnim(playerPed, dict, body, 8.0, -8.0, -1, 31, 0, true, 0, false, 0, false)
                end

                Wait(500)

            end

        else
            Wait(1000)
        end
    end

end)