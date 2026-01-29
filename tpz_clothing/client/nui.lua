
local CameraHandler   = {coords = nil, zoom = 0, default_zoom = 0, z = 0 }
local CurrentHeading  = 0

local hasTasksActive  = false
local Heading         = 0


-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local ToggleUI = function(display, data)
    local PlayerData = GetPlayerData()

    if not display then 

        while not IsScreenFadedOut() do
            Wait(50)
            DoScreenFadeOut(2000)
        end

        local LocationData = Config.Stores[GetPlayerData().LocationIndex]

        if LocationData.TeleportCoordsOnExit ~= false then
            exports.tpz_core:getCoreAPI().TeleportToCoords(LocationData.TeleportCoordsOnExit.x, LocationData.TeleportCoordsOnExit.y, LocationData.TeleportCoordsOnExit.z, LocationData.TeleportCoordsOnExit.h)
        end

        if LocationData.Instance then
        	TriggerServerEvent('tpz_core:instanceplayers', 0) 
        end

        DestroyAllCams(true)

        SetNuiFocus(display, display)

        SendNUIMessage({ type = "enable", enable = display })

        PlayerData.HasNUIActive = false
        hasTasksActive = false

        Wait(2000)
        DoScreenFadeIn(2000)

        TriggerServerEvent("tpz_clothing:server:save")
        
    else
        SetNuiFocus(display, display)
    
        SendNUIMessage({ type = "enable", enable = display })

    end
end

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function GetCameraHandler()
    return CameraHandler
end

function OpenCharacterCustomization(locationIndex)
    local PlayerData   = GetPlayerData()
    local LocationData = Config.Stores[locationIndex]
    
    while not IsScreenFadedOut() do
        Wait(50)
        DoScreenFadeOut(2000)
    end

    Wait(2000)

    CurrentHeading = LocationData.Coords.h

    local cameraCoords = LocationData.CameraCoords
    StartCam(cameraCoords.x, cameraCoords.y, cameraCoords.z, cameraCoords.rotx, cameraCoords.roty, cameraCoords.rotz, cameraCoords.zoom)
    CameraHandler.coords = { x = cameraCoords.x, y = cameraCoords.y, z = cameraCoords.z, rotx = cameraCoords.rotx, roty = cameraCoords.roty, rotz = cameraCoords.rotz, fov = cameraCoords.fov }
    CameraHandler.z    = cameraCoords.z
    CameraHandler.zoom = cameraCoords.zoom 
    CameraHandler.default_zoom = cameraCoords.zoom

    Heading = GetEntityHeading(PlayerPedId())

    PlayerData.HasNUIActive = true

    TriggerEvent("tpz_clothing:client:tasks", locationIndex)

    LoadClothingData() -- for loading player skin and all clothing properly.

    if LocationData.TeleportCoords ~= false then
        exports.tpz_core:getCoreAPI().TeleportToCoords(LocationData.TeleportCoords.x, LocationData.TeleportCoords.y, LocationData.TeleportCoords.z, LocationData.TeleportCoords.h)
    else 
        exports.tpz_core:getCoreAPI().TeleportToCoords(LocationData.Coords.x, LocationData.Coords.y, LocationData.Coords.z, LocationData.Coords.h)
    end

    if LocationData.Instance then
        local instanced = GetPlayerServerId(PlayerId()) + 456565
        TriggerServerEvent('tpz_core:instanceplayers', math.floor(instanced)) 
    end

    Wait(2000)
    DoScreenFadeIn(2000)
    ToggleUI(true)

    SendNUIMessage({ action = 'set_information', title = LocationData.Title, locales = Locales})
end

function CloseNUI()
    if GetPlayerData().HasNUIActive then SendNUIMessage({action = 'close'}) end
end

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    local PlayerData = GetPlayerData()

    if PlayerData.HasNUIActive then
        
        DestroyAllCams(true)

        local LocationData = Config.Stores[PlayerData.LocationIndex]

        if LocationData.TeleportCoords ~= false then
          exports.tpz_core:getCoreAPI().TeleportToCoords(LocationData.Coords.x, LocationData.Coords.y, LocationData.Coords.z, LocationData.Coords.h)
        end

        if LocationData.Instance then
        	TriggerServerEvent('tpz_core:instanceplayers', 0) 
        end

    end

end)


Citizen.CreateThread(function() RegisterStoreActionPrompts() end)

AddEventHandler("tpz_clothing:client:tasks", function(locationIndex)

    if hasTasksActive then 
        return 
    end

    hasTasksActive = true

    local LocationData = Config.Stores[locationIndex]

    Citizen.CreateThread(function()

        while GetPlayerData().HasNUIActive do 

            Wait(0)
            
            DisplayRadar(false)
            
            local Prompts, PromptList = GetStoreLocationPromptData()

            local label = CreateVarString(10, 'LITERAL_STRING', Locales['CLOTHING_TITLE'])
            PromptSetActiveGroupThisFrame(Prompts, label)
    
            DrawLightWithRange(LocationData.Lighting.Coords, LocationData.Lighting.RGB.R, LocationData.Lighting.RGB.G, LocationData.Lighting.RGB.B, LocationData.Lighting.Range, LocationData.Lighting.Intensity)
        end
    
    end)

end)

-----------------------------------------------------------
--[[ General NUI Callbacks ]]--
-----------------------------------------------------------

