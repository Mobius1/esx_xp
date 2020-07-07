fx_version 'adamant'

game 'gta5'

description 'XP Ranking System'

author 'Karl Saunders'

version '0.3.0'

server_scripts {
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'utils.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'utils.lua',
    'client/main.lua'
}

dependencies {
    'es_extended',
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/fonts/ChaletComprimeCologneSixty.ttf',
    'html/css/app.css',
    'html/js/class.xp.js',
    'html/js/app.js'
}

export 'ESXP_SetInitial'
export 'ESXP_Add'
export 'ESXP_Remove'
export 'ESXP_GetXP'
export 'ESXP_GetRank'
export 'ESXP_GetXPToNextRank'
export 'ESXP_GetXPToRank'
export 'ESXP_GetMaxXP'
export 'ESXP_GetMaxRank'
