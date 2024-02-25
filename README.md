# TPZ-CORE Clothing

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
4. TPZ-Menu Base: https://github.com/TPZ-CORE/tpz_menu_base

# Installation

1. When opening the zip file, open `tpz_clothing-main` directory folder and inside there will be another directory folder which is called as `tpz_clothing`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_clothing` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.

# Development


### The following event is opening the personal players wardrobe

```lua
TriggerEvent("tpz_clothing:openWardrobe") -- Client Side
TriggerClientEvent("tpz_clothing:openWardrobe", source) -- Server Side
```

### There is also an export that can be used Client Side only.

```lua
exports.tpz_clothing:openWardrobe()
```
