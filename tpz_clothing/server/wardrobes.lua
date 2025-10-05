local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local function DoesOutfitExistAlready(source, title)
    local Clothing = GetClothing()

    for _, outfit in pairs (Clothing[source].outfits) do

        if tostring(outfit.name) == tostring(title) then
            return true
        end

    end

    return false

end

local function GetOutfitDataByDate(source, date)
    local Clothing = GetClothing()

    for _, outfit in pairs (Clothing[source].outfits) do

        if tostring(outfit.date) == tostring(date) then
            return outfit
        end

    end

    return nil

end

local DoesCategoryExist = function(category)

	for _, cloth in pairs (Config.ClothingCategories) do 

		if category == cloth.category then
			return true
		end

	end

	return false

end


-------------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_clothing:server:wardrobes:update")
AddEventHandler("tpz_clothing:server:wardrobes:update", function(actionType, data)
    local _source   = source
    local xPlayer   = TPZ.GetPlayer(_source)
    local Clothing  = GetClothing()

    if actionType == "INSERT" then

        local DoesOutfitExist = DoesOutfitExistAlready(_source, data[1])

        if DoesOutfitExist then
            ----------------------------
            return
        end

        local skin = json.decode(data[2])
        local new_skin = {}

        for category, data in pairs (skin) do

            if DoesCategoryExist(category) then
                new_skin[category] = data
            end

        end

        -- by using os.time() the outfit becomes unique (its the id of the outfit).
        local insert_data = { name = data[1], comps = new_skin, date = os.time() }

        table.insert(Clothing[_source].outfits, insert_data )
        TriggerClientEvent("tpz_clothing:client:update", _source, { actionType = "INSERT_OUTFIT", data = insert_data })

    elseif actionType == "SET_DEFAULT" then

        local OutfitData  = GetOutfitDataByDate(_source, data[1])
        local skinComp    = xPlayer.getOutfitComponents()

        skinComp = json.decode(skinComp)

        -- if it's still a string (double encoded), decode again
        if type(skinComp) == "string" then
            skinComp = json.decode(skinComp)
        end
        
        for _category, _ in pairs (Config.ComponentCategories) do

            if OutfitData.comps[_category] ~= nil then
                local category, data = _category, OutfitData.comps[_category]
                skinComp[category] = data
            else 
                skinComp[category] = { id = 0, palette = 0, albedo = 0, material = 0, normal = 0, drawable = 0,  tint0 = 0, tint1 = 0, tint2 = 0 }
            end

        end

        local Parameters = {
            ["charidentifier"] = xPlayer.getCharacterIdentifier(),
            ['skinComp']       = json.encode(skinComp),
        }

       exports.ghmattimysql:execute("UPDATE `characters` SET `skinComp` = @skinComp WHERE `charidentifier` = @charidentifier", Parameters)

        xPlayer.setOutfitComponents(json.encode(skinComp))

    elseif actionType == "RENAME" then

        for _, outfit in pairs (Clothing[_source].outfits) do

            if tostring(outfit.date) == tostring(data[1]) then
                outfit.name = data[2]
            end

        end

    elseif actionType == "DELETE" then

        for _, outfit in pairs (Clothing[_source].outfits) do

            if tostring(outfit.date) == tostring(data[1]) then
                table.remove(Clothing[_source].outfits, _)
            end

        end

    end

end)
