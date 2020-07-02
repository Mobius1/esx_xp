fx_version 'adamant'

game 'gta5'

description 'XP Leveling System'

author 'Karl Saunders'

version '0.1.0'

server_scripts {
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
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

export 'XP_SetInitial'
export 'XP_Add'
export 'XP_Remove'
export 'XP_GetXP'
export 'XP_GetLevel'
export 'XP_GetXPToNextLevel'
export 'XP_GetXPToLevel'
export 'XP_GetMaxXP'
export 'XP_GetMaxLevel'
