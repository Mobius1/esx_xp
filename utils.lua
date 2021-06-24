-- Check XP is an integer
function IsInt(XPCheck)
    XPCheck = tonumber(XPCheck)
    if XPCheck and XPCheck == math.floor(XPCheck) then
        return true
    end
    return false
end

-- Prevent XP from going over / under limits
function LimitXP(XPCheck)
    local Max = tonumber(Config.Ranks[#Config.Ranks].XP)

    if XPCheck > Max then
        XPCheck = Max
    elseif XPCheck < 0 then
        XPCheck = 0
    end

    return tonumber(XPCheck)
end

function CheckRanks()
    local Limit = #Config.Ranks
    local InValid = {}

    for i = 1, Limit do
        local RankXP = Config.Ranks[i].XP

        if not IsInt(RankXP) then
            table.insert(InValid, _('err_lvl_check', i,  RankXP))
        end
        
    end

    return InValid
end

function SortLeaderboard(players, order)
    if order == nil then
        order = Config.Leaderboard.Order
    end

    if order == "rank" then
        table.sort(players, function(a,b)
            return a.rank > b.rank
        end)
    elseif order == "id" then
        table.sort(players, function(a,b)
            return a.id > b.id
        end)                      
    elseif order == "name" then
        table.sort(players, function(a,b)
            return a.name < b.name
        end)                
    end    
end

function PlayerIsActive(tab, val)
    for k, v in ipairs(tab) do
        if tonumber(v.id) == tonumber(val) then
            return k
        end
    end

    return false
end

function GetRankFromXP(_xp)
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

function CloneTable(object)
    local lookup_table = {}
    local function copy(object) 
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[copy(key)] = copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return copy(object)
end