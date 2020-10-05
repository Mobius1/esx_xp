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

function GetOnlinePlayers(players)
    local Players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local name = GetPlayerName(playerId)
    
        for k, v in pairs(players) do
            if name == v.name then
                local Player = {
                    name = name,
                    id = playerId,
                    xp = v.rp_xp,
                    rank = v.rp_rank
                }     
                            
                if Config.Leaderboard.ShowPing then
                    Player.ping = GetPlayerPing(playerId)
                end
    
                table.insert(Players, Player)
                break
            end
        end
    end
    return Players 
end