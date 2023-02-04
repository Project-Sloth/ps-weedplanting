fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version '1.0'
description 'Project Sloth Weedplanting script'
author 'Lionh34rt'

shared_scripts {
    'shared/sh_shared.lua',
    'shared/locales.lua',
}

client_scripts{
    'client/cl_main.lua',
    'client/cl_utils.lua',
    'client/cl_planting.lua'
} 
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
    'server/sv_planting.lua'
}

dependencies {
	'qb-target'
}
