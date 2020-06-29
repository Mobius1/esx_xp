ESX = nil
Player = nil
XP = 0

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end

    Wait(1000)

    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(10)
    end

    Player = ESX.GetPlayerData()

    ESX.TriggerServerCallback("esx_xp:ready", function(xPlayer, _xp)
        XP = tonumber(_xp)
        SendNUIMessage({
            init = true,
            xp = XP,
            levels = Config.Levels
        });
    end)
end)

function UpdateXP(_xp, init)
    _xp = tonumber(_xp)

    local _XP = XP + _xp;

    if init then
        _XP = _xp
    end

    Citizen.CreateThread(function()
        ESX.TriggerServerCallback("esx_xp:setXP", function(xPlayer, points)
            XP = tonumber(points)
            SendNUIMessage({
                set = true,
                xp = XP
            })
        end, _XP)
    end)
end

RegisterCommand('initXP', function(source, args)
    UpdateXP(tonumber(args[1]), true)
end)

RegisterCommand('addXP', function(source, args)
    UpdateXP(tonumber(args[1]))
end)

RegisterCommand('removeXP', function(source, args)
    UpdateXP(-(tonumber(args[1])))
end)

-- Show XP bar on keypress
Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(0, 20) then
            SendNUIMessage({
                display = true
            })
        end
        Citizen.Wait(1)
    end
end)

-- EXPORTS
exports('XP_SetInitial', function(XPInit)
    UpdateXP(tonumber(XPAdd), true)
end)

exports('XP_Add', function(XPAdd)
    UpdateXP(tonumber(XPAdd))
end)

exports('XP_Remove', function(XPAdd)
    UpdateXP(-(tonumber(XPAdd)))
end)