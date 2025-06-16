local TPZ = exports.tpz_core:getCoreAPI()

local ClothesList = {} -- Required for saving and loading purchased clothes. 

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  ClothesList = nil
end)

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_clothing:server:request")
AddEventHandler("tpz_clothing:server:request", function()
    local _source        = source

    local xPlayer        = TPZ.GetPlayer(_source)
    local charIdentifier = xPlayer.getCharacterIdentifier()

    exports["ghmattimysql"]:execute("SELECT `boughtOutfitComps` FROM `characters` WHERE `charidentifier` = @charidentifier", { ['charidentifier'] = charIdentifier }, function(result)
		
        if not result or result and not result[1].boughtOutfitComps then
            print("^1[WARNING] - boughtOutfitComps column does not exist on characters table")
            return
        end

        ClothesList[charIdentifier] = {}

        local boughtComps = json.decode(result[1].boughtOutfitComps)

        if boughtComps and TPZ.GetTableLength(boughtComps) > 0 then
            ClothesList[charIdentifier] = boughtComps
        end

        TriggerClientEvent("tpz_clothing:client:update", _source, ClothesList[charIdentifier])
		
    end)

end)

RegisterServerEvent("tpz_clothing:server:buy")
AddEventHandler("tpz_clothing:server:buy", function(category, index)
    local _source        = source

    local xPlayer        = TPZ.GetPlayer(_source)
    local charIdentifier = xPlayer.getCharacterIdentifier()

    if Config.OutfitCategories[category] == nil then
        return
    end

    local OutfitData   = Config.OutfitCategories[category][index]
    local currentMoney = xPlayer.getAccount(0)

    if currentMoney < OutfitData.Cost then
        SendNotification(_source, Locales["NOT_ENOUGH_MONEY"], "error")
        return
    end

    table.insert(ClothesList[charIdentifier], { category = category, index = index })

    xPlayer.removeAccount(0, OutfitData.Cost)
    SendNotification(_source, string.format(Locales["BOUGHT_CLOTH"], OutfitData.Cost), "success")

end)

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
