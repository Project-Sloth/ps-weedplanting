# Weed Planting 

For all support questions, ask in our Discord support chat. Do not create issues if you need help. Issues are for bug reporting and new features only.

 https://www.discord.gg/projectsloth

## Dependencies

- [QBCore](https://github.com/qbcore-framework/qb-core)
- [Ox MySQL](https://github.com/overextended/oxmysql)

# Installation
* Download ZIP
* Drag and drop resource into your server files, make sure to remove -main in the folder name
* Run the attached SQL script (weedplanting.sql)
* Start resource through server.cfg
* Restart your server.

## Add to your qb-core > shared > items.lua
```lua
['weedplant_seedm'] 			 = {['name'] = 'weedplant_seedm', 			    ['label'] = 'Male Weed Seed', 			['weight'] = 0, 		['type'] = 'item', 		['image'] = 'weedplant_seed.png', 		['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Male Weed Seed'},
['weedplant_seedf'] 			 = {['name'] = 'weedplant_seedf', 			    ['label'] = 'Female Weed Seed', 		['weight'] = 0, 		['type'] = 'item', 		['image'] = 'weedplant_seed.png', 		['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Female Weed Seed'},
['weedplant_branch'] 			 = {['name'] = 'weedplant_branch', 			    ['label'] = 'Female Weed Seed', 		['weight'] = 2000, 		['type'] = 'item', 		['image'] = 'weedplant_branch.png', 	['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Weed plant'},
['weedplant_weed'] 				 = {['name'] = 'weedplant_weed', 			    ['label'] = 'Weed 1oz', 				['weight'] = 100, 		['type'] = 'item', 		['image'] = 'weedplant_weed.png', 		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Bag of weed'},
```