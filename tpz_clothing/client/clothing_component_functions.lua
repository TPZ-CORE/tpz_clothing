
local WardrobePrompts, StoreLocationPrompts, StorePrompts = GetRandomIntInRange(0, 0xffffff), GetRandomIntInRange(0, 0xffffff), GetRandomIntInRange(0, 0xffffff)
local WardrobePromptsList, StoreLocationPromptsList, StorePromptsList = {}, {}, {}

local metaPedCategoryTags = {
    Tags = {
        [`accessories`]         = "Accessories",
        [`ammo_pistols`]        = "ammo_pistols",
        [`ammo_rifles`]         = "ammo_rifles",
        [`ankle_bindings`]      = "ankle_bindings",
        [`aprons`]              = "aprons",
        [`armor`]               = "Armor",
        [`badges`]              = "Badge",
        [`beards_chin`]         = "beards_chin",
        [`beards_chops`]        = "beards_chops",
        [`beards_complete`]     = "beards_complete",
        [`beards_mustache`]     = "beards_mustache",
        [`belts`]               = "Belts",
        [`belt_buckles`]        = "Buckle",
        [`bodies_lower`]        = "Boots",
        [`bodies_upper`]        = "bodies_upper",
        [`boots`]               = "boots",
        [`boot_accessories`]    = "Spurs",
        [`chaps`]               = "Chap",
        [`cloaks`]              = "Cloak",
        [`coats`]               = "Coat",
        [`coats_closed`]        = "CoatClosed",
        [`coats_heavy`]         = "coats_heavy",
        [`dresses`]             = "Dress",
        [`eyebrows`]            = "eyebrows",
        [`eyes`]                = "eyes",
        [`eyewear`]             = "EyeWear",
        [`gauntlets`]           = "Gauntlets",
        [`gloves`]              = "Glove",
        [`gunbelt_accs`]        = "GunbeltAccs",
        [`gunbelts`]            = "Gunbelt",
        [`hair`]                = "hair",
        [`hair_accessories`]    = "hair_accessories",
        [`hats`]                = "Hat",
        [`heads`]               = "heads",
        [`holsters_crossdraw`]  = "holsters_crossdraw",
        [`holsters_knife`]      = "holsters_knife",
        [`holsters_left`]       = "Holster",
        [`holsters_right`]      = "holsters_right",
        [`jewelry_bracelets`]   = "Vracelet",
        [`jewelry_rings_left`]  = "RingLh",
        [`jewelry_rings_right`] = "RingRh",
        [`loadouts`]            = "Loadouts",
        [`masks`]               = "Mask",
        [`masks_large`]         = "masks_large",
        [`neckties`]            = "NeckTies",
        [`neckwear`]            = "NeckWear",
        [`outfits`]             = "outfits",
        [`pants`]               = "Pant",
        [`ponchos`]             = "Poncho",
        [`satchels`]            = "Satchels",
        [`shirts_full`]         = "Shirt",
        [`skirts`]              = "Skirt",
        [`spats`]               = "Spats",
        [`suspenders`]          = "Suspenders",
        [`teeth`]               = "teeth",
        [`vests`]               = "Vest",
        [`wrist_bindings`]      = "wrist_bindings",
    },
}

--[[-------------------------------------------------------
 General
]]---------------------------------------------------------

local function SetTextureOutfitTints(ped, category, data)
    local palette = Config.clothesPalettes[data.palette]
    Citizen.InvokeNative(0x4EFC1F8FF1AD94DE, ped, joaat(category), palette, data.tint0, data.tint1, data.tint2)
end

function FixCategoryClothingProperly(category, skinData, ped)
    local entityPed = ped or PlayerPedId()
    local PlayerSkin

    if skinData then 
        PlayerSkin = skinData
    else 
        PlayerSkin = GetPlayerSkinData()
    end

    local modules = exports.tpz_core:getCoreAPI().modules()

    Wait(100)

    modules.IsPedReadyToRender()

    if category == "gunbelt" then
        --toggleComp(Config.ComponentCategories.Holster, CachedComponents.Holster, key)
    end

    if category == "vest" and IsMetaPedUsingComponent(entityPed, Config.ComponentCategories.shirt) then
        local item = PlayerSkin.shirt
        if item and item.drawable ~= 0 then
            SetTextureOutfitTints(entityPed, 'shirts_full', item)
        end
    end

    if category == 'shirt' and IsMetaPedUsingComponent(entityPed, Config.ComponentCategories.vest) then
        local item = PlayerSkin.vest
        if item and item.drawable ~= 0 then
            SetTextureOutfitTints(entityPed, 'vests', item)
        end
    end

    if category == "coat" or category == 'coatclosed' then

        if IsMetaPedUsingComponent(entityPed, Config.ComponentCategories.vest) then
            local item = PlayerSkin.vest
            if item and item.drawable ~= 0 then
                SetTextureOutfitTints(entityPed, 'vests', item)
            end
        end

        if IsMetaPedUsingComponent(entityPed, Config.ComponentCategories.shirt) then
            local item = PlayerSkin.shirt
            if item and item.drawable ~= 0 then
                SetTextureOutfitTints(entityPed, 'shirts_full', item)
            end
        end

    end

    if category == "boots" then
        if IsMetaPedUsingComponent(entityPed, Config.ComponentCategories.boots) then
            local item = PlayerSkin.boots

            if item and item.drawable ~= 0 then
                SetTextureOutfitTints(entityPed, 'boots', item)
            end

        end

        if IsMetaPedUsingComponent(entityPed, Config.ComponentCategories.pant) then

            local item = PlayerSkin.pant

            if item and item.drawable ~= 0 then
                SetTextureOutfitTints(entityPed, 'pants', item)
            end

        end
    end

    if category == "pant" then 

        UpdateShopItemWearableState(Config.ComponentCategories[category], `base`) -- -2081918609
        modules.UpdatePedVariation(entityPed)

        local item = PlayerSkin.Shirt -- some pants breaking the shirt colors
        if item and item.drawable ~= 0 then
            SetTextureOutfitTints(entityPed, 'shirts_full', item)
        end

    end

end