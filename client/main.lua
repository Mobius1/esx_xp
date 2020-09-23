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
        local Ranks = CheckRanks()

        -- All ranks are valid
        if #Ranks == 0 then
            XP = tonumber(_xp)
            SendNUIMessage({
                esxp_init = true,
                xp = XP,
                esxp_config = Config
            });
        else
            print(_('err_lvls_check', #Ranks, 'Config.Ranks'))
            print(ESX.DumpTable(Ranks))
        end
    end)
end)


------------------------------------------------------------
--                       FUNCTIONS                        --
------------------------------------------------------------

function UpdateXP(_xp, init)
    _xp = tonumber(_xp)

    local points = XP + _xp;
    local max = ESXP_GetMaxXP()

    if init then
        points = _xp
    end

    points = LimitXP(points)

    Citizen.CreateThread(function()
        local currentRank = ESXP_GetRank()
        local endRank = ESXP_GetRank(points)
        ESX.TriggerServerCallback("esx_xp:setXP", function(xPlayer, xp)
            XP = tonumber(xp)
            SendNUIMessage({
                esxp_set = true,
                xp = XP
            })

            if endRank > currentRank then
                for i = currentRank, endRank - 1 do
                    TriggerEvent("esx_xp:rankUp", endRank, currentRank)
                end
            elseif endRank < currentRank then
                for i = endRank, currentRank - 1 do
                    TriggerEvent("esx_xp:rankDown", endRank, currentRank)
                end                
            end
        end, points)
    end)
end

function ESXP_SetInitial(XPInit)
    local GoalXP = tonumber(XPInit)
    -- Check for valid XP
    if not GoalXP or (GoalXP < 0 or GoalXP > ESXP_GetMaxXP()) then
        print(_('err_xp_update', XPInit, "ESXP_SetInitial"))
        return
    end    
    UpdateXP(tonumber(GoalXP), true)
end

function ESXP_SetRank(Rank)
    local GoalRank = tonumber(Rank)

    if not GoalRank then
        print(_('err_lvl_update', Rank, "ESXP_SetRank"))
        return
    end

    local XPAdd = tonumber(Config.Ranks[GoalRank]) - XP

    ESXP_Add(XPAdd)
end

function ESXP_Add(XPAdd)
    -- Check for valid XP
    if not tonumber(XPAdd) then
        print(_('err_xp_update', XPAdd, "ESXP_Add"))
        return
    end       
    UpdateXP(tonumber(XPAdd))
end

function ESXP_Remove(XPRemove)
    -- Check for valid XP
    if not tonumber(XPRemove) then
        print(_('err_xp_update', XPRemove, "ESXP_Remove"))
        return
    end       
    UpdateXP(-(tonumber(XPRemove)))
end

function ESXP_GetRank(_xp)
    local len = #Config.Ranks
    local points = XP
    if _xp then
        points = _xp
    end

    for rank = 1, len do
        if rank < len then
            if Config.Ranks[rank + 1] >= tonumber(points) then
                return rank
            end
        else
            return rank
        end
    end
end	

function ESXP_GetXPToNextRank()
    local currentRank = ESXP_GetRank()

    return Config.Ranks[currentRank + 1] - tonumber(XP)   
end

function ESXP_GetXPToRank(Rank)
    local GoalRank = tonumber(Rank)
    -- Check for valid rank
    if not GoalRank or (GoalRank < 1 or GoalRank > #Config.Ranks) then
        print(_('err_lvl_update', Rank, "ESXP_GetXPToRank"))
        return
    end

    local goalXP = tonumber(Config.Ranks[GoalRankl])

    return goalXP - XP
end

function ESXP_GetXP()
    return tonumber(XP)
end

function ESXP_GetMaxXP()
    return Config.Ranks[#Config.Ranks]
end

function ESXP_GetMaxRank()
    return #Config.Ranks
end


------------------------------------------------------------
--                        CONTROLS                        --
------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(0, 20) then
            SendNUIMessage({
                esxp_display = true
            })
        end
        Citizen.Wait(1)
    end
end)


------------------------------------------------------------
--                         EVENTS                         --
------------------------------------------------------------

RegisterNetEvent("esx_xp:updateUI")
AddEventHandler("esx_xp:updateUI", function(_xp)
    XP = tonumber(_xp)

    SendNUIMessage({
        esxp_set = true,
        xp = XP
    });
end)

-- SET INTITIAL XP
RegisterNetEvent("esx_xp:setInitial")
AddEventHandler('esx_xp:setInitial',  ESXP_SetInitial)

-- ADD XP
RegisterNetEvent("esx_xp:addXP")
AddEventHandler('esx_xp:addXP',  ESXP_Add)

-- REMOVE XP
RegisterNetEvent("esx_xp:removeXP")
AddEventHandler('esx_xp:removeXP',  ESXP_Remove)

------------------------------------------------------------
--                        EXPORTS                         --
------------------------------------------------------------

-- SET INTITIAL XP
exports('ESXP_SetInitial', ESXP_SetInitial)

-- ADD XP
exports('ESXP_Add', ESXP_Add)

-- REMOVE XP
exports('ESXP_Remove', ESXP_Remove)

-- GET CURRENT XP
exports('ESXP_GetXP', ESXP_GetXP)

-- GET CURRENT RANK
exports('ESXP_GetRank', ESXP_GetRank)

-- GET XP REQUIRED TO RANK-UP
exports('ESXP_GetXPToNextRank', ESXP_GetXPToNextRank)

-- GET XP REQUIRED TO RANK-UP
exports('ESXP_GetXPToRank', ESXP_GetXPToRank)

-- GET MAX XP
exports('ESXP_GetMaxXP', ESXP_GetMaxXP)

-- GET MAX RANK
exports('ESXP_GetMaxRank', ESXP_GetMaxRank)


------------------------------------------------------------
--                        COMMANDS                        --
------------------------------------------------------------

TriggerEvent('chat:addSuggestion', '/ESXP', 'Display your XP stats') 

RegisterCommand('ESXP', function(source, args)
    Citizen.CreateThread(function()
        local currentRank = ESXP_GetRank()
        local xpToNext = ESXP_GetXPToNextRank()

        -- SHOW THE XP BAR
        SendNUIMessage({ esxp_display = true })        

        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _('cmd_current_xp', XP)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _('cmd_current_lvl', currentRank)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _('cmd_next_lvl', xpToNext, currentRank + 1)}
        })                
    end)
end)

-- !!!!!! THESE ARE FOR TESTING PURPOSES AND WILL NOT SAVE THE CHANGES IN THE DB !!!!!! --
RegisterCommand('ESXP_SetInitial', function(source, args)
    if IsInt(args[1]) then
        XP = LimitXP(tonumber(args[1]))
        SendNUIMessage({
            esxp_set = true,
            xp = XP
        });   
    else
        print("esx_xp: Invalid XP") 
    end       
end)

RegisterCommand('ESXP_Add', function(source, args)
    if IsInt(args[1]) then
        XP = LimitXP(XP + tonumber(args[1]))
        SendNUIMessage({
            esxp_set = true,
            xp = XP
        }); 
    else
        print("esx_xp: Invalid XP") 
    end  
end)

RegisterCommand('ESXP_Remove', function(source, args)
    if IsInt(args[1]) then
        XP = LimitXP(XP - tonumber(args[1]))
        SendNUIMessage({
            esxp_set = true,
            xp = XP
        }); 
    else
        print("esx_xp: Invalid XP") 
    end     
end)