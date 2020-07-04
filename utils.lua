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
    local Max = tonumber(Config.Levels[#Config.Levels])

    if XPCheck > Max then
        XPCheck = Max
    elseif XPCheck < 0 then
        XPCheck = 0
    end

    return tonumber(XPCheck)
end