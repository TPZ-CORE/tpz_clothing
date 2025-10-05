local TPZ = exports.tpz_core:getCoreAPI()
local Clothing = {} -- Required for saving and loading purchased clothes and wardrobe outfits. 

-----------------------------------------------------------
--[[ Functions ]]--
-------------------------------------------------------------

function GetClothing()
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

AddEventHandler('playerDropped', function (reason, resourceName, clientDropReason)
    local _source = source

    if not Clothing[_source] then
      return
    end
    Clothing[_source] = nil
end)


-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_clothing:server:request")
AddEventHandler("tpz_clothing:server:request", function()
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)

    if not xPlayer.loaded() then
      return
    end

    local identifier      = xPlayer.getIdentifier()
    local charIdentifier  = xPlayer.getCharacterIdentifier()

    exports["ghmattimysql"]:execute("SELECT * FROM `outfits` WHERE `charidentifier` = @charidentifier", { ['charidentifier'] = charIdentifier }, function(result)
		
        Clothing[_source] = { identifier = identifier, charidentifier = charIdentifier, outfits = {}, purchased = {} }

        if result and result[1] then
          Clothing[_source].outfits   = json.decode(result[1].outfits)
          Clothing[_source].purchased = json.decode(result[1].purchased)
        else

          local Parameters = { ["identifier"] = identifier, ["charidentifier"] = charIdentifier }
          exports.ghmattimysql:execute("INSERT INTO `outfits` (`identifier`, `charidentifier` ) VALUES (@identifier, @charidentifier)", Parameters)
        end

        TriggerClientEvent("tpz_clothing:client:update", _source, { actionType = "REQUEST", data = Clothing[_source] })
		
    end)

end)


RegisterServerEvent("tpz_clothing:server:save")
AddEventHandler("tpz_clothing:server:save", function()
  local _source = source
  
  local ClothingData = Clothing[_source]

  local Parameters = {
    ['charidentifier'] = ClothingData.charidentifier,
    ['outfits']        = json.encode(ClothingData.outfits),
    ['purchased']      = json.encode(ClothingData.purchased)
  }
  exports.ghmattimysql:execute("UPDATE `outfits` SET `outfits` = @outfits, `purchased` = @purchased WHERE `charidentifier` = @charidentifier", Parameters)
end)

RegisterServerEvent("tpz_clothing:server:buy")
AddEventHandler("tpz_clothing:server:buy", function(category, index, palette, cb)
  local _source        = source

  local xPlayer        = TPZ.GetPlayer(_source)
  local charIdentifier = xPlayer.getCharacterIdentifier()

  local cost           = Config.OutfitCosts[category]
  local currentMoney   = xPlayer.getAccount(0)

  if currentMoney < cost then
    SendNotification(_source, Locales["NOT_ENOUGH_MONEY"], "error")
    return
  end

  if Clothing[_source].purchased[category] == nil then 
    Clothing[_source].purchased[category] = {}
  end

  table.insert(Clothing[_source].purchased[category], { id = index, palette = palette } )

  if cb == nil or cb ~= 1 then
    xPlayer.removeAccount(0, cost)
  end

  TriggerClientEvent('tpz_clothing:client:update', _source, { actionType = 'INSERT_PURCHASED_ITEM', data = { category, index, palette } })
  SendNotification(_source, string.format(Locales["BOUGHT_CLOTH"], cost), "success")

end)
