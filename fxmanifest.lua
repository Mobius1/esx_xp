fx_version 'adamant'

game 'gta5'

description 'XP Ranking System'

author 'Karl Saunders'

version '1.2.3'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'ranks.lua',
    'utils.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'ranks.lua',
    'utils.lua',
    'client/main.lua',
    'client/functions.lua',    
    'client/events.lua',
    'demo.lua', -- remove if not required
}

dependencies {
    'es_extended',
}

ui_page 'ui/ui.html'

files {
    'ui/ui.html',
    'ui/fonts/ChaletComprimeCologneSixty.ttf',
    'ui/css/app.css',
    'ui/js/class.xpm.js',
    'ui/js/class.paginator.js',
    'ui/js/class.leaderboard.js',
    'ui/js/app.js'
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
export 'ESXP_TimeoutUI'
export 'ESXP_SortLeaderboard'