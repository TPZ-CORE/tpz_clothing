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
| exports.tpz_clothing:isBusy() | This returns a boolean (true - false) if any menu is active.     |

## Screenshots

<img width="2559" height="1307" alt="image" src="https://github.com/user-attachments/assets/f99943c7-fb44-4e95-88c3-4b8e6937ac06" />
<img width="2558" height="1310" alt="image" src="https://github.com/user-attachments/assets/a1324728-b8b8-4d68-8482-9a800d66c68f" />
<img width="2559" height="1314" alt="image" src="https://github.com/user-attachments/assets/e8424cca-e001-4571-a8e1-458f5b8c85ea" />
<img width="2559" height="1311" alt="image" src="https://github.com/user-attachments/assets/b36c6451-0ee4-4bbf-87ea-ac8712cc3ed1" />
<img width="2559" height="1305" alt="image" src="https://github.com/user-attachments/assets/103956a9-3016-4544-849e-ab96123f23aa" />
<img width="620" height="762" alt="image" src="https://github.com/user-attachments/assets/c0ec8c8e-fb0d-420b-a6d6-ab3483d3e7df" />
<img width="654" height="723" alt="image" src="https://github.com/user-attachments/assets/f488941f-dbf5-42c6-ae8d-d6c2022a7e0e" />