RegisterNUICallback('close', function()
	ToggleUI(false)
end)


RegisterNUICallback('key_action', function(data)
    
    local playerPed = PlayerPedId()

    -- Pressed right key.
    if data.action == 'ROTATE_LEFT' then
        Heading = Heading - 2.5
        SetPedDesiredHeading(PlayerPedId(), Heading)
    end

    -- Pressed left key.
    if data.action == 'ROTATE_RIGHT' then
		Heading = Heading + 2.5
		SetPedDesiredHeading(PlayerPedId(), Heading)
    end
    -- UP CAMERA

    if data.action == 'UP_CAMERA' then

        if CameraHandler.coords.z <= CameraHandler.z + 0.5 then

            CameraHandler.coords.z = CameraHandler.coords.z + 0.01
            StartCam(CameraHandler.coords.x, CameraHandler.coords.y, CameraHandler.coords.z, CameraHandler.coords.rotx, CameraHandler.coords.roty,
            CameraHandler.coords.rotz, CameraHandler.zoom)

        end

    end

    -- DOWN CAMERA
    if data.action == 'DOWN_CAMERA' then

        if CameraHandler.coords.z >= CameraHandler.z - 1.0 then

            CameraHandler.coords.z = CameraHandler.coords.z - 0.01

            StartCam(CameraHandler.coords.x, CameraHandler.coords.y, CameraHandler.coords.z, CameraHandler.coords.rotx, CameraHandler.coords.roty,
            CameraHandler.coords.rotz, CameraHandler.zoom)

        end
    end

    if data.action == 'ZOOM_OUT' then

        if CameraHandler.zoom < CameraHandler.default_zoom then -- Zoom out limit

            CameraHandler.zoom = CameraHandler.zoom + 0.5

            StartCam(CameraHandler.coords.x, CameraHandler.coords.y, CameraHandler.coords.z, CameraHandler.coords.rotx, CameraHandler.coords.roty,
            CameraHandler.coords.rotz, CameraHandler.zoom)
        end
    end

    if data.action == 'ZOOM_IN' then

        if CameraHandler.zoom > 11.0 then -- Zoom in limit
            

            CameraHandler.zoom = CameraHandler.zoom - 0.5

            StartCam(CameraHandler.coords.x, CameraHandler.coords.y, CameraHandler.coords.z, CameraHandler.coords.rotx, CameraHandler.coords.roty,
            CameraHandler.coords.rotz, CameraHandler.zoom)
        end

    end

    -- Pressed X key.
    if data.action == 'HANDS_UP_DOWN' then

        local dict = Config.HandsUpAnimation.Dict
        local body = Config.HandsUpAnimation.Body

        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            RequestAnimDict(dict)
            Citizen.Wait(100)
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


end)

-----------------------------------------------------------
--[[ Wardrobe NUI Callbacks ]]--
-----------------------------------------------------------

RegisterNUICallback('save', function()
    local inputData = {
        title        = Locales['SAVE_OUTFIT_TITLE'],
        desc         = Locales['SAVE_OUTFIT_DESCRIPTION'],
        buttonparam1 = Locales['ACCEPT_BUTTON'],
        buttonparam2 = Locales['DECLINE_BUTTON']
    }
                                
    TriggerEvent("tpz_inputs:getTextInput", inputData, function(cb)

        if cb ~= "DECLINE" or cb ~= Locales['DECLINE_BUTTON'] then

            local skin = json.encode(GetPlayerSkinData())

            TriggerServerEvent("tpz_clothing:server:wardrobes:update", 'INSERT', { cb, skin } )
        end

    end) 

end)

-----------------------------------------------------------
--[[ Clothing Store NUI Callbacks ]]--
-----------------------------------------------------------

RegisterNUICallback('request_clothing_categories', function()
    local Clothing = GetClothing()

    SendNUIMessage({ action = 'reset_categories' })
    
    for _, element in pairs (Config.ClothingCategories) do 

        if Clothing[element.category] then

            SendNUIMessage({
                action = 'insertCategory',
                result = element,
            })
            
        end

    end

    SendNUIMessage({ action = 'display_categories' })
end)

-- data.category, data.title
RegisterNUICallback('request_category_data', function(data)
    LoadSelectedCategoryClothingData(data.category, data.title)
end)

-- data.id
RegisterNUICallback('load_selected_cloth', function(data)

    LoadSelectedOutfitById(data, false)
end)

RegisterNUICallback('buy_item', function(data)
    BuySelectedCategoryItem(data)
end)

-- when going back to categories, we reset the camera to normal view.
RegisterNUICallback('back', function(data)
    CheckBackOutfitCategoryPurchase(data.id, data.palette)

end)

RegisterNUICallback('reset_outfit_category', function()
    ResetOutfitByCategoryName()
end)


RegisterNUICallback('set_default', function(data)

    local TagData = GetMetaPedData(GetSelectedCategoryType() == "Boots" and "boots" or GetSelectedCategoryType())

    if not TagData then return end 

    local _data = {
        id        = data.id, 
        palette   = data.palette,
        normal    = TagData.normal,
        material  = TagData.material,
        drawable  = TagData.drawable,
		albedo    = TagData.albedo,
        tint0     = data.tint0,
        tint1     = data.tint1,
        tint2     = data.tint2,

    }

    TriggerServerEvent("tpz_clothing:server:set_default_category_outfit", GetSelectedCategoryType(), _data)
end)
