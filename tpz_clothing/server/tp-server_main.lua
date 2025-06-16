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
