ESX = nil
CurrentXP = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_xp:ready', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Enabled then
        MySQL.Async.fetchAll('SELECT rp_xp FROM users WHERE identifier = @identifier', {
            ['@identifier'] =  xPlayer.identifier,
        }, function(result)
            if #result > 0 then
                CurrentXP = tonumber(result[1]["rp_xp"])
                xPlayer.set('xp', CurrentXP)
                cb(xPlayer, CurrentXP)
            end
        end)
    end
end)

ESX.RegisterServerCallback('esx_xp:setXP', function (source, cb, _xp)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Enabled then
        MySQL.Async.execute('UPDATE users SET rp_xp = @xp WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@xp'] = _xp
        }, function(result)
            CurrentXP = tonumber(_xp)
            xPlayer.set('xp', CurrentXP)
            cb(xPlayer, CurrentXP)
        end)
    end
end)

function UpdatePlayer(PlayerID, xp)
    if Config.Enabled then
        local xPlayer = ESX.GetPlayerFromId(PlayerID)
        MySQL.Async.execute('UPDATE users SET rp_xp = @xp WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@xp'] = xp
        }, function(result)
            CurrentXP = tonumber(xp)
            xPlayer.set('xp', CurrentXP)

            TriggerClientEvent("esx_xp:updateUI", PlayerID, CurrentXP)
        end)
    end
end

------------------------------------------------------------
--                        EVENTS                          --
------------------------------------------------------------

AddEventHandler("esx_xp:XP_SetInitial", function(PlayerID, XPInit)
    if IsInt(XPInit) then
        UpdatePlayer(PlayerID, LimitXP(XPInit))
    end
end)

AddEventHandler("esx_xp:XP_Add", function(PlayerID, XPAdd)
    if IsInt(XPAdd) then
        local xPlayer = ESX.GetPlayerFromId(PlayerID)
        local XP = tonumber(xPlayer.get("xp"))
        local Max = tonumber(Config.Levels[#Config.Levels])

        if not XP then
            XP = CurrentXP
        end

        local NewXP = XP + XPAdd

        UpdatePlayer(PlayerID, LimitXP(NewXP))
    end
end)

AddEventHandler("esx_xp:XP_Remove", function(PlayerID, XPRemove)
    if IsInt(XPRemove) then
        local xPlayer = ESX.GetPlayerFromId(PlayerID)
        local XP = tonumber(xPlayer.get("xp"))

        if not XP then
            XP = CurrentXP
        end

        local NewXP = XP - XPRemove

        UpdatePlayer(PlayerID, LimitXP(NewXP))
    end
end)