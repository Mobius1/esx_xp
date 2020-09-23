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