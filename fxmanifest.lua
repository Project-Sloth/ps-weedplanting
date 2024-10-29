fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

version '2.0'
description 'Weedplanting Script for FiveM'
author 'Lionh34rt'

dependencies {
    'ox_lib',
    'oxmysql'
}

files {
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/locales.lua',
}

client_scripts{
    'bridge/**/client.lua',
    'utils/client.lua',
    'client/cl_planting.lua',
    'client/cl_processing.lua',
    'client/cl_weedrun.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/**/server.lua',
    'utils/server.lua',
    'server/sv_setup.lua',
    'server/sv_planting.lua',
    'server/sv_processing.lua',
    'server/sv_weedrun.lua'
}
