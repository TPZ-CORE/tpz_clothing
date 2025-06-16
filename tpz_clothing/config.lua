Config = {}

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
    ['OPEN_STORE']    = {label = 'Press',  key = 'SPACEBAR' },
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

-----------------------------------------------------------
--[[ Clothing Store Locations ]]--
-----------------------------------------------------------

Config.Stores = {

    { -- Saint Denis ( CLOTHING )

        Coords = {x = 2555.755, y = -1170.66, z = 53.683, h = 78.336357116699},

        CameraCoords = { x = 2552.937, y = -1169.39, z = 54.0, h = 231.269088745, roty = 0.0, rotz = 245.0, fov = 60.0, zoom = 68.0},
        
        BlipData = {
            Enabled = true,
            Title   = "Clothing Store",
            Sprite  = 1195729388,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
        },

        ActionDistance = 0.8,

        ActionType = "CLOTHING",
        
    },

    { -- Saint Denis ( MAKEUP )

        Coords = {x = 2548.435, y = -1158.50, z = 53.726, h = 262.8038024902},

        CameraCoords = { x = 2551.079, y = -1160.82, z = 54.124, h = 52.4939613342, roty = 0.0, rotz = 50.0, fov = 60.0, zoom = 68.0},
        
        BlipData = {
            Enabled = true,
            Title   = "Makeup Store",
            Sprite  = 1451797164,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
        },

        ActionDistance = 0.6,

        ActionType = "MAKEUP",
    },

    { -- Blackwater ( CLOTHING )

        Coords = {x = -759.990, y = -1294.08, z = 43.835, h = 104.9513473510},

        CameraCoords = { x = -762.637, y = -1293.84, z = 44.2, h = 253.674316406, roty = 0.0, rotz = 255.0, fov = 60.0, zoom = 68.0},
        
        BlipData = {
            Enabled = true,
            Title   = "Clothing Store",
            Sprite  = 1195729388,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
        },

        ActionDistance = 0.8,

        ActionType = "CLOTHING",
    },

}

-----------------------------------------------------------
--[[ Default Wardrobe Locations ]]--
-----------------------------------------------------------

Config.Wardrobes = {

    ['Valentine'] = {

        Coords = {x = -325.114, y = 766.4060, z = 117.43, h = 12.5232944488},

        BlipData = {
            Enabled = true,
            Title   = "Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
        },

        ActionDistance = 1.2,
    },

    ['Rhodes'] = {

        Coords = {x = 1323.890, y = -1288.67, z = 77.021, h = 0},

        BlipData = {
            Enabled = true,
            Title   = "Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
        },

        ActionDistance = 1.2,
    },

    ['SaintDenis'] = {

        Coords = {x = 2555.864, y = -1160.55, z = 53.701, h = 181.045257568},

        BlipData = {
            Enabled = true,
            Title   = "Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
        },

        ActionDistance = 1.2,
    },

    ['Blackwater'] = {

        Coords = {x = -767.94,y = -1294.95,z = 43.84, h = 0},

        BlipData = {
            Enabled = true,
            Title   = "Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
        },

        ActionDistance = 1.2,
    },

    ['Strawberry'] = {

        Coords = {x = -1794.00, y = -394.872, z = 160.33},

        BlipData = {
            Enabled = true,
            Title   = "Wardrobe",
            Sprite  = 1496995379,
        },

        ActionMarkers = {
            Enabled = true,

            Distance = 10.0,
            RGBA = {r = 240, g = 230, b = 140, a = 255},
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