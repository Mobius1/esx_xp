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
            config = Config
        });
    end)
end)


------------------------------------------------------------
--                       FUNCTIONS                        --
------------------------------------------------------------

function UpdateXP(_xp, init)
    _xp = tonumber(_xp)

    local points = XP + _xp;
    local max = XP_GetMaxXP()

    if init then
        points = _xp
    end

    if points < 0 then
        points = 0
    end

    if points > max then
        points = max
    end

    Citizen.CreateThread(function()
        local currentLevel = XP_GetLevel()
        local endLevel = XP_GetLevel(points)
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

function XP_SetInitial(XPInit)
    XPInit = tonumber(XPInit)
    -- Check for valid XP
    if not XPInit or (XPInit < 0 or XPInit > XP_GetMaxXP()) then
        print(("esx_xp: Invalid XP (%s) passed to '%s'"):format(XPInit, "XP_SetInitial"))
        return
    end    
    UpdateXP(tonumber(XPInit), true)
end

function XP_SetLevel(Level)
    local GoalLevel = tonumber(Level)

    if not GoalLevel then
        print(("esx_xp: Invalid level (%s) passed to '%s'"):format(Level, "XP_SetLevel"))
        return
    end

    local XPAdd = tonumber(Config.Levels[GoalLevel]) - XP

    XP_Add(XPAdd)
end

function XP_Add(XPAdd)
    -- Check for valid XP
    if not tonumber(XPAdd) then
        print(("esx_xp: Invalid XP (%s) passed to '%s'"):format(XPAdd, "XP_Add"))
        return
    end       
    UpdateXP(tonumber(XPAdd))
end

function XP_Remove(XPRemove)
    -- Check for valid XP
    if not tonumber(XPRemove) then
        print(("esx_xp: Invalid XP (%s) passed to '%s'"):format(XPRemove, "XP_Remove"))
        return
    end       
    UpdateXP(-(tonumber(XPRemove)))
end

function XP_GetLevel(_xp)
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

function XP_GetXPToNextLevel()
    local currentLevel = XP_GetLevel()

    return Config.Levels[currentLevel + 1] - tonumber(XP)   
end

function XP_GetXPToLevel(Level)
    Level = tonumber(Level)
    -- Check for valid level
    if not Level or (Level < 1 or Level > #Config.Levels) then
        print(("esx_xp: Invalid level (%s) passed to '%s'"):format(Level, "XP_GetXPToLevel"))
        return
    end

    local goalXP = tonumber(Config.Levels[Level])

    return goalXP - XP
end

function XP_GetXP()
    return tonumber(XP)
end

function XP_GetMaxXP()
    return Config.Levels[#Config.Levels]
end

function XP_GetMaxLevel()
    return #Config.Levels
end


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

-- SET INTITIAL XP
exports('XP_SetInitial', XP_SetInitial)

-- ADD XP
exports('XP_Add', XP_Add)

-- REMOVE XP
exports('XP_Remove', XP_Remove)

-- GET CURRENT XP
exports('XP_GetXP', XP_GetXP)

-- GET CURRENT LEVEL
exports('XP_GetLevel', XP_GetLevel)

-- GET XP REQUIRED TO LEVEL-UP
exports('XP_GetXPToNextLevel', XP_GetXPToNextLevel)

-- GET XP REQUIRED TO LEVEL-UP
exports('XP_GetXPToLevel', XP_GetXPToLevel)

-- GET MAX XP
exports('XP_GetMaxXP', XP_GetMaxXP)

-- GET MAX LEVEL
exports('XP_GetMaxLevel', XP_GetMaxLevel)


------------------------------------------------------------
--                        COMMANDS                        --
------------------------------------------------------------

TriggerEvent('chat:addSuggestion', '/XP', 'Display your XP stats') 

RegisterCommand('XP', function(source, args)
    Citizen.CreateThread(function()
        local currentLevel = XP_GetLevel()
        local xpToNext = XP_GetXPToNextLevel()

        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _U('cmd_current_xp', XP)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _U('cmd_current_lvl', currentLevel)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _U('cmd_next_lvl', xpToNext, currentLevel + 1)}
        })                
        
    end)
end)