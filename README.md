# esx_xp
Adds an XP ranking system like the one found in GTA:O

## Features
* Designed to emulate the native GTA:O system
* Saves and loads players XP / rank
* Add / remove XP from your own script / job
* Allows you listen for rank changes to reward players
* Fully customisable UI

============================================================================
#### NOTE: The API may change until v1.0.0 so check back regularly for any changes.
#### NOTE 2: v1.0.0 will have the ESX dependency removed
============================================================================

## Demo
You can find an interactive demo [here](https://codepen.io/Mobius1/full/yLeMwzO).

##### Increasing XP

![Demo Image 1](https://i.imgur.com/CpACt9s.gif)

##### Rank Up

![Demo Image 2](https://i.imgur.com/uNPRGo5.gif)


## Requirements

* [es_extended](https://github.com/ESX-Org/es_extended)

## Download & Installation

* Download and extract the package: https://github.com/Mobius1/esx_xp/archive/master.zip
* Rename the `esx_xp-master` directory to `esx_xp`
* Drop the `esx_xp` directory into your `[esx]` directory on your server
* Add `start esx_xp` in your `server.cfg`
* Edit `config.lua` to your liking
* Start your server and rejoice!

## Configuration

The `config.lua` file is set to emulate GTA:O as close as possible, but can be changed to fit your own needs.

```lua
Config.Enabled = true       -- enable / disable the resource
Config.Locale = 'en'        -- Current language
Config.Width = 532          -- Sets the width of the XP bar in px
Config.Timeout = 5000       -- Sets the interval in ms that the XP bar is shown after updating
Config.BarSegments = 10     -- Sets the number of segments the XP bar has. Native GTA:O is 10
Config.Ranks = {}          -- XP ranks. Must be a table of integers with the first element being 0.
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

## Client Event Listeners

Listen for rank change events. These can be used to reward / punish the player for changing rank.

Listen for rank-up event
```lua
AddEventHandler("esx_xp:rankUp", newRank --[[ integer ]], previousRank --[[ integer ]])
```
Listen for rank-down event
```lua
AddEventHandler("esx_xp:rankDown", newRank --[[ integer ]], previousRank --[[ integer ]])
```

## Server Triggers

Each of these triggers will save the player's XP as well as update their UI in real-time

Set player's initial XP
```lua
TriggerEvent("esx_xp:setInitial", source --[[ integer ]], XP --[[ integer ]])
```

Give XP to player
```lua
TriggerEvent("esx_xp:addXP", source --[[ integer ]], XP --[[ integer ]])
```

Remove XP from player
```lua
TriggerEvent("esx_xp:removeXP", source --[[ integer ]], XP --[[ integer ]])
```

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

## To Do
* Allow globe / rank colour change based on rank
* Make non-ESX (platform agnostic) version available

## Contributing
Pull requests welcome.

## Legal

### License

esx_xp - FiveM XP System

Copyright (C) 2020 Karl Saunders

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.