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

TPZ.addNewCallBack("tpz_clothing:callbacks:getPlayerOutfits", function(source, cb)
	local _source         = source

	local xPlayer         = TPZ.GetPlayer(_source)
	local charIdentifier  = xPlayer.getCharacterIdentifier()

	local outfits         = {}

	exports["ghmattimysql"]:execute("SELECT * FROM `outfits`", {}, function(result)

		if TPZ.GetTableLength(result) <= 0 then
			return cb (nil)
		end

		for _, res in pairs (result) do

			if res.charidentifier == charIdentifier then
				table.insert(outfits, res)
			end

		end

		return cb(outfits)
	
	end)

end)
