# esx_xp
Adds an XP leveling system like the one found in GTA:O

## Features
* Designed to emulate the native GTA:O system
* Saves and loads players XP / level
* Add / remove XP from your own script / job
* Allows you listen for level changes to reward players
* Fully customisable UI

## Demo
You can find an interactive demo [here](https://codepen.io/Mobius1/full/yLeMwzO).

##### Increasing XP

![Demo Image 1](https://i.imgur.com/CpACt9s.gif)

##### Level Up

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
Config.Levels = {}          -- XP levels. Must be a table of integers with the first element being 0.
```

## Functions

### Setters

Set initial XP level for player
```lua
exports.esx_xp:XP_SetInitial(xp --[[ integer ]])
```

Set Level for player. This will add the required XP to advance the player to the given level.
```lua
exports.esx_xp:XP_SetLevel(level --[[ integer ]])
```

Give player XP
```lua
exports.esx_xp:XP_Add(xp --[[ integer ]])
```

Remove XP from player
```lua
exports.esx_xp:XP_Remove(xp --[[ integer ]])
```

### Getters

Get player's current XP
```lua
exports.esx_xp:XP_GetXP()
```

Get player's current level
```lua
exports.esx_xp:XP_GetLevel()
```

Get XP required to advance the player to the next level
```lua
exports.esx_xp:XP_GetXPToNextLevel()
```

Get XP required to advance the player to the given level
```lua
exports.esx_xp:XP_GetXPToLevel(level --[[ integer ]])
```

Get max attainable XP
```lua
exports.esx_xp:XP_GetMaxXP()
```

Get max attainable level
```lua
exports.esx_xp:XP_GetMaxLevel()
```

## Client Event Listeners

Listen for level change events. These can be used to reward / punish the player for changing level.

Listen for level-up event
```lua
AddEventHandler("esx_xp:levelUp", newLevel --[[ integer ]], previousLevel --[[ integer ]])
```
Listen for level-down event
```lua
AddEventHandler("esx_xp:levelDown", newLevel --[[ integer ]], previousLevel --[[ integer ]])
```

## Server Triggers

Each of these triggers will save the player's XP as well as update their UI in real-time

Set player's initial XP
```lua
TriggerEvent("esx_xp:XP_SetInitial", source --[[ integer ]], XP --[[ integer ]])
```

Give XP to player
```lua
TriggerEvent("esx_xp:XP_Add", source --[[ integer ]], XP --[[ integer ]])
```

Remove XP from player
```lua
TriggerEvent("esx_xp:XP_Remove", source --[[ integer ]], XP --[[ integer ]])
```

## Commands
Get current XP stats
```lua
/XP
```
output
```lua
You currently have xxxx XP
Your current level is xxxx
You require xxxx XP to advance to level yyyy
```

## To Do
* Allow globe / level colour change based on level
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