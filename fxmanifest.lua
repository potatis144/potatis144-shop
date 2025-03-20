fx_version "cerulean"
game "gta5"

lua54 "yes"
use_experimental_fxv2_oal "yes"

author "Potatis144"
description "edited version of Cloud-Shop. Original: https://github.com/yiruzu"
version "1.0.0"

discord "https://discord.gg/jAnEnyGBef" -- original discord not for the forked version forked verison dose not give support
repository "https://github.com/potatis144/potatis144-shop"
license "CC BY-NC"

files { "shared/sh_config.lua", "shared/sh_locales.lua" }
shared_scripts { "@ox_lib/init.lua", "shared/sh_functions.lua" }
server_scripts { "bridge/server/*.lua", "server/*.lua" }
client_scripts { "client/*.lua" }

ui_page { "web/dist/index.html" }
files { "web/dist/**/*" }
