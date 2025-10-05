local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_clothing:callbacks:getPlayerOutfits", function(source, cb)
	local _source       = source
	local xPlayer       = TPZ.GetPlayer(_source)
	
    local ClothingData  = GetClothingData()
	local returned_data = { outfits = {}, purchased = {} }

	if ClothingData[_source] then 
		returned_data = { outfits = ClothingData[_source].outfits, purchased = ClothingData[_source].purchased } 
	end

	return cb(returned_data)
end)
