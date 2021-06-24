CurrentXP = 0
CurrentRank = 0
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent("esx_xp:load")
AddEventHandler("esx_xp:load", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            if #result > 0 then

                if result[1]["rp_xp"] == nil or result[1]["rp_rank"] == nil then
                    TriggerClientEvent("esx_xp:print", _source, _("err_db_columns"))
                else
                    CurrentXP = tonumber(result[1]["rp_xp"])
                    CurrentRank = tonumber(result[1]["rp_rank"])  

                    xPlayer.set("xp", CurrentXP)
                    xPlayer.set("rank", CurrentRank)       
                    
                    if Config.Leaderboard.Enabled then
                        FetchActivePlayers(_source, CurrentXP, CurrentRank)
                    else
                        TriggerClientEvent("esx_xp:init", _source, CurrentXP, CurrentRank, false)
                    end
                end
            else
                TriggerClientEvent("esx_xp:print", _source, _("err_db_user"))
            end
        end)
    end
end)

-- Get Identifier
function GetPlayerLicense(id)
    local xPlayer = ESX.GetPlayerFromId(id)

    if xPlayer and xPlayer ~= nil then
        return xPlayer.identifier
    end

    return false
end

function GetOnlinePlayers(_source, players)
    local Active = {}

    for _, playerId in ipairs(GetPlayers()) do
        local name = GetPlayerName(playerId)
        local license = GetPlayerLicense(playerId)

        for k, v in pairs(players) do
            if license == v.license or license == v.identifier then
                local Player = {
                    name = name,
                    id = playerId,
                    xp = v.rp_xp,
                    rank = v.rp_rank
                }

                -- Current player
                if GetPlayerLicense(_source) == license then
                    Player.current = true
                end
                            
                if Config.Leaderboard.ShowPing then
                    Player.ping = GetPlayerPing(playerId)
                end
    
                table.insert(Active, Player)
                break
            end
        end
    end
    return Active 
end

function FetchActivePlayers(_source, CurrentXP, CurrentRank)
    MySQL.Async.fetchAll('SELECT * FROM users', {}, function(players)
        if #players > 0 then
            TriggerClientEvent("esx_xp:init", _source, CurrentXP, CurrentRank, GetOnlinePlayers(_source, players))
        end
    end)
end

function GetRank(_xp)
    local len = #Config.Ranks
    for rank = 1, len do
        if rank < len then
            if Config.Ranks[rank + 1].XP > tonumber(_xp) then
                return rank
            end
        else
            return rank
        end
    end
end	

RegisterNetEvent("esx_xp:setXP")
AddEventHandler("esx_xp:setXP", function(_xp, _rank)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    _xp = tonumber(_xp)
    _rank = tonumber(_rank)

    if xPlayer then
        MySQL.Async.execute('UPDATE users SET rp_xp = @xp, rp_rank = @rank  WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@xp'] = _xp,
            ['@rank'] = _rank
        }, function(result)
            CurrentXP = tonumber(_xp)
            CurrentRank = tonumber(_rank)

            xPlayer.set("xp", CurrentXP)
            xPlayer.set("rank", CurrentRank)

            TriggerClientEvent("esx_xp:update", _source, CurrentXP, CurrentRank)
        end)
    end
end)

function UpdatePlayer(xPlayer, xp)
    if xPlayer ~= nil then
        CurrentXP = LimitXP(tonumber(xp))
        CurrentRank = GetRank(CurrentXP)

        MySQL.Async.execute('UPDATE users SET rp_xp = @xp, rp_rank = @rank WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@xp'] = CurrentXP,
            ['@rank'] = CurrentRank
        }, function(result)
            xPlayer.set("xp", CurrentXP)
            xPlayer.set("rank", CurrentRank)

            -- Update the player's XP bar
            xPlayer.triggerEvent("esx_xp:update", CurrentXP, CurrentRank)
        end)
    end
end

RegisterNetEvent("esx_xp:getPlayerData")
AddEventHandler("esx_xp:getPlayerData", function()
    local _source = source
    MySQL.Async.fetchAll('SELECT * FROM users', {}, function(players)
        if #players > 0 then     
            TriggerClientEvent("esx_xp:setPlayerData", _source, GetOnlinePlayers(_source, players))
        end
    end) 
end)

------------------------------------------------------------
--                        EVENTS                          --
------------------------------------------------------------

