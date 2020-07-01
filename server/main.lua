ESX = nil
XP = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_xp:ready', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Enabled then
        MySQL.Async.fetchAll('SELECT rp_xp FROM users WHERE identifier = @identifier', {
            ['@identifier'] =  xPlayer.identifier,
        }, function(result)
            if #result > 0 then
                XP = tonumber(result[1]["rp_xp"])
                cb(xPlayer, XP)
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
            XP = tonumber(_xp)
            cb(xPlayer, _xp)
        end)
    end
end)

RegisterCommand('XP_SetInitial', function(source, args)
    TriggerClientEvent("esx_xp:setInitialXP", source, tonumber(args[1]))
end, true)

RegisterCommand('XP_Add', function(source, args)
    TriggerClientEvent("esx_xp:addXP", source, tonumber(args[1]))
end, true)

RegisterCommand('XP_Remove', function(source, args)
    TriggerClientEvent("esx_xp:removeXP", source, tonumber(args[1]))
end, true)