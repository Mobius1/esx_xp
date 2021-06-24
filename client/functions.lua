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
        TriggerEvent("esx_xp:print", _('err_xp_update', XPInit, "ESXP_SetInitial"))
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
        TriggerEvent("esx_xp:print", _('err_lvl_update', Rank, "ESXP_SetRank"))
        return
    end

    local newXP = Config.Ranks[GoalRank].XP

    if newXP ~= nil then
        local XPAdd = 0

        if newXP > CurrentXP then
            ESXP_Add(newXP - CurrentXP)
        elseif newXP < CurrentXP then
            ESXP_Remove(CurrentXP - newXP)
        end
    else
        TriggerEvent("esx_xp:print", _('err_lvl_update', Rank, "ESXP_SetRank"))
    end
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
        TriggerEvent("esx_xp:print", _('err_xp_update', XPAdd, "ESXP_Add"))
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
        TriggerEvent("esx_xp:print", _('err_xp_update', XPRemove, "ESXP_Remove"))
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
            if Config.Ranks[rank + 1].XP > tonumber(_xp) then
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

    return Config.Ranks[currentRank + 1].XP - tonumber(CurrentXP)   
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
        TriggerEvent("esx_xp:print", _('err_lvl_update', Rank, "ESXP_GetXPToRank"))
        return
    end

    local goalXP = tonumber(Config.Ranks[GoalRank].XP)

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
    return Config.Ranks[#Config.Ranks].XP
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
function ESXP_ShowUI(update)
    UIActive = true

    if update ~= nil then
        TriggerServerEvent("esx_xp:getPlayerData")
    end
    
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

function ESXP_TimeoutUI(update)
    UIActive = true

    if update ~= nil then
        TriggerServerEvent("esx_xp:getPlayerData")
    end
    
    SendNUIMessage({
        xpm_display = true
    })    
end

function ESXP_SortLeaderboard(type)
    SendNUIMessage({
        xpm_lb_sort = true,
        xpm_lb_order = type or "rank"
    })   
end


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

-- SHOW UI
exports('ESXP_ShowUI', ESXP_ShowUI)

-- HIDE UI
exports('ESXP_HideUI', ESXP_HideUI)

-- TIMEOUT UI
exports('ESXP_TimeoutUI', ESXP_TimeoutUI)

-- SORT LEADERBOARD
exports('ESXP_SortLeaderboard', ESXP_SortLeaderboard)

