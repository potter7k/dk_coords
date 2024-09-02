fx_version "adamant"
game "gta5"

author 'Potter <@potter7k>'
description 'Script GRATUITO e OPEN SOURCE desenvolvido por DK Development. Discord: https://discord.gg/NJjUn8Ad3P'
version '1.0.0'

ui_page "web/index.html"
 
client_scripts {
	"@PolyZone/client.lua",
	"client/**/*"
}

server_scripts {
	"server/*"
}

files {
	"web/*",
	"web/**/*"
}