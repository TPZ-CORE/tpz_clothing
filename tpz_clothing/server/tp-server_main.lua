local TPZ = exports.tpz_core:getCoreAPI()
local Clothing = {} -- Required for saving and loading purchased clothes and wardrobe outfits. 

-----------------------------------------------------------
--[[ Functions ]]--
-------------------------------------------------------------

function GetClothingData()
  return Clothing
end

-------------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  Clothing = nil
end)

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_clothing:server:request")
AddEventHandler("tpz_clothing:server:request", function()
    local _source        = source
    local xPlayer        = TPZ.GetPlayer(_source)
    local charIdentifier = xPlayer.getCharacterIdentifier()

    exports["ghmattimysql"]:execute("SELECT * FROM `outfits` WHERE `charidentifier` = @charidentifier", { ['charidentifier'] = charIdentifier }, function(result)
		
        Clothing[_source] = { outfits = {}, purchased = {} }

        if result and result[1] then
          Clothing[_source].outfits   = json.decode(result[1].outfits)
          Clothing[_source].purchased = json.decode(result[1].purchased)
        end

        TriggerClientEvent("tpz_clothing:client:update", _source, { actionType = "REQUEST", data = Clothing[_source] })
		
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
