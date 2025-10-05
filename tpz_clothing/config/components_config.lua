
-----------------------------------------------------------
--[[ Clothing Components ]]--
-----------------------------------------------------------

-- (!) Modify only the @label parameter, not the @category parameter.
Config.ClothingCategories = {
    { label = "Coats Closed", category = "coatclosed" },
    { label = "Coats",        category = "coat" },
    { label = "Hats",         category = "hat" },

    { label = "Eye wear",     category = "eyewear" },
    { label = "Masks",        category = "mask" },
    { label = "Neck wear",    category = "neckwear" },
    { label = "Neck Ties",    category = "neckties" },
    { label = "Shirts",       category = "shirt" },
    { label = "Suspenders",   category = "suspender" },
    { label = "Vests",        category = "vest" },
    { label = "Ponchos",      category = "poncho" },
    { label = "Cloaks",       category = "cloak" },
    { label = "Gloves",       category = "glove" },
    { label = "Belts",        category = "belt" },
    { label = "Pants",        category = "pant" },
    { label = "Boots",        category = "boots" },
    { label = "Spurs",        category = "spurs" },
    { label = "Bracelets",    category = "bracelet" },
    { label = "Belt Buckles", category = "buckle" },
    { label = "Skirts",       category = "skirt" },
    { label = "Chaps",        category = "chap" },
    { label = "Spats",        category = "spats" },
    { label = "Gun Belts Accessories", category = "gunbeltaccs" },
    { label = "Gaunlets",     category = "gauntlets" },
    { label = "Loadouts",     category = "loadouts" },
    { label = "Accessories",  category = "accessories" },
    { label = "Satchels",     category = "satchels" },
    { label = "Dresses",      category = "dress" },
    { label = "Left Holster", category = "holster" },
    { label = "Gun Belts",    category = "gunbelt" },
    { label = "Rings Right",  category = "ringrh" },
    { label = "Rings Left",   category = "ringlh" },
}

-- (!) DO NOT MODIFY
Config.ComponentCategories = {
    coatclosed      = `COATS_CLOSED`,
    coat            = `COATS`,
    hat             = `HATS`,
    eyewear         = `EYEWEAR`,
    mask            = `MASKS`,
    neckwear        = `NECKWEAR`,
    neckties        = `NECKTIES`,
    shirt           = `SHIRTS_FULL`,
    suspender       = `SUSPENDERS`,
    vest            = `VESTS`,
    poncho          = `PONCHOS`,
    cloak           = `CLOAKS`,
    glove           = `GLOVES`,
    belt            = `BELTS`,
    pant            = `PANTS`,
    boots           = `BOOTS`,
    spurs           = `BOOT_ACCESSORIES`,
    bracelet        = `JEWELRY_BRACELETS`,
    buckle          = `BELT_BUCKLES`,
    skirt           = `SKIRTS`,
    chap            = `CHAPS`,
    spats           = `SPATS`,
    gunbeltaccs     = `GUNBELT_ACCS`,
    gauntlets       = `GAUNTLETS`,
    loadouts        = `LOADOUTS`,
    accessories     = `ACCESSORIES`,
    satchels        = `SATCHELS`,
    dress           = `DRESSES`,
    holster         = `HOLSTERS_LEFT`,
    gunbelt         = `GUNBELTS`,
    ringrh          = `JEWELRY_RINGS_RIGHT`,
    ringlh          = `JEWELRY_RINGS_LEFT`,
}

-- (!) DO NOT MODIFY.
Config.clothesPalettes = {
    1090645383, 1064202495, -783849117, 864404955, 1669565057, -1952348042
}

-- The cost for buying outfit components is always on CASH.
-- (!) The names must be the same as it is from @Config.Categories.
Config.OutfitCosts = {
    ['gunbelt']             = 2,
    ['mask']                = 2,
    ['holster']             = 2,
    ['loadouts']            = 5,
    ['coat']                = 3,
    ['cloak']               = 3,
    ['eyewear']             = 0.50,
    ['bracelet']            = 0.35,
    ['skirt']               = 3,
    ['poncho']              = 3,
    ['spats']               = 3,
    ['neckties']            = 0.50,
    ['pant']                = 3,
    ['suspender']           = 1,
    ['glove']               = 1,
    ['satchels']            = 3,
    ['gunbeltaccs']         = 3,
    ['coatclosed']          = 5,
    ['buckle']              = 0.30,
    ['ringrh']              = 0.20,
    ['belt']                = 1,
    ['accessories']         = 2,
    ['shirt']               = 3,
    ['gauntlets']           = 1,
    ['chap']                = 3,
    ['neckwear']            = 0.50,
    ['boots']               = 2,
    ['spurs']               = 1,
    ['vest']                = 3,
    ['ringlh']              = 0.20,
    ['hat']                 = 1,
    ['dress']               = 5,
}
