Config = {}

Config.DevMode = false
Config.Debug   = false

Config.Keys = { 
    ["A"] = 0x7065027D, ["D"] = 0xB4E465B4, ['R'] = 0xE30CD707, ['G'] = 0x760A9C6F, ["ENTER"] = 0xC7B5340A, 
    ["SPACEBAR"] = 0xD9D0E1C0, ['BACKSPACE'] = 0x156F7119, ["W"] = 0x8FD015D8, ["S"] = 0xD27782E3,
    ["CursorScrollDown"] = 0x8BDE7443, ["CursorScrollUp"] = 0x62800C92, ["X"] = 0x8CC9CD42,
}

-----------------------------------------------------------
--[[ General Settings  ]]--
-----------------------------------------------------------

-- (!) You can't have the same key in multiple prompts but must be used only once.
Config.Prompts = {
    ['OPEN_STORE']    = {label = 'Press',  key = 'G' },
    ['OPEN_WARDROBE'] = {label = 'Press',  key = 'G' },
}

Config.CameraAdjustmentPrompts = {
    ['CHARACTER_ADJUSTMENT_LEFT_AND_RIGHT']       = {label = "LEFT & RIGHT ROTATIONS",                key1 = 'A', key2 = 'D'}, -- Do not touch.
    ['CHARACTER_ADJUSTMENT_UP_AND_DOWN']          = {label = "UP & DOWN CAMERA ADJUSTMENTS",          key1 = 'W', key2 = 'S'}, -- Do not touch.
    ['CHARACTER_ADJUSTMENT_ZOOM_IN_AND_ZOOM_OUT'] = {label = "ZOOM IN & ZOOM OUT CAMERA ADJUSTMENTS", key1 = 'CursorScrollUp', key2 = 'CursorScrollDown'}, -- Do not touch.
    ['CHARACTER_ADJUSTMENT_HANDS_UP']             = {label = "HANDS UP",                              key1 = 'X', key2 = nil}, -- Do not touch.
}

Config.HandsUpAnimation = {
    Dict = "script_proc@robberies@shop@rhodes@gunsmith@inside_upstairs",
    Body = "handsup_register_owner",
}

Config.OpenWardrobeOutfitsEvent = "tpz_clothing:client:openWardrobeOutfits"

Config.WardrobeMenuAlign = 'left'

-----------------------------------------------------------
--[[ Clothing Store Locations ]]--
-----------------------------------------------------------

