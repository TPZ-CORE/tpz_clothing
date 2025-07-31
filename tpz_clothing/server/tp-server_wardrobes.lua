local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local function GetOutfitDataByOsTime(source, time)
    local Clothing = GetClothing()

    for _, outfit in pairs (Clothing[source].outfits) do

        if tostring(outfit.date) == tostring(time) then
            return json.encode(outfit.comps)
        end

    end

    return nil

end

-------------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

-- The event is triggered from the store menu for saving an outfit that has been created.
RegisterServerEvent("tpz_clothing:server:saveOutfit")
AddEventHandler("tpz_clothing:server:saveOutfit", function(outfitName, skinComp)
	local _source    = source
    local Clothing   = GetClothing()

    -- by using os.time() the outfit becomes unique (its the id of the outfit).
    local insert_data = { name = outfitName, date = os.time(), comps = json.encode(skinComp) }

    table.insert(Clothing[_source], insert_data )
    TriggerClientEvent("tpz_clothing:client:update", _source, { actionType = "INSERT_OUTFIT", data = insert_data })
end)

RegisterServerEvent("tpz_clothing:server:setDefaultOutfit")
AddEventHandler("tpz_clothing:server:setDefaultOutfit", function(osTime)
    local _source  = source
    local xPlayer   = TPZ.GetPlayer(_source)
    local Clothing  = GetClothing()
	
    local skinComp  = GetOutfitDataByOsTime(_source, osTime)

    local Parameters = {
        ["charidentifier"] = charidentifier,
        ['skinComp']       = skinComp,
    }

    exports.ghmattimysql:execute("UPDATE `characters` SET `skinComp` = @skinComp WHERE `charidentifier` = @charidentifier", Parameters)

    xPlayer.setOutfitComponents(json.encode(skinComp))
end)


RegisterServerEvent("tpz_clothing:server:renameOutfit")
AddEventHandler("tpz_clothing:server:renameOutfit", function(outfitId, inputTitle)
    local Parameters = { ["id"] = outfitId, ['title'] = inputTitle }
    exports.ghmattimysql:execute("UPDATE `outfits` SET `title` = @title WHERE `id` = @id", Parameters)
end)

-- The event is triggered from the wardrobe menu for removing the selected outfitId from outfits database table.
RegisterServerEvent("tpz_clothing:server:deleteOutfit")
AddEventHandler("tpz_clothing:server:deleteOutfit", function(outfitId)
    exports.ghmattimysql:execute("DELETE FROM `outfits` WHERE id = @id", {["id"] = outfitId})
end)