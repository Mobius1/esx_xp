-- Get Identifier
function GetPlayerLicense(id)
    for _, v in pairs(GetPlayerIdentifiers(id)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            return string.gsub(v, "license:", "")
        end
    end  
    return false
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

function GetOnlinePlayers(_source, players)
    local Active = {}
    for _, playerId in ipairs(GetPlayers()) do
        local name = GetPlayerName(playerId)
        local license = GetPlayerLicense(playerId)

        for k, v in pairs(players) do
            v.license = string.gsub(v.license, "license:", "")
            
            if v.license == license then
                local Player = {
                    name = name,
                    id = playerId,
                    xp = v.rp_xp,
                    rank = v.rp_rank
                }

                -- Current player
                if GetPlayerLicense(_source) == v.license then
                    Player.current = true
                end
                            
                if Config.Leaderboard.ShowPing then
                    Player.ping = GetPlayerPing(playerId)
                end
    
                table.insert(Active, Player)
                break
            end
        end
    end
    return Active 
end