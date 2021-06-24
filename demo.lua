------------------------------------------------------------
--                        COMMANDS                        --
------------------------------------------------------------

TriggerEvent('chat:addSuggestion', '/ESXP_AddFakePlayer', 'Adds a fake player to the leaderboard') 
TriggerEvent('chat:addSuggestion', '/ESXP_SetInitial', 'Sets player initial XP', {
    { name="XP", help="The XP to set" },
}) 
TriggerEvent('chat:addSuggestion', '/ESXP_Add', 'Add XP', {
    { name="XP", help="The XP to add" },
}) 
TriggerEvent('chat:addSuggestion', '/ESXP_Remove', 'Remove XP', {
    { name="XP", help="The XP to remove" },
}) 

-- !!!!!! THESE ARE FOR TESTING PURPOSES AND WILL NOT SAVE THE CHANGES IN THE DB !!!!!! --
RegisterCommand('ESXP_SetInitial', function(source, args)
    if IsInt(args[1]) then
        CurrentXP = LimitXP(tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        })   
    else
        print("esx_xp: Invalid XP") 
    end       
end)

RegisterCommand('ESXP_Add', function(source, args)
    if IsInt(args[1]) then
        CurrentXP = LimitXP(CurrentXP + tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        }) 
    else
        print("esx_xp: Invalid XP") 
    end  
end)

RegisterCommand('ESXP_Remove', function(source, args)
    if IsInt(args[1]) then    
        CurrentXP = LimitXP(CurrentXP - tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        }) 
    else
        print("esx_xp: Invalid XP") 
    end     
end)

RegisterCommand('ESXP_AddFakePlayer', function(source, args)
    local count = 1
    if args[1] ~= nil and tonumber(args[1]) then
        count = tonumber(args[1])
    end

    math.randomseed(GetGameTimer())
    for i = 1, count do
        AddFakePlayer()
    end    

    TriggerServerEvent("esx_xp:getPlayerData")
    SendNUIMessage({
        xpm_show = true,
        xbm_lb = Config.Leaderboard
    })

    ESX.ShowNotification("~b~ESX_XP: ~g~" .. count .. " ~w~players added")      
end)

RegisterCommand('ESXP_RemoveFakePlayers', function(source, args)
    for i=#Players,1,-1 do
        if Players[i].fake ~= nil then
            table.remove(Players, i)
        end
    end

    ESX.ShowNotification("~b~ESX_XP: ~w~Fake players removed")    

    TriggerServerEvent("esx_xp:getPlayerData")
    SendNUIMessage({
        xpm_show = true,
        xbm_lb = Config.Leaderboard
    })
end)

RegisterCommand('ESXP_SortLeaderboard', function(source, args)
    local order = args[1] or "rank"

    ESXP_SortLeaderboard(order)

    TriggerServerEvent("esx_xp:getPlayerData")
    SendNUIMessage({
        xpm_show = true,
        xbm_lb = Config.Leaderboard
    })    

    ESX.ShowNotification("~b~ESX_XP: ~w~Leaderboard ordered by ~g~" .. order)    
end)

function AddFakePlayer()
    function maxVal(t, fn)
        local max = 0
        for k, v in pairs(Players) do
            local id = tonumber(v.id)
            if id > max then
                max = id
            end
        end
        return max
    end

    local names = {
        "xxvctdreemaxxto",
        "estropevc",
        "bruscavi5a",
        "fretaretzgl",
        "tenshii58",
        "afamatt9",
        "motriuo1",
        "kittykatrox13cj",
        "meastalfs",
        "tisleiferxl",
        "persephone33ql",
        "herbianinvu",
        "lapic4r",
        "rubia1044rp",
        "dzieciaryd9",
        "Lactabikito12",
        "trappunumu7",
        "Dallioes",
        "apanyava43",
        "hcoloverrrrx33x",
        "kastplankif",
        "Foramitibp",
        "Rail45",
        "dargludajm",
        "Condoloqo",
        "hestvagn3g",
        "Aidelmimaip",
        "Stehanjkgr",
        "daycapaniwebs05",
        "polars87",
        "nickbitemekt",
        "hovedlegeb0",
        "peoplesuck076l",
        "Laisvisli",
        "drargewabwz",
        "Cocconiz0",
        "BypeSkebykj",
        "neerdaalcc",
        "kennirh7",
        "kuhwelela50",
        "Honshubv",
        "Mungarilz",
        "aphangejy",
        "Fiananese93",
        "Mushungtq",
        "lorci1",
        "rongalitnm",
        "engusardet9",
        "bauginojj",
        "sonsonatzk0"
    }

    local name  = names[ math.random( #names ) ]
    local rank  = math.random(1, 100)
    local id    = maxVal() + 1
    local ping  = false
    
    if Config.Leaderboard.ShowPing then
        ping  = math.random(0, 100)
    end
    
    table.insert(Players, {
        name = name,
        id = id,
        ping = ping,
        rank = rank,
        fake = true
    })
end