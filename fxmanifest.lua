fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version '1.6'
description 'Project Sloth Weedplanting script'
author 'Lionh34rt'

shared_scripts {
    'shared/sh_shared.lua',
    'shared/locales.lua',
}

client_scripts{
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    'client/cl_planting.lua',
    'client/cl_processing.lua',
    'client/cl_weedrun.lua'
} 
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_planting.lua',
    'server/sv_processing.lua',
    'server/sv_weedrun.lua'
}

dependencies {
    'PolyZone',
	'qb-target'
}
