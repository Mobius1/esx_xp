CurrentXP = 0
CurrentRank = 0
Leaderboard = nil
Players = {}
UIActive = true
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end
    
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(10)
    end
    
    TriggerServerEvent("esx_xp:ready")
end)

RegisterNetEvent("esx_xp:init")
AddEventHandler("esx_xp:init", function(_xp, _rank, players)

    local Ranks = CheckRanks()

    -- All ranks are valid
    if #Ranks == 0 then
    
        local data = {
            xpm_init = true,
            xpm_config = Config,
            currentID = false,
        }
    
        if Config.Leaderboard.Enabled and players then
            SortLeaderboard(players)
    
            data.players = players
            data.showPing = Config.Leaderboard.ShowPing
            
            for k, v in pairs(players) do
                if GetPlayerServerId(PlayerId()) == tonumber(v.id) then
                    data.currentID = tonumber(v.id)
                end
            end
    
            for k,v in pairs(players) do
                Players[tonumber(v.id)] = v
            end                        
        end
    
        CurrentXP = tonumber(_xp)
    
        data.xp = CurrentXP
    
        SendNUIMessage(data)
    
        CurrentRank = _rank
    
        -- Native stats
        StatSetInt("MPPLY_GLOBALXP", CurrentXP, 1)
    else
        print(_('err_lvls_check', #Ranks, 'Config.Ranks'))
    end
end)

RegisterNetEvent("esx_xp:update")
AddEventHandler("esx_xp:update", function(_xp, _rank)

    local oldRank = CurrentRank
    local newRank = _rank
    local newXP = _xp

    SendNUIMessage({
        xpm_set = true,
        xp = newXP
    })

    CurrentXP = newXP
    CurrentRank = newRank
end)

if Config.Leaderboard.Enabled then
    RegisterNetEvent("esx_xp:setPlayerData")
    AddEventHandler("esx_xp:setPlayerData", function(players)

        for k, v in pairs(Players) do
            if v.fake == nil then
                Players[k] = nil
            end
        end

        for k, v in pairs(players) do
            Players[v.id] = v
        end

        -- Update leaderboard
        SendNUIMessage({
            xpm_updateleaderboard = true,
            xpm_players = Players
        })
    end)
end


------------------------------------------------------------
--                       FUNCTIONS                        --
------------------------------------------------------------

------------
-- UpdateXP.
--
-- @global
-- @param	int 	_xp 	
-- @param	bool	init	
-- @return	void
function UpdateXP(_xp, init)
    _xp = tonumber(_xp)

    local points = CurrentXP + _xp
    local max = ESXP_GetMaxXP()

    if init then
        points = _xp
    end

    points = LimitXP(points)

    local rank = ESXP_GetRank(points)

    TriggerServerEvent("esx_xp:setXP", points, rank)
end


------------
-- ESXP_SetInitial.
--
-- @global
-- @param	int 	XPInit	
-- @return	void
function ESXP_SetInitial(XPInit)
    local GoalXP = tonumber(XPInit)
    -- Check for valid XP
    if not GoalXP or (GoalXP < 0 or GoalXP > ESXP_GetMaxXP()) then
        print(_('err_xp_update', XPInit, "ESXP_SetInitial"))
        return
    end    
    UpdateXP(tonumber(GoalXP), true)
end

------------
-- ESXP_SetRank.
--
-- @global
-- @param	int	Rank	
-- @return	void
function ESXP_SetRank(Rank)
    local GoalRank = tonumber(Rank)

    if not GoalRank then
        print(_('err_lvl_update', Rank, "ESXP_SetRank"))
        return
    end

    local XPAdd = tonumber(Config.Ranks[GoalRank]) - CurrentXP

    ESXP_Add(XPAdd)
end

------------
-- ESXP_Add.
--
-- @global
-- @param	int 	XPAdd	
-- @return	void
function ESXP_Add(XPAdd)
    -- Check for valid XP
    if not tonumber(XPAdd) then
        print(_('err_xp_update', XPAdd, "ESXP_Add"))
        return
    end       
    UpdateXP(tonumber(XPAdd))
end

------------
-- ESXP_Remove.
--
-- @global
-- @param	int 	XPRemove	
-- @return	void
function ESXP_Remove(XPRemove)
    -- Check for valid XP
    if not tonumber(XPRemove) then
        print(_('err_xp_update', XPRemove, "ESXP_Remove"))
        return
    end       
    UpdateXP(-(tonumber(XPRemove)))
end

------------
-- ESXP_GetRank.
--
-- @global
-- @param	int 	_xp	
-- @return	void
function ESXP_GetRank(_xp)

    if _xp == nil then
        return CurrentRank
    end

    local len = #Config.Ranks
    for rank = 1, len do
        if rank < len then
            if Config.Ranks[rank + 1] > tonumber(_xp) then
                return rank
            end
        else
            return rank
        end
    end
end	

------------
-- ESXP_GetXPToNextRank.
--
-- @global
-- @return	int
function ESXP_GetXPToNextRank()
    local currentRank = ESXP_GetRank()

    return Config.Ranks[currentRank + 1] - tonumber(CurrentXP)   
end

------------
-- ESXP_GetXPToRank.
--
-- @global
-- @param	int 	Rank	
-- @return	int
function ESXP_GetXPToRank(Rank)
    local GoalRank = tonumber(Rank)
    -- Check for valid rank
    if not GoalRank or (GoalRank < 1 or GoalRank > #Config.Ranks) then
        print(_('err_lvl_update', Rank, "ESXP_GetXPToRank"))
        return
    end

    local goalXP = tonumber(Config.Ranks[GoalRankl])

    return goalXP - CurrentXP
end

------------
-- ESXP_GetXP.
--
-- @global
-- @return	int
function ESXP_GetXP()
    return tonumber(CurrentXP)
end

------------
-- ESXP_GetMaxXP.
--
-- @global
-- @return	int
function ESXP_GetMaxXP()
    return Config.Ranks[#Config.Ranks]
end

------------
-- ESXP_GetMaxRank.
--
-- @global
-- @return	int
function ESXP_GetMaxRank()
    return #Config.Ranks
end

------------
-- ESXP_ShowUI.
--
-- @global
-- @return	void
function ESXP_ShowUI()
    UIActive = true

    TriggerServerEvent("esx_xp:getPlayerData")
    
    SendNUIMessage({
        xpm_show = true
    })    
end

------------
-- ESXP_HideUI.
--
-- @global
-- @return	void
function ESXP_HideUI()
    UIActive = false
        
    SendNUIMessage({
        xpm_hide = true
    })      
end
------------------------------------------------------------
--                        CONTROLS                        --
------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(0, 20) then
            UIActive = not UIActive

            if UIActive then
                TriggerServerEvent("esx_xp:getPlayerData")
            end

            SendNUIMessage({
                xpm_display = true
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
    CurrentXP = tonumber(_xp)

    SendNUIMessage({
        xpm_set = true,
        xp = CurrentXP
    })
end)

-- SET INTITIAL XP
RegisterNetEvent("esx_xp:SetInitial")
AddEventHandler('esx_xp:SetInitial', ESXP_SetInitial)

-- ADD XP
RegisterNetEvent("esx_xp:Add")
AddEventHandler('esx_xp:Add', ESXP_Add)

-- REMOVE XP
RegisterNetEvent("esx_xp:Remove")
AddEventHandler('esx_xp:Remove', ESXP_Remove)

RegisterNetEvent("esx_xp:SetRank")
AddEventHandler('esx_xp:SetRank', ESXP_SetRank)

-- RANK CHANGE NUI CALLBACK
RegisterNUICallback('xpm_rankchange', function(data)
    if data.rankUp then
        TriggerEvent("esx_xp:rankUp", data.current, data.previous)
    else
        TriggerEvent("esx_xp:rankDown", data.current, data.previous)
    end
end)

RegisterNUICallback('xpm_uichange', function(data)
    UIActive = false
end)


------------------------------------------------------------
--                        EXPORTS                         --
------------------------------------------------------------

-- SET INTITIAL XP
exports('ESXP_SetInitial', ESXP_SetInitial)

-- ADD XP
exports('ESXP_Add', ESXP_Add)

-- REMOVE XP
exports('ESXP_Remove', ESXP_Remove)

-- SET RANK
exports('ESXP_SetRank', ESXP_SetRank)

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