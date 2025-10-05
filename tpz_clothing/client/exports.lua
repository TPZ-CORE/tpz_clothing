-----------------------------------------------------------
--[[ Exports ]]--
-----------------------------------------------------------

-- @function : openWardrobe menu function.  
exports('openWardrobe', function() OpenWardrobe() end)

-- @return isBusy : returns a boolean (if player has open buying menu or wardrobes menu).
exports('isBusy', function() 
    local PlayerData = GetPlayerData()
    return PlayerData.HasMenuActive or PlayerData.HasNUIActive 
end)
