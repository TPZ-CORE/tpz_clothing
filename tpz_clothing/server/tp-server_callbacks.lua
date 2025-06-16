local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

TPZ.addNewCallBack("tpz_clothing:callbacks:getPlayerDefaultOutfit", function(source, cb)
	local _source         = source

	local xPlayer         = TPZ.GetPlayer(_source)
	local charidentifier  = xPlayer.getCharacterIdentifier()

    exports["ghmattimysql"]:execute("SELECT * FROM `characters` WHERE `charidentifier` = @charidentifier", { ['charidentifier'] = charidentifier }, function(result)
		
		return cb(result[1].skinComp)
	
	end)
end)

TPZ.addNewCallBack("tpz_clothing:callbacks:getPlayerOutfits", function(source, cb, data)
	local _source         = source

	local xPlayer         = TPZ.GetPlayer(_source)
	local charIdentifier  = xPlayer.getCharacterIdentifier()

	local outfits         = {}

    exports["ghmattimysql"]:execute("SELECT * FROM `outfits` WHERE `charidentifier` = @charidentifier, { ["charidentifier"] = charIdentifier }, function(result)

        if TPZ.GetTableLength(result) > 0 then

            for _, res in pairs (result) do
                table.insert(outfits, res)
			end

		end

		return cb(outfits)
	
	end)

end)
