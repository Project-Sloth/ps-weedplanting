# Project Sloth Weed Planting 

Script provides the convenience of planting weed anywhere using both male and female seeds, along with additional features like watering, harvesting branches, drying, and packing the weed.

For all support questions, ask in our [Discord](https://www.discord.gg/projectsloth) support chat. Do not create issues if you need help. Issues are for bug reporting and new features only.

# Preview
![image](https://user-images.githubusercontent.com/82112471/221007957-34e1641e-1cc0-469a-8bf1-33315ef1bdf0.png)
![image](https://user-images.githubusercontent.com/82112471/221006801-4639fe6e-3a07-4d27-b0e1-90e1134829fd.png)
![image](https://user-images.githubusercontent.com/82112471/221007532-bd50ae14-5927-4d7e-90fb-b2c1c9b0c467.png)

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
['weedplant_seedm'] 			 = {['name'] = 'weedplant_seedm', 			    ['label'] = 'Male Weed Seed', 			['weight'] = 0, 		['type'] = 'item', 		['image'] = 'weedplant_seed.png', 		['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Male Weed Seed'},
['weedplant_seedf'] 			 = {['name'] = 'weedplant_seedf', 			    ['label'] = 'Female Weed Seed', 		['weight'] = 0, 		['type'] = 'item', 		['image'] = 'weedplant_seed.png', 		['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Female Weed Seed'},
['weedplant_branch'] 			 = {['name'] = 'weedplant_branch', 			    ['label'] = 'Weed Branch', 				['weight'] = 10000, 	['type'] = 'item', 		['image'] = 'weedplant_branch.png', 	['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Weed plant'},
['weedplant_weed'] 				 = {['name'] = 'weedplant_weed', 			    ['label'] = 'Dried Weed', 				['weight'] = 100, 		['type'] = 'item', 		['image'] = 'weedplant_weed.png', 		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Weed ready for packaging'},
['weedplant_packedweed'] 		 = {['name'] = 'weedplant_packedweed', 			['label'] = 'Packed Weed', 				['weight'] = 100, 		['type'] = 'item', 		['image'] = 'weedplant_weed.png', 		['unique'] = true, 		['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Weed ready for sale'},
['weedplant_package'] 			 = {['name'] = 'weedplant_package', 			['label'] = 'Suspicious Package', 		['weight'] = 10000, 	['type'] = 'item', 		['image'] = 'weedplant_package.png', 	['unique'] = true, 		['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Suspicious Package'},
```
# Credits
* [Lionh34rt](https://github.com/Lionh34rt) | Check out more scripts from Lionh34rt [here.](https://lionh34rt.tebex.io/category/1954119)
