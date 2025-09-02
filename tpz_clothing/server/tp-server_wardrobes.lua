local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local function GetOutfitDataByOsTime(source, time)
    local Clothing = GetClothing()

    for _, outfit in pairs (Clothing[source].outfits) do

        if tostring(outfit.date) == tostring(time) then
            return outfit
        end

    end

    return nil

end

-------------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_clothing:server:wardrobes:update")
AddEventHandler("tpz_clothing:server:wardrobes:update", function(actionType, data)
    local _source   = source
    local Clothing  = GetClothing()

    if actionType == "INSERT" then

        -- by using os.time() the outfit becomes unique (its the id of the outfit).
        local insert_data = { name = data[1], date = os.time(), comps = json.encode(data[2]) }

        table.insert(Clothing[_source], insert_data )
        TriggerClientEvent("tpz_clothing:client:update", _source, { actionType = "INSERT_OUTFIT", data = insert_data })

    elseif actionType == "SET_DEFAULT" then

        local outfit = GetOutfitDataByOsTime(_source, data[1])

        local Parameters = {
            ["charidentifier"] = charidentifier,
            ['skinComp']       = json.encode(outfit.comps),
        }

        exports.ghmattimysql:execute("UPDATE `characters` SET `skinComp` = @skinComp WHERE `charidentifier` = @charidentifier", Parameters)

        xPlayer.setOutfitComponents(json.encode(skinComp))

    elseif actionType == "SHARE" then

        local outfit = GetOutfitDataByOsTime(_source, data[1])
        local target = tonumber(data[2])

        if GetPlayerName(target) == nil then
            -- player not online notify
            return
        end

        outfit.date = os.time()

        table.insert(Clothing[target], outfit )
        TriggerClientEvent("tpz_clothing:client:update", target, { actionType = "INSERT_OUTFIT", data = outfit })

    elseif actionType == "RENAME" then

        for _, outfit in pairs (Clothing[_source].outfits) do

            if tostring(outfit.date) == tostring(data[1]) then
                outfit.name = data[2]
            end

        end

    elseif actionType == "DELETE" then

        for _, outfit in pairs (Clothing[_source].outfits) do

            if tostring(outfit.date) == tostring(data[1]) then
                table.remove(Clothing[_source].outfits, _)
            end

        end

    end

end)
