server_script '@rac/src/shared/shared.lua' -- Modified by Raven Anticheat
client_script '@rac/src/shared/shared.lua' -- Modified by Raven Anticheat
fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

client_scripts { 
    'client/*.lua'
 }
server_scripts {
    'server/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}