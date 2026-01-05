fx_version "adamant"
game "gta5"

author 'Potter <@potter7k>'
description 'Script GRATUITO e OPEN SOURCE desenvolvido por DK Development. Discord: https://discord.gg/NJjUn8Ad3P'
version '2.1.0'

ui_page "web/index.html"

shared_scripts {
    "shared/config.lua"
}

client_scripts {
    "@PolyZone/client.lua",
    "client/core/utils.lua",
    "client/core/ui_manager.lua",
    "client/core/control_manager.lua",
    "client/modules/blip_handler.lua",
    "client/modules/polyzone_handler.lua",
    "client/modules/sequential_handler.lua",
    "client/modules/vehicles_handler.lua",
    "client/modules/racepoint_handler.lua",
    "client/modules/marker_preview.lua",
    "client/core/coordinate_collector.lua",
    "client/main.lua"
}

server_scripts {
    "server/main.lua"
}

files {
    "web/*",
    "web/**/*"
}