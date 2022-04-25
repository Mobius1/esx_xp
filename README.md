# esx_xp
Adds an XP ranking system like the one found in GTA:O. Work in progress.

# Update
I've abandoned work on this resource in favour of [xperience](https://github.com/Mobius1/xperience). It offers the same functionality, but is framework agnostic. It also integrates into both `ESX` and `QBCore`.

## Features
* Designed to emulate the native GTA:O system
* Saves and loads players XP / rank
* Add / remove XP from your own script / job
* Allows you listen for rank changes to reward players
* Fully customisable UI
* Integrated leaderboard

## TOC
* [Demos](#demos)
* [Requirements](#requirements)
* [Download & Installation](#download---installation)
* [Upgrading to 1.0.0](#upgrading-to-100)
* [Upgrading to 1.3.0](#upgrading-to-130)
* [Configuration](#configuration)
* [Functions](#functions)
    + [Setters](#setters)
    + [Getters](#getters)
* [Get player XP and Rank from other ESX resources](#get-player-xp-and-rank-from-other-esx-resources)
* [Client Event Listeners](#client-event-listeners)
* [Client Triggers](#client-triggers)
* [Server Triggers](#server-triggers)
* [UI](#ui)
* [Commands](#commands)
* [Demo Commands](#demo-commands)
* [FAQ](#faq)
    - [Does this use  VenomXNL's XNLRankBar?](#does-this-use--venomxnls-xnlrankbar)
    - [How do I change the look of the UI?](#how-do-i-change-the-look-of-the-ui-)
    - [How do I lock a weapon / vehicle / unlockable to a rank?](#how-do-i-lock-a-weapon---vehicle---unlockable-to-a-rank-)
* [Contributing](#contributing)
* [Legal](#legal)


## Demos
You can find an interactive demo [here](https://codepen.io/Mobius1/full/yLeMwzO).

##### Increasing XP

![Demo Image 1](https://i.imgur.com/CpACt9s.gif)

##### Rank Up

![Demo Image 2](https://i.imgur.com/uNPRGo5.gif)

##### Mini Leaderboard
![Demo Image 3](https://i.imgur.com/vOY7xpI.png)

## Requirements

* [es_extended](https://github.com/esx-framework/es_extended/tree/v1-final)

## Download & Installation

* Download and extract the package: https://github.com/Mobius1/esx_xp/archive/master.zip
* Rename the `esx_xp-master` directory to `esx_xp`
* Drop the `esx_xp` directory into your `resources` directory on your server
* Import the `esx_xp.sql` file into your db
* Add `ensure esx_xp` in your `server.cfg`
* Edit `config.lua` to your liking
* Start your server

## Upgrading to 1.0.0
* Rename the `rp_level` column in the `users` table to `rp_rank`

## Upgrading to 1.3.0
As of `1.3.0` the ranks are now stored as nested tables instead of the previous 1D array of XP values and have been moved to `ranks.lua`.


Old structure
```lua
Config.Ranks = {
    0,
    800,
    2100,
    3800,
    6100,
    ...
}
```

New structure
```lua
Config.Ranks = {
    { XP = 0 },
    { XP = 800 },
    { XP = 2100 },
    { XP = 3800 },
    { XP = 6100 },
    ...
}
```

If you have your own script accessing the ranks table, you'll need to update it, e.g.

Old method:
```lua
local rank4XP = Config.Ranks[4]
```

New method:
```lua
local rank4XP = Config.Ranks[4].XP
```

## Configuration

The `config.lua` file is set to emulate GTA:O as close as possible, but can be changed to fit your own needs.

```lua
Config.Enabled      = true  -- enable / disable the resource
Config.Locale       = 'en'  -- Current language
Config.Width        = 532   -- Sets the width of the XP bar in px
Config.Timeout      = 5000  -- Sets the interval in ms that the XP bar is shown before fading out
Config.BarSegments  = 10    -- Sets the number of segments the XP bar has. Native GTA:O is 10
Config.UIKey        = 20    -- The key that toggles the UI - default is "Z"

Config.Leaderboard = {
    Enabled     = true,     -- Enable the leaderboard
    ShowPing    = true,     -- Show player pings on the leaderboard
    Order       = "rank",   -- Order the player list by "name", "rank" or "id"
    PerPage     = 12        -- Max players to show per page    
}
```

The `ranks.lua` file contains the ranks / XP / callbacks. Each rank must have the `XP` key with the required XP to reach the rank as the value.

You can pass an optional callback using the `Action` key:

```lua
Config.Ranks = {
    { XP = 0 }, -- Rank 1
    {           -- Rank 2
        XP = 800,
        Action = function(xPlayer, rankUp, prevRank)
        
            -- Function is called when the player hits this rank

            -- xPlayer: table       - The player's ESX player data
            -- rankUp: boolean      - whether the player reached or dropped to this rank
            -- prevRank: number     - the player's previous rank

        end
    },
    { XP = 2100 }, -- Rank 3
    { XP = 3800 }, -- Rank 4
    ...
}
```

## Functions

### Setters

Set initial XP rank for player
```lua
exports.esx_xp:ESXP_SetInitial(xp --[[ integer ]])
```

Set Rank for player. This will add the required XP to advance the player to the given rank.
```lua
exports.esx_xp:ESXP_SetRank(rank --[[ integer ]])
```

Give player XP
```lua
exports.esx_xp:ESXP_Add(xp --[[ integer ]])
```

Remove XP from player
```lua
exports.esx_xp:ESXP_Remove(xp --[[ integer ]])
```

### Getters

Get player's current XP
```lua
exports.esx_xp:ESXP_GetXP()
```

Get player's current rank
```lua
-- Get rank from current XP
exports.esx_xp:ESXP_GetRank()

-- or

-- Get rank from given XP
exports.esx_xp:ESXP_GetRank(xp --[[ integer ]])

```

Get XP required to advance the player to the next rank
```lua
exports.esx_xp:ESXP_GetXPToNextRank()
```

Get XP required to advance the player to the given rank
```lua
exports.esx_xp:ESXP_GetXPToRank(rank --[[ integer ]])
```

Get max attainable XP
```lua
exports.esx_xp:ESXP_GetMaxXP()
```

Get max attainable rank
```lua
exports.esx_xp:ESXP_GetMaxRank()
```

### Utils
Show the UI
```lua
ESXP_ShowUI()

-- update the leaderboard at the same time

ESXP_ShowUI(true)
```

Hide the UI
```lua
ESXP_HideUI()
```

Show the UI and hide after timeout
```lua
ESXP_TimeoutUI()
```

Sort the leaderboard
```lua
ESXP_SortLeaderboard("rank")

-- or

ESXP_SortLeaderboard("name")
```


## Get player XP and Rank from other ESX resources
If you want to access the players xp and / or rank in other `ESX` resources:

Client
```lua
local xPlayer = ESX.GetPlayerData()

local playerXP = xPlayer.xp
local playerRank = xPlayer.rank
```

Server
```lua
local xPlayer = ESX.GetPlayerFromId(source)

local playerXP = xPlayer.get("xp")
local playerRank = xPlayer.get("rank")
```

## Client Event Listeners

Wait for `esx_xp` to be ready for use
```lua
AddEventHandler("esx_xp:ready", function(data --[[ table ]])
    local currentXP     = data.xp
    local currentRank   = data.rank
    local xPlayer       = data.player
    
    -- esx_xp is ready for use
end)
```

Listen for rank change events. These can be used to reward / punish the player for changing rank.

Listen for rank-up event
```lua
AddEventHandler("esx_xp:rankUp", function(newRank --[[ integer ]], previousRank --[[ integer ]])
    -- Do something when player ranks up
end)
```
Listen for rank-down event
```lua
AddEventHandler("esx_xp:rankDown", function(newRank --[[ integer ]], previousRank --[[ integer ]])
    -- Do something when player drops a rank
end)
```

## UI
The UI can be toggled with the `Z` key by default. The UI will fade out after the interval defined by `Config.Timeout` or you can close it immediately with the `Z` key.

The leaderboard is paginated and can be navigated with arrow keys. The number of players displayed per page can be customised with the `PerPage` variable.

You can customise the UI key with `Config.UIKey` in `config.lua`.

The data in the leaderboard is refreshed whenever it is opened so you get up-to-date information.

## Commands
Get current XP stats
```lua
/ESXP
```
output
```lua
You currently have xxxx XP
Your current rank is xxxx
You require xxxx XP to advance to rank yyyy
```

## Demo Commands

These commands are for testing and will change the UI, but no data will be saved.

If these are not required, you can delete the `demo.lua` file and remove it's entry in the `fxmanifest.lua` file.

Set initial XP
```lua
/ESXP_SetInitial xp
```

Add XP
```lua
/ESXP_Add xp
```

Remove XP
```lua
/ESXP_Remove xp
```

Add fake player to leaderboard
```lua
/ESXP_AddFakePlayer
```

Add number of fake players to leaderboard
```lua
/ESXP_AddFakePlayer count
```

Remove all fake players from leaderboard
```lua
/ESXP_RemoveFakePlayers
```

Sort the leaderboard
```lua
/ESXP_SortLeaderboard order --[[ rank or name ]]
```

## Admin Commands

This require you to set ace permissions, i.e `add_ace group.admin command.esxp_give allow`

Give XP to player:
`/esxp_give [playerId] [xp]`

Take XP from player
`/esxp_take [playerId] [xp]`

Set player's XP
`/esxp_set [playerId] [xp]`

Set player's rank
`/esxp_rank [playerId] [rank]`

## FAQ

#### Does this use  VenomXNL's `XNLRankBar`?

No. I thought about using it, but I created a HTML5 version of the GTA:O rankbar so I could have greater control / customisation. You can see the base system I created [here](https://codepen.io/Mobius1/pen/yLeMwzO).

#### How do I change the look of the UI?

With a little knowledge of HTML5,  CSS3 and JS you can change all aspects of the look and layout of the bar to make it fit with your UI. The main structure is defined in `html/ui.html`, the main style is defined in `html/css/app.css` and scripting is defined in `html/js/app.js`.

You can find a demo of customised UI [here](https://codepen.io/Mobius1/full/eYJRmVy)

#### How do I lock a weapon / vehicle / unlockable to a rank?

To lock something to a rank you can listen for the `esx_xp:rankUp` or `esx_xp:rankDown` events:

Example of unlocking the minigun at rank 10:
```lua
AddEventHandler("esx_xp:rankUp", function(newRank, previousRank)
    if newRank == 10 then
        GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_MINIGUN"), 100, false, false)
    end
end)
```

If player ranks down then you can remove it:
```lua
AddEventHandler("esx_xp:rankDown", function(newRank, previousRank)
    if newRank < 10 then
        local player = PlayerPedId()
        local weapon = GetHashKey("WEAPON_MINIGUN")
        
        if HasPedGotWeapon(player, weapon, false) then
            RemoveWeaponFromPed(player, weapon)
        end
    end
end)
```

## Contributing
Pull requests welcome.

## Legal

### License

esx_xp - FiveM XP System

Copyright (C) 2020 Karl Saunders

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
