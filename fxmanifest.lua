fx_version 'cerulean'
game 'gta5'

author 'Votre Nom'
description 'Système de prison pour FiveM'
version '1.0.0'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server.lua',
    'helper.lua' -- Script pour afficher vos identifiants avec /myid
}

client_scripts {
    'client.lua'
}

ui_page 'html/notifications.html'

files {
    'html/notifications.html'
}
