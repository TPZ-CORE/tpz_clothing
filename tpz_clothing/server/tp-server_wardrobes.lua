local TPZ = exports.tpz_core:getCoreAPI()

-- The event is triggered from the store menu for saving an outfit that has been created.
RegisterServerEvent("tpz_clothing:save")
AddEventHandler("tpz_clothing:save", function(databaseType, outfitName, skinComp)

	local _source         = source

	local xPlayer         = TPZ.GetPlayer(_source)
	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()

    local Parameters = { 
        ['identifier']     = identifier, 
        ['charidentifier'] = charidentifier,
        ['title']          = outfitName,
        ['comps']          = json.encode(skinComp), 
    }

    exports.ghmattimysql:execute("INSERT INTO `" .. databaseType .. "` ( `identifier`, `charidentifier`, `title`, `comps`) VALUES ( @identifier, @charidentifier, @title, @comps)", Parameters)
end)

RegisterServerEvent("tpz_clothing:replace")
AddEventHandler("tpz_clothing:replace", function(skinComp)
    local _source         = source

	local xPlayer         = TPZ.GetPlayer(_source)
    local charidentifier  = xPlayer.getCharacterIdentifier()

    local newSkinComp     = json.decode(skinComp)

    exports["ghmattimysql"]:execute("SELECT * FROM `characters` WHERE `charidentifier` = @charidentifier", { ['charidentifier'] = charidentifier }, function(result)
		
		local currentSkinComp = json.decode(result[1].skinComp)
        local finished        = false

        for _, comp in pairs (newSkinComp) do

            if currentSkinComp[_] then currentSkinComp[_] = comp end

            if next(newSkinComp, _) == nil then
                finished = true
            end

        end

        while not finished do
            Wait(100)
        end

        local Parameters = {
            ["charidentifier"] = charidentifier,
            ['skinComp']       = json.encode(currentSkinComp),
        }
    
       exports.ghmattimysql:execute("UPDATE `characters` SET `skinComp` = @skinComp WHERE `charidentifier` = @charidentifier", Parameters)

    end)
    
end)


RegisterServerEvent("tpz_clothing:rename")
AddEventHandler("tpz_clothing:rename", function(databaseType, outfitId, inputTitle)

    local Parameters = {
        ["id"]    = outfitId,
        ['title'] = inputTitle,
    }

    exports.ghmattimysql:execute("UPDATE `" .. databaseType .. "` SET `title` = @title WHERE `id` = @id", Parameters)

end)

-- The event is triggered from the wardrobe menu for removing the selected outfitId from outfits database table.
RegisterServerEvent("tpz_clothing:delete")
AddEventHandler("tpz_clothing:delete", function(databaseType, outfitId)
    exports.ghmattimysql:execute("DELETE FROM " .. databaseType .. " WHERE id = @id", {["id"] = outfitId})
end)