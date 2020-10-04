------------------------------------------------------------
--                        COMMANDS                        --
------------------------------------------------------------

TriggerEvent('chat:addSuggestion', '/ESXP', 'Display your XP stats') 

RegisterCommand('ESXP', function(source, args)
    Citizen.CreateThread(function()
        local xpToNext = ESXP_GetXPToNextRank()

        -- SHOW THE XP BAR
        SendNUIMessage({ xpm_display = true })        

        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", trans('cmd_current_xp', CurrentXP)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", trans('cmd_current_lvl', CurrentRank)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", trans('cmd_next_lvl', xpToNext, CurrentRank + 1)}
        })                
    end)
end)

-- !!!!!! THESE ARE FOR TESTING PURPOSES AND WILL NOT SAVE THE CHANGES IN THE DB !!!!!! --
RegisterCommand('ESXP_SetInitial', function(source, args)
    if IsInt(args[1]) then
        CurrentXP = LimitXP(tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        })   
    else
        print("esx_xp: Invalid XP") 
    end       
end)

RegisterCommand('ESXP_Add', function(source, args)
    if IsInt(args[1]) then
        CurrentXP = LimitXP(CurrentXP + tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        }) 
    else
        print("esx_xp: Invalid XP") 
    end  
end)

RegisterCommand('ESXP_Remove', function(source, args)
    if IsInt(args[1]) then    
        CurrentXP = LimitXP(CurrentXP - tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        }) 
    else
        print("esx_xp: Invalid XP") 
    end     
end)