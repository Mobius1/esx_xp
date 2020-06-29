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
            timeout = Config.Timeout,
            levels = Config.Levels
        });
    end)
end)


------------------------------------------------------------
--                       FUNCTIONS                        --
------------------------------------------------------------

function UpdateXP(_xp, init)
    _xp = tonumber(_xp)

    local points = XP + _xp;

    if init then
        points = _xp
    end

    Citizen.CreateThread(function()
        local currentLevel = GetLevelFromXP()
        local endLevel = GetLevelFromXP(points)
        ESX.TriggerServerCallback("esx_xp:setXP", function(xPlayer, points)
            XP = tonumber(points)
            SendNUIMessage({
                set = true,
                xp = XP
            })

            if endLevel > currentLevel then
                for i = currentLevel, endLevel - 1 do
                    TriggerEvent("esx_xp:levelUp", endLevel, currentLevel)
                end
            elseif endLevel < currentLevel then
                for i = endLevel, currentLevel - 1 do
                    TriggerEvent("esx_xp:levelDown", endLevel, currentLevel)
                end                
            end
        end, points)
    end)
end

function GetLevelFromXP(_xp)
    local len = #Config.Levels
    local points = XP
    if _xp then
        points = _xp
    end

    for level = 1, len do
        if level < len then
            if Config.Levels[level + 1] >= tonumber(points) then
                return level
            end
        else
            return level
        end
    end
end	

function GetXPToNextLevel()
    local currentLevel = GetLevelFromXP()

    return Config.Levels[currentLevel + 1] - tonumber(XP)   
end

------------------------------------------------------------
--                         EVENTS                         --
------------------------------------------------------------

AddEventHandler("esx_xp:levelUp", function(level, old)
    ESX.ShowNotification("~g~LEVEL UP!")
end)
AddEventHandler("esx_xp:levelDown", function(level, old)
    ESX.ShowNotification("~r~LEVEL DOWN!")
end)

------------------------------------------------------------
--                        COMMANDS                        --
------------------------------------------------------------

TriggerEvent('chat:addSuggestion', '/XP', 'help text', {
    { name="type", help="level | xp | next" }
}) 

RegisterCommand('XP', function(source, args)
    Citizen.CreateThread(function()
        local currentLevel = GetLevelFromXP()
        if args ~= nil then
            if args[1] == 'level' then
                TriggerEvent("chatMessage", "Your current XP level is ^2".. currentLevel)
            elseif args[1] == 'xp' then
                TriggerEvent("chatMessage", "Your currently have ^2".. XP .. " XP")
            elseif args[1] == 'next' then
                TriggerEvent("chatMessage", "You require ^2".. GetXPToNextLevel() .. " XP ^7to advance to level ^2" .. currentLevel + 1)
            end
        end  
    end)
end)

------------------------------------------------------------
--                        CONTROLS                        --
------------------------------------------------------------

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

------------------------------------------------------------
--                        EXPORTS                         --
------------------------------------------------------------

exports('XP_SetInitial', function(XPInit)
    UpdateXP(tonumber(XPAdd), true)
end)

exports('XP_Add', function(XPAdd)
    UpdateXP(tonumber(XPAdd))
end)

exports('XP_Remove', function(XPAdd)
    UpdateXP(-(tonumber(XPAdd)))
end)

exports('XP_GetXP', function()
    return tonumber(XP)
end)

exports('XP_GetLevel', GetLevelFromXP)

exports('XP_GetXPToNextLevel', GetXPToNextLevel)