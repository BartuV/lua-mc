# Lua-MC

Lua-MC is a minecraft datapack compiler 

## Installation

Use the package manager [luarocks](luarocks.org) to install foobar.

```bash
luarocks install lua-mc
```

## Usage

If cant decide which version to choose go visit the [minecraft wiki](https://minecraft.fandom.com/wiki/Data_pack#Pack_format) 

```lua
local lua-mc = require "lua-mc"
local app = {
   version = 1-9,
   description = "something",
   location = "/home/BartuBartu/Desktop/Lua",
   name = "a",
   elements = {
       
   }
}
--add some stuff in there

gamerule.doDaylightCycle(true,"load")
player.team.new("test","load")
player.team.new("default","load")
player.team.set_default("default")

--at the end of the file
compile(app)
```



## License
[MIT](https://choosealicense.com/licenses/mit/)