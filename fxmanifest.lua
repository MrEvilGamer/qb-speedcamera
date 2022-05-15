fx_version 'cerulean'
game 'gta5'

description 'QBCore Speedcamera'

version '0.0.1'

shared_scripts {
  'config.lua'
}

server_scripts {
  'server/main.lua'
}

client_scripts {
  'client/main.lua'
}

ui_page('html/index.html')

files {
    'html/index.html'
}

lua54 'yes'