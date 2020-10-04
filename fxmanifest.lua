fx_version 'adamant'

game 'gta5'

description 'XP Ranking System'

author 'Karl Saunders'

version '1.0.1'

server_scripts {
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
    'client/main.lua',
    'demo.lua', -- remove if not required
}

dependencies {
    'es_extended',
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/fonts/ChaletComprimeCologneSixty.ttf',
    'html/css/app.css',
    'html/js/class.xpm.js',
    'html/js/class.leaderboard.js',
    'html/js/app.js'
}

export 'ESXP_SetInitial'
export 'ESXP_Add'
export 'ESXP_Remove'
export 'ESXP_SetRank'

export 'ESXP_GetXP'
export 'ESXP_GetRank'
export 'ESXP_GetXPToNextRank'
export 'ESXP_GetXPToRank'
export 'ESXP_GetMaxXP'
export 'ESXP_GetMaxRank'
export 'ESXP_ShowUI'
export 'ESXP_HideUI'