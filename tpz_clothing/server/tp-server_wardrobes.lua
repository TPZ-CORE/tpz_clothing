local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

-- The event is triggered from the store menu for saving an outfit that has been created.
RegisterServerEvent("tpz_clothing:server:save")
AddEventHandler("tpz_clothing:server:save", function(databaseType, outfitName, skinComp)

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

    exports.ghmattimysql:execute("INSERT INTO `outfits` ( `identifier`, `charidentifier`, `title`, `comps`) VALUES ( @identifier, @charidentifier, @title, @comps)", Parameters)
end)

RegisterServerEvent("tpz_clothing:server:replace")
AddEventHandler("tpz_clothing:server:replace", function(skinComp)
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


RegisterServerEvent("tpz_clothing:server:rename")
AddEventHandler("tpz_clothing:server:rename", function(outfitId, inputTitle)

    local Parameters = {
        ["id"]    = outfitId,
        ['title'] = inputTitle,
    }

    exports.ghmattimysql:execute("UPDATE `outfits` SET `title` = @title WHERE `id` = @id", Parameters)

end)

-- The event is triggered from the wardrobe menu for removing the selected outfitId from outfits database table.
RegisterServerEvent("tpz_clothing:server:delete")
AddEventHandler("tpz_clothing:server:delete", function(outfitId)
    exports.ghmattimysql:execute("DELETE FROM `outfits` WHERE id = @id", {["id"] = outfitId})
end)