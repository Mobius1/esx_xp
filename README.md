# esx_xp
Adds an XP leveling system like the one found in GTA:O

## Features
* Saves and loads players XP / level
* Add / remove XP from your own script or job
* Allows you to set perks for levels

## Demo
##### Increasing XP

![Demo Image 1](https://i.imgur.com/wOT5bqg.gif)

##### Level Up

![Demo Image 2](https://i.imgur.com/ehxGWsd.gif)


## Requirements

* [es_extended](https://github.com/ESX-Org/es_extended)

## Download & Installation

* Download and extract the package: https://github.com/Mobius1/esx_xp/archive/master.zip
* Rename the `esx_xp-master` directory to `esx_xp`
* Drop the `esx_xp` directory into your `[esx]` directory on your server
* Add `start esx_xp` in your `server.cfg`
* Edit `config.lua` to your liking
* Start your server and rejoice!

## Usage

### Setters

Setting initial XP level
```lua
exports.esx_xp:XP_SetInitial(xp)
```

Adding XP
```lua
exports.esx_xp:XP_Add(xp)
```

Removing XP
```lua
exports.esx_xp:XP_Remove(xp)
```

### Getters

Getting current XP
```lua
exports.esx_xp:XP_GetXP()
```

Getting current level
```lua
exports.esx_xp:XP_GetLevel()
```

Getting XP needed to level-up
```lua
exports.esx_xp:XP_GetXPToNextLevel()
```
## Videos

* Coming soon...

## Contributing
Pull requests welcome.

## Legal

### License

esx_xp - FiveM XP System

Copyright (C) 2020 Karl Saunders

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.