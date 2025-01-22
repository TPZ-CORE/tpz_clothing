local TPZ    = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

-- @GetTableLength returns the length of a table.
local GetTableLength = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------


exports.tpz_core:server().addNewCallBack("tpz_clothing:getPlayerDefaultOutfit", function(source, cb)
	local _source         = source

	local xPlayer         = TPZ.GetPlayer(_source)
	local charidentifier  = xPlayer.getCharacterIdentifier()

    exports["ghmattimysql"]:execute("SELECT * FROM `characters` WHERE `charidentifier` = @charidentifier", { ['charidentifier'] = charidentifier }, function(result)
		
		return cb(result[1].skinComp)
	
	end)
end)

exports.tpz_core:server().addNewCallBack("tpz_clothing:getPlayerOutfits", function(source, cb, data)
	local _source         = source

	local xPlayer         = TPZ.GetPlayer(_source)
	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()

	local outfits         = {}

    exports["ghmattimysql"]:execute("SELECT * FROM " .. data.type, {}, function(result)

        local length = GetTableLength(result)

        if length > 0 then

            for _, res in pairs (result) do

				if res.identifier == identifier and res.charidentifier == charidentifier then
					table.insert(outfits, res)
				end

			end

		end

		return cb(outfits)
	
	end)

end)
