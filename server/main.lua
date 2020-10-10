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
            if Config.Ranks[rank + 1] > tonumber(_xp) then
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

function UpdatePlayer(source, xp)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    CurrentXP = tonumber(xp)
    CurrentRank = GetRank(CurrentXP)

    if xPlayer then
        MySQL.Async.execute('UPDATE users SET rp_xp = @xp, rp_rank = @rank WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@xp'] = CurrentXP,
            ['@rank'] = CurrentRank
        }, function(result)

            xPlayer.set("xp", CurrentXP)
            xPlayer.set("rank", CurrentRank)

            TriggerClientEvent("esx_xp:update", _source, CurrentXP, CurrentRank)
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

AddEventHandler("esx_xp:setInitial", function(PlayerID, XPInit)
    if IsInt(XPInit) then
        UpdatePlayer(PlayerID, LimitXP(XPInit))
    end
end)

AddEventHandler("esx_xp:addXP", function(PlayerID, XPAdd)
    if IsInt(XPAdd) then
        local NewXP = CurrentXP + XPAdd
        UpdatePlayer(PlayerID, LimitXP(NewXP))
    end
end)

AddEventHandler("esx_xp:removeXP", function(PlayerID, XPRemove)
    if IsInt(XPRemove) then
        local NewXP = CurrentXP - XPRemove
        UpdatePlayer(PlayerID, LimitXP(NewXP))
    end
end)