------------------------------------------------------------
--                      MAIN EVENTS                       --
------------------------------------------------------------

-- CHECK RESOURCE IS READY
AddEventHandler('esx_xp:isReady', function(cb)
    cb(Ready)
end)

AddEventHandler("playerSpawned", function(spawn)
    Citizen.CreateThread(function()
        if not Ready then
            TriggerServerEvent("esx_xp:load")
        end
    end)
end)

-- INITIALISE RESOURCE
RegisterNetEvent("esx_xp:init")
AddEventHandler("esx_xp:init", function(_xp, _rank, players)

    local Ranks = CheckRanks()

    -- All ranks are valid
    if #Ranks == 0 then
        CurrentXP = tonumber(_xp)
        CurrentRank = tonumber(_rank)

        local cfg = CloneTable(Config)
        
        
        for _, v in ipairs(cfg.Ranks) do
            v.Action = nil
        end

        local data = {
            xpm_init = true,
            xpm_config = cfg,
            currentID = GetPlayerServerId(PlayerId()),
            xp = CurrentXP
        }
    
        if Config.Leaderboard.Enabled and players then
            data.leaderboard = true
            data.players = players

            for k, v in pairs(players) do
                if v.current then
                    Player = v
                end
            end        
    
            Players = players                       
        end
    
        -- Update UI
        SendNUIMessage(data)

        -- Set ESX properties
        ESX.SetPlayerData("xp", CurrentXP)
        ESX.SetPlayerData("rank", CurrentRank)
    
        -- Native stats
        StatSetInt("MPPLY_GLOBALXP", CurrentXP, 1)

        -- Resource is ready to be used
        Ready = true

        -- Trigger event
        TriggerEvent("esx_xp:ready", {
            xPlayer = ESX.GetPlayerData(),
            xp = CurrentXP,
            rank = CurrentRank
        })
    else
        TriggerEvent("esx_xp:print", _('err_lvls_check', #Ranks, 'Config.Ranks'))
        print(ESX.DumpTable(Ranks))
    end
end)

RegisterNetEvent("esx_xp:update")
AddEventHandler("esx_xp:update", function(_xp, _rank)

    local oldRank = CurrentRank
    local newRank = _rank
    local newXP = _xp

    SendNUIMessage({
        xpm_set = true,
        xp = newXP
    })

    CurrentXP = newXP
    CurrentRank = newRank

    -- Set ESX properties
    ESX.SetPlayerData("xp", CurrentXP)
    ESX.SetPlayerData("rank", CurrentRank)    
end)

if Config.Leaderboard.Enabled then
    RegisterNetEvent("esx_xp:setPlayerData")
    AddEventHandler("esx_xp:setPlayerData", function(players)

        -- Remove disconnected players
        for i=#Players,1,-1 do
            local active = PlayerIsActive(players, Players[i].id)

            if not Players[i].fake then
                if not active then
                    table.remove(Players, i)
                end
            end
        end

        -- Add new players
        for k, v in pairs(players) do
            local active = PlayerIsActive(Players, v.id)

            if not active then
                table.insert(Players, v)
            else
                Players[active] = v
            end

            if v.current then
                Player = v
            end            
        end

        -- Update leaderboard
        SendNUIMessage({
            xpm_updateleaderboard = true,
            xpm_players = Players
        })
    end)
end

-- UPDATE UI
RegisterNetEvent("esx_xp:updateUI")
AddEventHandler("esx_xp:updateUI", function(_xp)
    CurrentXP = tonumber(_xp)

    SendNUIMessage({
        xpm_set = true,
        xp = CurrentXP
    })
end)

-- SET INTITIAL XP
RegisterNetEvent("esx_xp:SetInitial")
AddEventHandler('esx_xp:SetInitial', ESXP_SetInitial)

-- ADD XP
RegisterNetEvent("esx_xp:Add")
AddEventHandler('esx_xp:Add', ESXP_Add)

-- REMOVE XP
RegisterNetEvent("esx_xp:Remove")
AddEventHandler('esx_xp:Remove', ESXP_Remove)

RegisterNetEvent("esx_xp:SetRank")
AddEventHandler('esx_xp:SetRank', ESXP_SetRank)

-- RANK CHANGE NUI CALLBACK
RegisterNUICallback('xpm_rankchange', function(data, cb)
    if data.rankUp then
        TriggerEvent("esx_xp:rankUp", data.current, data.previous)
    else
        TriggerEvent("esx_xp:rankDown", data.current, data.previous)      
    end
    
    local Rank = Config.Ranks[data.current]

    if Rank.Action ~= nil and type(Rank.Action) == "function" then
        Rank.Action(ESX.GetPlayerData(), data.rankUp, data.previous)
    end

    cb(data)
end)

-- UI CHANGE
RegisterNUICallback('xpm_uichange', function(data, cb)
    UIActive = false

    cb(data)
end)

-- Error Printing
RegisterNetEvent("esx_xp:print")
AddEventHandler("esx_xp:print", function(message)
    local s = string.rep("=", string.len(message))
    print(s)
    print(message)
    print(s)           
end)

TriggerEvent('chat:addSuggestion', '/esxp_give', _('cmd_give_desc'), {
    { name = "playerId",    help = _('cmd_playerid') },
    { name = "xp",          help = _('cmd_xp_amount') }
})

TriggerEvent('chat:addSuggestion', '/esxp_take', _('cmd_take_desc'), {
    { name = "playerId",    help = _('cmd_playerid') },
    { name = "xp",          help = _('cmd_xp_amount') }
}) 

TriggerEvent('chat:addSuggestion', '/esxp_set', _('cmd_set_desc'), {
    { name = "playerId",    help = _('cmd_playerid') },
    { name = "xp",          help = _('cmd_xp_amount') }
})

TriggerEvent('chat:addSuggestion', '/esxp_rank', _('cmd_rank_desc'), {
    { name = "playerId",    help = _('cmd_playerid') },
    { name = "rank",        help = _('cmd_rank_amount') }
}) 