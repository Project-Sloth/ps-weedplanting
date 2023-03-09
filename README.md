# Project Sloth Weed Planting 

Script provides the convenience of planting weed anywhere using both male and female seeds, along with additional features like watering, harvesting branches, drying, and packing the weed.

For all support questions, ask in our [Discord](https://www.discord.gg/projectsloth) support chat. Do not create issues if you need help. Issues are for bug reporting and new features only.

# Preview
![image](https://user-images.githubusercontent.com/82112471/221007957-34e1641e-1cc0-469a-8bf1-33315ef1bdf0.png)
![image](https://user-images.githubusercontent.com/82112471/221006801-4639fe6e-3a07-4d27-b0e1-90e1134829fd.png)
![image](https://user-images.githubusercontent.com/82112471/221007532-bd50ae14-5927-4d7e-90fb-b2c1c9b0c467.png)
![image](https://user-images.githubusercontent.com/82112471/221007532-bd50ae14-5927-4d7e-90fb-b2c1c9b0c467.png)
![image](https://user-images.githubusercontent.com/107671912/222414486-e789257e-f9f4-4152-a8d0-738be9d13fa7.png)
![image](https://user-images.githubusercontent.com/107671912/224058250-8635434c-0c16-4ff4-97bf-d3b5d9290a64.png)

# Dependencies

- [QBCore](https://github.com/qbcore-framework/qb-core)
- [oxmysql](https://github.com/overextended/oxmysql)

# Installation
* Download ZIP
* Drag and drop resource into your server files, make sure to remove -main in the folder name
* Run the attached SQL script (weedplanting.sql)
* Start resource through server.cfg
* Restart your server.

## Add to your qb-core > shared > items.lua
```lua
--- ps-weedplanting
['weedplant_seedm'] 			 = {['name'] = 'weedplant_seedm', 			    ['label'] = 'Male Weed Seed', 			['weight'] = 0, 		['type'] = 'item', 		['image'] = 'weedplant_seed.png', 		['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Male Weed Seed'},
['weedplant_seedf'] 			 = {['name'] = 'weedplant_seedf', 			    ['label'] = 'Female Weed Seed', 		['weight'] = 0, 		['type'] = 'item', 		['image'] = 'weedplant_seed.png', 		['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Female Weed Seed'},
['weedplant_branch'] 			 = {['name'] = 'weedplant_branch', 			    ['label'] = 'Weed Branch', 				['weight'] = 10000, 	['type'] = 'item', 		['image'] = 'weedplant_branch.png', 	['unique'] = true, 		['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Weed plant'},
['weedplant_weed'] 		     	 = {['name'] = 'weedplant_weed', 			    ['label'] = 'Dried Weed', 				['weight'] = 100, 		['type'] = 'item', 		['image'] = 'weedplant_weed.png', 		['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Weed ready for packaging'},
['weedplant_packedweed'] 		 = {['name'] = 'weedplant_packedweed', 			['label'] = 'Packed Weed', 				['weight'] = 100, 		['type'] = 'item', 		['image'] = 'weedplant_weed.png', 		['unique'] = true, 		['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Weed ready for sale'},
['weedplant_package'] 			 = {['name'] = 'weedplant_package', 			['label'] = 'Suspicious Package', 		['weight'] = 10000, 	['type'] = 'item', 		['image'] = 'weedplant_package.png', 	['unique'] = true, 		['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Suspicious Package'},
['plant_tub'] 			         = {['name'] = 'plant_tub', 			        ['label'] = 'Plant Tub', 		     	['weight'] = 1000, 		['type'] = 'item', 		['image'] = 'plant_tub.png', 		    ['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Pot for planting plants'},
['empty_watering_can'] 			 = {['name'] = 'empty_watering_can', 			['label'] = 'Empty Watering Can', 		['weight'] = 500, 		['type'] = 'item', 		['image'] = 'watering_can.png', 	    ['unique'] = true, 	    ['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Empty watering can'},
['full_watering_can'] 			 = {['name'] = 'full_watering_can', 			['label'] = 'Full Watering Can', 		['weight'] = 1000, 		['type'] = 'item', 		['image'] = 'watering_can.png', 	    ['unique'] = true, 	    ['useable'] = false, 	['shouldClose'] = false,	   ['combinable'] = nil,   ['description'] = 'Watering can filled with water for watering plants'},
["keya"]                         = {["name"] = "keya",                          ["label"] = "Labkey A",                 ["weight"] = 0,         ["type"] = "item",      ["image"] = "keya.png",                 ["unique"] = true,      ["useable"] = false,    ["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Labkey A.."},
```
## Weed Processing (Weed Lab)
If you want to use the script's own teleport system to go inside the weed lab then leave the `EnableTp = true` on line 24.

OR 

If you want to use qb-smallresources default teleport instead of the scripts then go to `qb-smallresource > config.lua` and add the following lines below `Config.Teleports` 
```
    --- Weedlab
    [1] = {
        [1] = {
            coords = vector4(1066.2, -3183.38, -39.16, 89.3),
            ["AllowVehicle"] = false,
            drawText = '[E] Exit Lab'
        },
        [2] = {
            coords = vector4(-66.95, -1312.37, 29.28, 180.95),
            ["AllowVehicle"] = false,
            drawText = '[E] Enter Lab'
        },

    },
```
# Credits
* [Lionh34rt](https://github.com/Lionh34rt) | Check out more scripts from Lionh34rt [here.](https://lionh34rt.tebex.io/category/1954119)
