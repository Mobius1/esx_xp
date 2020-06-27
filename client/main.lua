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

        if Config.UseXNLRankBar then
            exports.XNLRankBar:Exp_XNL_SetInitialXPLevels(XP, true, true)
        else
            SendNUIMessage({
                init = true,
                xp = XP,
                levels = Config.Levels
            });
        end
    end)
end)

function UpdateXP(_xp)
    _xp = tonumber(_xp)

    Citizen.CreateThread(function()
        ESX.TriggerServerCallback("esx_xp:setXP", function(xPlayer, points)
            XP = tonumber(points)
            if Config.UseXNLRankBar then
                if _xp > 0 then
                    exports.XNLRankBar:Exp_XNL_AddPlayerXP(_xp)
                elseif _xp < 0 then
                    exports.XNLRankBar:Exp_XNL_RemovePlayerXP(_xp * -1)
                end
            else
                SendNUIMessage({
                    set = true,
                    xp = XP
                })
            end
        end, XP + _xp)
    end)
end

AddEventHandler("esx_xp:addXP", function(_xp)
    UpdateXP(tonumber(_xp))
end)

RegisterCommand('addXP', function(source, args)
    UpdateXP(tonumber(args[1]))
end)
RegisterCommand('removeXP', function(source, args)
    UpdateXP(-(tonumber(args[1])))
end)