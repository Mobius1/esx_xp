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

RegisterNetEvent("esx_xp:update")

function SetXP(xPlayer, _xp)
    if Config.Enabled then
        MySQL.Async.execute('UPDATE users SET rp_xp = @xp WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@xp'] = _xp
        }, function(result)
            XP = tonumber(_xp)

            TriggerClientEvent("esx_xp:update", source, XP)
        end)
    end    
end

RegisterNetEvent("esx_xp:addXP")

AddEventHandler("esx_xp:addXP", function(_xp)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Enabled then
        XP = XP + tonumber(_xp)
        SetXP(xPlayer, XP)
    end
end)

RegisterNetEvent("esx_xp:removeXP")

AddEventHandler("esx_xp:removeXP", function(_xp)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.Enabled then
        XP = XP - tonumber(_xp)
        SetXP(xPlayer, XP)
    end
end)
