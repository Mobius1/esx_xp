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

function UpdateXP(_xp)
    Citizen.CreateThread(function()
        XP = tonumber(_xp)
        ESX.TriggerServerCallback("esx_xp:setXP", function(xPlayer, _xp)
            SendNUIMessage({
                set = true,
                xp = XP
            });
        end, XP)
    end)
end

AddEventHandler("esx_xp:addXP", function(_xp)
    UpdateXP(XP + tonumber(_xp))
end)

RegisterCommand('setXP', function(source, args)
    UpdateXP(tonumber(args[1]))
end)
RegisterCommand('addXP', function(source, args)
    UpdateXP(XP + tonumber(args[1]))
end)
RegisterCommand('removeXP', function(source, args)
    UpdateXP(XP - tonumber(args[1]))
end)