-- Get Identifier
function GetSteamIdentifier(id)
    local identifier = false
    
    for k,v in ipairs(GetPlayerIdentifiers(id)) do
        if string.match(v, 'steam:') then
            identifier = v
            break
        end
    end

    return identifier
end

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
    local Max = tonumber(Config.Ranks[#Config.Ranks])

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
        local RankXP = Config.Ranks[i]

        if not IsInt(RankXP) then
            table.insert(InValid, trans('err_lvl_check', i,  RankXP))
        end
        
    end

    return InValid
end

function SortLeaderboard(players)
    if Config.Leaderboard.Order == "rank" then
        table.sort(players, function(a,b)
            return a.rank > b.rank
        end)
    elseif Config.Leaderboard.Order == "name" then
        table.sort(players, function(a,b)
            return a.name < b.name
        end)                
    end    
end