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
        
        for category, data in pairs (OutfitData.comps) do
            skinComp[category] = data
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

/*

[{"comps":{"shirt":{"normal":0,"albedo":0,"palette":8,"tint2":0,"id":5,"drawable":0,"material":0,"tint0":0,"tint1":0},"boots":{"normal":0,"albedo":0,"palette":6,"tint2":0,"id":4,"drawable":0,"material":0,"tint0":0,"tint1":0},"ringlh":{"normal":0,"albedo":0,"palette":1,"tint2":0,"id":0,"drawable":0,"material":0,"tint0":0,"tint1":0},"vest":{"normal":0,"albedo":0,"palette":1,"tint2":0,"id":0,"drawable":0,"material":0,"tint0":0,"tint1":0},"pant":{"normal":0,"albedo":0,"palette":13,"tint2":0,"id":14,"drawable":0,"material":0,"tint0":0,"tint1":0},"ringrh":{"normal":0,"albedo":0,"palette":1,"tint2":0,"id":2,"drawable":0,"material":0,"tint0":0,"tint1":0},"gunbelt":{"palette":0,"id":0},"coatclosed":{"normal":0,"albedo":0,"palette":1,"tint2":0,"id":0,"drawable":0,"material":0,"tint0":0,"tint1":0},"coat":{"normal":0,"albedo":0,"palette":8,"tint2":0,"id":7,"drawable":0,"material":0,"tint0":0,"tint1":0}},"name":"Default","date":1759691565},{"comps":{"hat":{"normal":0,"albedo":0,"palette":5,"tint2":0,"id":2,"drawable":0,"material":0,"tint0":0,"tint1":0},"gunbelt":{"palette":0,"id":0},"ringlh":{"normal":0,"albedo":0,"palette":1,"tint2":0,"id":0,"drawable":0,"material":0,"tint0":0,"tint1":0},"vest":{"normal":0,"albedo":0,"palette":1,"tint2":0,"id":0,"drawable":0,"material":0,"tint0":0,"tint1":0},"pant":{"normal":0,"albedo":0,"palette":13,"tint2":0,"id":14,"drawable":0,"material":0,"tint0":0,"tint1":0},"ringrh":{"normal":0,"albedo":0,"palette":1,"tint2":0,"id":2,"drawable":0,"material":0,"tint0":0,"tint1":0},"coatclosed":{"normal":0,"albedo":0,"palette":1,"tint2":0,"id":0,"drawable":0,"material":0,"tint0":0,"tint1":0},"coat":{"normal":0,"albedo":0,"palette":8,"tint2":0,"id":7,"drawable":0,"material":0,"tint0":0,"tint1":0},"shirt":{"normal":0,"albedo":0,"palette":8,"tint2":0,"id":5,"drawable":0,"material":0,"tint0":0,"tint1":0},"boots":{"normal":0,"albedo":0,"palette":6,"tint2":0,"id":4,"drawable":0,"material":0,"tint0":0,"tint1":0}},"name":"Default2","date":1759694114}]

{"ringlh":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"scale":1.0,"beard":{"color":5,"id":13},"Pant":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"torso":-162963160,"vest":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"coatclosed":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Shirt":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"headtype":-2064391035,"gunbelt":{"id":0, "palette": 0},"ringrh":{"material":0,"tint0":0,"normal":0,"palette":1,"id":2,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"legstype":174153218,"body":-162963160,"teeth":712446626,"bodytype":-162963160,"legs":174153218,"albedo":317354806,"eyebrows":{"color":7,"visibility":1,"id":9,"opacity":1.0},"hair":{"color":5,"id":2},"shirt":{"material":0,"tint0":0,"normal":0,"palette":8,"id":5,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Boots":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Gunbelt":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"waist":-2045421226,"coat":{"material":0,"tint0":0,"normal":0,"palette":8,"id":7,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"eyes":612262189,"sex":"mp_male","boots":{"material":0,"tint0":0,"normal":0,"palette":6,"id":4,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"pant":{"material":0,"tint0":0,"normal":0,"palette":13,"id":14,"drawable":0,"tint1":0,"albedo":0,"tint2":0}}

{"ringlh":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"scale":1.0,"beard":{"color":5,"id":13},"Pant":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"torso":-162963160,"vest":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"coatclosed":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Shirt":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"headtype":-2064391035,"gunbelt":{"id":0, "palette": 0},"ringrh":{"material":0,"tint0":0,"normal":0,"palette":1,"id":2,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"legstype":174153218,"body":-162963160,"teeth":712446626,"bodytype":-162963160,"legs":174153218,"albedo":317354806,"eyebrows":{"color":7,"visibility":1,"id":9,"opacity":1.0},"hair":{"color":5,"id":2},"shirt":{"material":0,"tint0":0,"normal":0,"palette":8,"id":5,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Boots":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Gunbelt":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"waist":-2045421226,"coat":{"material":0,"tint0":0,"normal":0,"palette":8,"id":7,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"eyes":612262189,"sex":"mp_male","boots":{"material":0,"tint0":0,"normal":0,"palette":6,"id":4,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"pant":{"material":0,"tint0":0,"normal":0,"palette":13,"id":14,"drawable":0,"tint1":0,"albedo":0,"tint2":0}}

{"ringlh":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"scale":1.0,"beard":{"color":5,"id":13},"Pant":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"torso":-162963160,"vest":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"coatclosed":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Shirt":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"headtype":-2064391035,"gunbelt":{"id":0, "palette": 0},"ringrh":{"material":0,"tint0":0,"normal":0,"palette":1,"id":2,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"legstype":174153218,"body":-162963160,"teeth":712446626,"bodytype":-162963160,"legs":174153218,"albedo":317354806,"eyebrows":{"color":7,"visibility":1,"id":9,"opacity":1.0},"hair":{"color":5,"id":2},"shirt":{"material":0,"tint0":0,"normal":0,"palette":8,"id":5,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Boots":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Gunbelt":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"waist":-2045421226,"coat":{"material":0,"tint0":0,"normal":0,"palette":8,"id":7,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"eyes":612262189,"sex":"mp_male","boots":{"material":0,"tint0":0,"normal":0,"palette":6,"id":4,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"pant":{"material":0,"tint0":0,"normal":0,"palette":13,"id":14,"drawable":0,"tint1":0,"albedo":0,"tint2":0}}
{"ringlh":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"scale":1.0,"beard":{"color":5,"id":13},"Pant":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"torso":-162963160,"vest":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"coatclosed":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Shirt":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"headtype":-2064391035,"gunbelt":{"id":0, "palette": 0},"ringrh":{"material":0,"tint0":0,"normal":0,"palette":1,"id":2,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"legstype":174153218,"body":-162963160,"teeth":712446626,"bodytype":-162963160,"legs":174153218,"albedo":317354806,"eyebrows":{"color":7,"visibility":1,"id":9,"opacity":1.0},"hair":{"color":5,"id":2},"shirt":{"material":0,"tint0":0,"normal":0,"palette":8,"id":5,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Boots":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"Gunbelt":{"material":0,"tint0":0,"normal":0,"palette":1,"id":0,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"waist":-2045421226,"coat":{"material":0,"tint0":0,"normal":0,"palette":8,"id":7,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"eyes":612262189,"sex":"mp_male","boots":{"material":0,"tint0":0,"normal":0,"palette":6,"id":4,"drawable":0,"tint1":0,"albedo":0,"tint2":0},"pant":{"material":0,"tint0":0,"normal":0,"palette":13,"id":14,"drawable":0,"tint1":0,"albedo":0,"tint2":0}}
{"bodytype":-162963160,"legstype":174153218,"hat":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":2,"albedo":0,"palette":5},"teeth":712446626,"headtype":-2064391035,"torso":-162963160,"body":-162963160,"scale":1.0,"Pant":{"drawable":0,"tint2":0,"albedo":0,"tint1":0,"palette":1,"material":0,"tint0":0,"id":0,"normal":0},"Boots":{"drawable":0,"tint2":0,"albedo":0,"tint1":0,"palette":1,"material":0,"tint0":0,"id":0,"normal":0},"eyes":612262189,"pant":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":14,"albedo":0,"palette":13},"boots":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":4,"albedo":0,"palette":6},"sex":"mp_male","waist":-2045421226,"coat":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":7,"albedo":0,"palette":8},"ringlh":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":0,"albedo":0,"palette":1},"Gunbelt":{"drawable":0,"tint2":0,"albedo":0,"tint1":0,"palette":1,"material":0,"tint0":0,"id":0,"normal":0},"albedo":317354806,"Shirt":{"drawable":0,"tint2":0,"albedo":0,"tint1":0,"palette":1,"material":0,"tint0":0,"id":0,"normal":0},"vest":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":0,"albedo":0,"palette":1},"ringrh":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":2,"albedo":0,"palette":1},"shirt":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":5,"albedo":0,"palette":8},"hair":{"id":2,"color":5},"legs":174153218,"gunbelt":{"palette":0,"id":0},"beard":{"id":13,"color":5},"coatclosed":{"drawable":0,"tint2":0,"tint0":0,"tint1":0,"normal":0,"material":0,"id":0,"albedo":0,"palette":1},"eyebrows":{"id":9,"visibility":1,"opacity":1.0,"color":7}}
*/
