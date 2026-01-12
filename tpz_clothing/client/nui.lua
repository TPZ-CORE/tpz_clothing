
local CameraHandler   = {coords = nil, zoom = 0, z = 0 }
local CurrentHeading  = 0

local _LocationIndex  = nil

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

        if LocationData.TeleportCoordsOnExit ~= false then
            local LocationData = Config.Stores[_LocationIndex]
            exports.tpz_core:getCoreAPI().TeleportToCoords(LocationData.TeleportCoordsOnExit.x, LocationData.TeleportCoordsOnExit.y, LocationData.TeleportCoordsOnExit.z, LocationData.TeleportCoordsOnExit.h)
        end

        DestroyAllCams(true)

        SetNuiFocus(display, display)

        SendNUIMessage({ type = "enable", enable = display })

        PlayerData.HasNUIActive = false
    
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
    
    _LocationIndex = locationIndex

    while not IsScreenFadedOut() do
        Wait(50)
        DoScreenFadeOut(2000)
    end

    Wait(2000)

    SetEntityHeading(PlayerPedId(), LocationData.Coords.h)
    CurrentHeading = LocationData.Coords.h

    local cameraCoords = LocationData.CameraCoords
    StartCam(cameraCoords.x, cameraCoords.y, cameraCoords.z, cameraCoords.rotx, cameraCoords.roty, cameraCoords.rotz, cameraCoords.zoom)
    CameraHandler.coords = { x = cameraCoords.x, y = cameraCoords.y, z = cameraCoords.z, rotx = cameraCoords.rotx, roty = cameraCoords.roty, rotz = cameraCoords.rotz, fov = cameraCoords.fov }
    CameraHandler.z    = cameraCoords.z
    CameraHandler.zoom = cameraCoords.zoom 

    PlayerData.HasNUIActive = true

    LoadClothingData() -- for loading player skin and all clothing properly.

    Citizen.CreateThread(function()
        
        while PlayerData.HasNUIActive do 
            Wait(0)

            DisplayRadar(false)

        end
    
    end)

    exports.tpz_core:getCoreAPI().TeleportToCoords(LocationData.Coords.x, LocationData.Coords.y, LocationData.Coords.z, LocationData.Coords.h)
    
    Wait(2000)
    DoScreenFadeIn(2000)
    ToggleUI(true)

    SendNUIMessage({ action = 'set_information', title = LocationData.Title, locales = Locales})
end

function CloseNUI()
    if GetPlayerData().HasNUIActive then SendNUIMessage({action = 'close'}) end
end

-----------------------------------------------------------
--[[ General NUI Callbacks ]]--
-----------------------------------------------------------

RegisterNUICallback('close', function()
	ToggleUI(false)
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
    local LocationData = Config.Stores[GetPlayerData().LocationIndex]

    DestroyAllCams(true)

    local cameraCoords = LocationData.CameraCoords
    StartCam(cameraCoords.x, cameraCoords.y, cameraCoords.z, cameraCoords.rotx, cameraCoords.roty, cameraCoords.rotz, cameraCoords.zoom)
    CameraHandler.coords = { x = cameraCoords.x, y = cameraCoords.y, z = cameraCoords.z, rotx = cameraCoords.rotx, roty = cameraCoords.roty, rotz = cameraCoords.rotz, fov = cameraCoords.fov }
    CameraHandler.z    = cameraCoords.z
    CameraHandler.zoom = cameraCoords.zoom 

    CheckBackOutfitCategoryPurchase(data.id, data.palette)

end)

RegisterNUICallback('reset_outfit_category', function()
    ResetOutfitByCategoryName()
end)

