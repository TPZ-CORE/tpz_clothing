# TPZ-CORE Clothing

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
4. TPZ-Menu Base: https://github.com/TPZ-CORE/tpz_menu_base

# Installation

1. When opening the zip file, open `tpz_clothing-main` directory folder and inside there will be another directory folder which is called as `tpz_clothing`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_clothing` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.

## Development

### Events 

```lua
TriggerEvent("tpz_clothing:client:openWardrobeOutfits") -- Client - Client
TriggerClientEvent("tpz_clothing:client:openWardrobeOutfits", source) -- Server > Client
```

- The specified event name can be modified through the configuration file. 

### Exports

| Exports                              | Description                                                  |
|--------------------------------------|--------------------------------------------------------------|
| exports.tpz_clothing:openWardrobe()  | By executing, it will open the player wardrobe outfits menu. | 
| exports.tpz_clothing:hasMenuActive() | This returns a boolean (true - false) if menu is active.     |