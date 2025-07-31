local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_clothing:callbacks:getPlayerOutfits", function(source, cb)
	local _source         = source

	local xPlayer         = TPZ.GetPlayer(_source)
	local charIdentifier  = xPlayer.getCharacterIdentifier()

	exports["ghmattimysql"]:execute("SELECT * FROM `outfits` WHERE `charidentifier` = @charidentifier", { ["@charidentifier"] = charIdentifier }, function(result)

		local returned_data = {}

		if result and result[1] then 
			returned_data = json.decode(result[1].outfits
		end

		return cb(returned_data)
	
	end)

end)
