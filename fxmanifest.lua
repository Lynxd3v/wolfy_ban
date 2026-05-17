fx_version 'cerulean'
game 'gta5'

description 'Created by Wolf'

ui_page 'html/index.html'

files {
    'ban.json',
    'html/index.html',
    'html/app.js'
}

client_scripts {'client/*.lua'}
server_scripts {'server/*.lua'}
shared_scripts {'config.lua','@es_extended/imports.lua'}

server_exports {
    'unbanPlayer',
    'banPlayer'
}

dependency {
    'es_extended'
}