RegisterNetEvent("esx_xp:setInitial")
AddEventHandler("esx_xp:setInitial", function(playerId, XPInit)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer ~= nil then
        if IsInt(XPInit) then
            UpdatePlayer(xPlayer, XPInit)
        end
    end
end)

RegisterNetEvent("esx_xp:addXP")
AddEventHandler("esx_xp:addXP", function(playerId, XPAdd)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer ~= nil then
        if IsInt(XPAdd) then
            local NewXP = CurrentXP + XPAdd
            UpdatePlayer(xPlayer, NewXP)
        end
    end
end)

RegisterNetEvent("esx_xp:removeXP")
AddEventHandler("esx_xp:removeXP", function(playerId, XPRemove)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer ~= nil then    
        if IsInt(XPRemove) then
            local NewXP = CurrentXP - XPRemove
            UpdatePlayer(xPlayer, NewXP)
        end
    end
end)

RegisterNetEvent("esx_xp:setRank")
AddEventHandler("esx_xp:setRank", function(playerId, Rank)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    -- print(Rank)

    if xPlayer ~= nil then    
        local GoalRank = tonumber(Rank)

        if not GoalRank then
            --
        else
            if Config.Ranks[GoalRank] ~= nil then
                UpdatePlayer(xPlayer, tonumber(Config.Ranks[GoalRank].XP))
            end
        end
    end
end)


------------------------------------------------------------
--                    ADMIN COMMANDS                      --
------------------------------------------------------------

function DisplayError(playerId, message)
    TriggerClientEvent('chat:addMessage', playerId, {
        color = { 255, 0, 0 },
        args = { "esx_xp", message }
    })    
end

TriggerClientEvent('chat:addSuggestion', -1, '/esxp_give', _('cmd_give_desc'), {
    { name = "playerId",    help = _('cmd_playerid') },
    { name = "xp",          help = _('cmd_xp_amount') }
}) 

RegisterCommand("esxp_give", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(tonumber(args[1]))
    
    if xPlayer == nil then
        return DisplayError(source, _('err_invalid_player'))
    end

    local xp = tonumber(args[2])

    if not xp then
        return DisplayError(source, _('err_invalid_type', "XP", "number"))
    end

    UpdatePlayer(xPlayer, tonumber(xPlayer.get("xp")) + xp)
end, true)


TriggerClientEvent('chat:addSuggestion', -1, '/esxp_take', _('cmd_take_desc'), {
    { name = "playerId",    help = _('cmd_playerid') },
    { name = "xp",          help = _('cmd_xp_amount') }
}) 

RegisterCommand("esxp_take", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(tonumber(args[1]))

    if xPlayer == nil then
        return DisplayError(source, _('err_invalid_player'))
    end

    local xp = tonumber(args[2])

    if not xp then
        return DisplayError(source, _('err_invalid_type', "XP", "number"))
    end    
    
    UpdatePlayer(xPlayer, tonumber(xPlayer.get("xp")) - xp)
end, true)

TriggerClientEvent('chat:addSuggestion', -1, '/esxp_set', _('cmd_set_desc'), {
    { name = "playerId",    help = _('cmd_playerid') },
    { name = "xp",          help = _('cmd_xp_amount') }
}) 

RegisterCommand("esxp_set", function(source, args, rawCommand)
    if xPlayer == nil then
        return DisplayError(source, _('err_invalid_player'))
    end

    local xp = tonumber(args[2])

    if not xp then
        return DisplayError(source, _('err_invalid_type', "XP", "number"))
    end  

    UpdatePlayer(xPlayer, xp)
end, true)

TriggerClientEvent('chat:addSuggestion', -1, '/esxp_rank', _('cmd_rank_desc'), {
    { name = "playerId",    help = _('cmd_playerid') },
    { name = "rank",        help = _('cmd_rank_amount') }
}) 

RegisterCommand("esxp_rank", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(tonumber(args[1]))

    if xPlayer == nil then
        return DisplayError(source, _('err_invalid_player'))
    end

    local goalRank = tonumber(args[2])

    if not goalRank then
        return DisplayError(source, _('err_invalid_type', "Rank", "number"))
    end

    if goalRank < 1 or goalRank > #Config.Ranks then
        return DisplayError(source, _('err_invalid_rank', #Config.Ranks))
    end

    local xp = Config.Ranks[goalRank].XP

    UpdatePlayer(xPlayer, xp)
end, true)