Config.Stores = {
    
    ["SAINT_DENIS"] = {

        Title = 'Clothing Store',

        -- The store coords - also for teleporting the player for the proper location.
        Coords = {x = 2555.755, y = -1170.66, z = 53.683, h = 78.336357116699},

        TeleportCoords = { x = 2799.624, y = -1169.67, z = 46.928, h = 248.2420959 }, -- set to false to disable (requires table form as Coords)
        TeleportCoordsOnExit = {x = 2555.755, y = -1170.66, z = 53.683, h = 78.336357116699}, -- set to false to disable (requires table form as Coords }
        Instance = true, -- this must be true if player is on a specific room with others (like a characters room)

        CameraCoords = { x = 2800.740, y = -1170.24, z = 48.228, h = 59.94042587, roty = 0.0, rotz = 60.0, fov = 60.0, zoom = 70.0},

        BlipData = {
            Enabled = true,
            Title   = "Clothing Store",
            Sprite  = 1195729388,

            OpenBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            DisplayClosedHours = { Enabled = true, Sprite = 1195729388, BlipModifier = "BLIP_MODIFIER_MP_COLOR_2" },
        },

        Hours = { Allowed = true, Opening = 7, Closing = 23 },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 255, g = 255, b = 255, a = 55},
            Coords = {x = 2555.755, y = -1170.66, z = 53.683, h = 78.336357116699},
        },

        Lighting = {
            Coords = vector3(2800.194, -1170.01, 47.928),
            RGB    = {R = 255, G = 255, B = 255 },
            Range  = 5.0,
            Intensity = 500.0,
        },

        ActionDistance = 1.2,
        
    },
    
    ["BLACKWATER"] = { 

        Title = 'Clothing Store',

        -- The store coords - also for teleporting the player for the proper location.
        Coords = {x = -759.990, y = -1294.08, z = 43.835, h = 104.9513473510},

        TeleportCoords = { x = 2799.624, y = -1169.67, z = 46.928, h = 248.2420959 }, -- set to false to disable (requires table form as Coords)
        TeleportCoordsOnExit = {x = -759.990, y = -1294.08, z = 43.835, h = 104.9513473510}, -- set to false to disable (requires table form as Coords }
        Instance = true, -- this must be true if player is on a specific room with others (like a characters room)
        
        CameraCoords = { x = -762.637, y = -1293.84, z = 44.2, h = 253.674316406, roty = 0.0, rotz = 255.0, fov = 60.0, zoom = 68.0},
                
        BlipData = {
            Enabled = true,
            Title   = "Clothing Store",
            Sprite  = 1195729388,

            OpenBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            DisplayClosedHours = { Enabled = true, Sprite = 1195729388, BlipModifier = "BLIP_MODIFIER_MP_COLOR_2" },
        },

        Hours = { Allowed = true, Opening = 7, Closing = 23 },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 255, g = 255, b = 255, a = 55},
            Coords = {x = -759.990, y = -1294.08, z = 43.835, h = 104.9513473510},
        },

        Lighting = {
            Coords = vector3(2800.194, -1170.01, 47.928),
            RGB    = {R = 255, G = 255, B = 255 },
            Range  = 5.0,
            Intensity = 500.0,
        },

        ActionDistance = 1.2,
    },

}

-----------------------------------------------------------
--[[ Default Wardrobe Locations ]]--
-----------------------------------------------------------

-- Public wardrobe locations that can be found on the world map. 
Config.Wardrobes = {

    ['RHODES'] = {

        Coords = {x = 1323.890, y = -1288.67, z = 77.021, h = 0},

        BlipData = {
            Enabled = true,
            Title   = "Public Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 5.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
            Coords = {x = 1323.890, y = -1288.67, z = 77.021, h = 0},

        },

        ActionDistance = 1.2,
    },

    ['SAINT_DENIS'] = {

        Coords = {x = 2555.864, y = -1160.55, z = 53.701, h = 181.045257568},

        BlipData = {
            Enabled = true,
            Title   = "Public Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 5.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
            Coords = {x = 2555.864, y = -1160.55, z = 53.701, h = 181.045257568},
        },

        ActionDistance = 1.2,
    },

    ['BLACKWATER'] = {

        Coords = {x = -767.94,y = -1294.95,z = 43.84, h = 0},

        BlipData = {
            Enabled = true,
            Title   = "Public Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 5.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
            Coords = {x = -767.94,y = -1294.95,z = 43.84, h = 0},
        },

        ActionDistance = 1.2,
    },

    ['STRAWBERRY'] = {

        Coords = {x = -1794.00, y = -394.872, z = 160.33},

        BlipData = {
            Enabled = true,
            Title   = "Public Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 5.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
            Coords = {x = -1794.00, y = -394.872, z = 160.33},
        },

        ActionDistance = 1.2,
    },

}

-----------------------------------------------------------
--[[ Notification Functions  ]]--
-----------------------------------------------------------

-- @param source : The source always null when called from client.
-- @param type   : returns "error", "success", "info"
-- @param duration : the notification duration in milliseconds
function SendNotification(source, message, type, duration)

	if not duration then
		duration = 3000
	end

    if not source then
        TriggerEvent('tpz_core:sendBottomTipNotification', message, duration)
    else
        TriggerClientEvent('tpz_core:sendBottomTipNotification', source, message, duration)
    end
  
end
