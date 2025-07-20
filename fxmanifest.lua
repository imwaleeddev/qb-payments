fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'qb-payments'
author 'im.waleed, 1iuae'
description 'qb-payments Menu With UI <3'

shared_script { 'config.lua', '@ox_lib/init.lua', }
client_script { 'client/cl_*.lua', }
server_script { 'server/sv_*.lua', }

ui_page { 'html/index.html' }

files { 'html/**', }

dependency { 'ox_lib', }

-- .gg/slax