local lfs = require "lfs"
local eansi = require "eansi"
local json = require "lunajson"
local tickfile
local loadfile
local main
local ext = os.exit()

--[[
    writen by BartuV
    github profile: github.com/BartuV
    github project: github.com/BartuV/LuaMC
]]--

error = function(text)print(eansi.toansi "bold red" .. text .. eansi "") ext() end;info  = function(text)print(eansi.toansi "bold bright_green" .. text .. eansi "")end;warn  = function(text)print(eansi.toansi "bold bright_yellow" .. text .. eansi "") end
local function isInteger(str) return not (str == "" or str:find("%D")) end

function copy(source, destination)
    local file = io.open(source, "rb")
    if file then
        local data = file:read()
        if data == nil then
           data = "" 
        end
        file:close()
        file = io.open(destination, "w")
        file:write(data)
        file:close()  
    else
        error("Could not open file" .. source)
    end
end

--write a function that edits a file but dont overwrite the existing contents in the file
function edit_file_dont_overwrite(file, command)
    local file = io.open(file, "a")
    if file then
        file:write(command .. "\n")
        file:close()
    else
        error("Could not open file" .. file)
    end
end

local function copy_directory_rename(source, destination,name)
    local rename1 = source .. "/example"
    local rename2 = source .. "/example/data/example"
    local index = 1;
    for file in lfs.dir(source) do
        if file ~= "." and file ~= ".." then
            local source_file = source .. "/" .. file
            local destination_file = destination .. "/" .. file
            if lfs.attributes(source_file, "mode") == "directory" then
                if file == "example" then
                    destination_file = destination .. "/" .. name
                else 
                    destination_file = destination .. "/" .. file
                end
                lfs.mkdir(destination_file)
                copy_directory_rename(source_file, destination_file,name)
            else
                copy(source_file, destination_file)
            end
        end 
    end
end

function edit_file(filepath, text)
    local file = io.open(filepath, "w")
    if file then
        file:write(text)
        file:close()
        return filepath
    end
end
    
local function replace(str, old, new)
    return (str:gsub(old, new))
end

local function edit_packmeta(version, description, packlocation)
    local packmeta = packlocation.. "/pack.mcmeta"
    local meta = {
        ["pack"] = {
            ["pack_format"] = 1,
            ["description"] = "",
        }
    }
    meta["pack"]["description"] = description
    meta["pack"]["pack_format"] = version
    local encode = json.encode(meta)
    edit_file(packmeta, encode)
end

local function edit_load(location, name)
    local load = location.."/data/minecraft/tags/functions/load.json"
    local meta = {
        ["values"] = {"example:load"}
    }
    local new = replace(meta["values"][1],"example",name)
    meta["values"][1] = new
    local encode = json.encode(meta)
    edit_file(load, encode)
end

local function edit_tick(location, name)
    local load = location.."/data/minecraft/tags/functions/tick.json"
    local meta = {
        ["values"] = {"example:tick"}
    }
    local new = replace(meta["values"][1],"example",name)
    meta["values"][1] = new
    local encode = json.encode(meta)
    edit_file(load, encode)
end

function create_pack(version,name,description,location)
    copy_directory_rename("./pack",location,name)
    edit_packmeta(version,description,location.."/"..name)
    edit_load(location.."/"..name,name)
    edit_tick(location.."/"..name,name)
end

--create a function that creates a file with given content
function create_file(filepath)
    local file = io.open(filepath, "w")
    if file then
        file:close()
    end
end

local app = {
    version = 9,
    description = "something",
    location = "/home/BartuBartu/Desktop/Lua",
    name = "a",
    elements = {
        
    },
}

function compile(app) 
    app = app
    test_app(app)
    create_pack(app.version, app.name, app.description, app.location)
    tickfile = app.location.."/"..app.name.."/data/"..app.name.."/functions/tick.mcfunction"
    loadfile = app.location.."/"..app.name.."/data/"..app.name.."/functions/load.mcfunction"
    main = app.location.."/"..app.name.."/data/"..app.name.."/functions"
    to_file(app.elements)
end

function test_app(app)
    if app.version < 1 or app.version > 10 then
        warn("Version must be between 1 and 9")
        warn("4 for versions 1.13 – 1.14.4")
        warn("5 for versions 1.15 – 1.16.1")
        warn("6 for versions 1.16.2 – 1.16.5")
        warn("7 for versions 1.17 - 1.17.1")
        warn("8 for versions 1.18 - 1.18.1")
        warn("9 for versions 1.18.2")
        warn("10 for versions 1.19+")
        os.exit()
    end
    if not isdir(app.location) then
        error("Please enter a valid filepath")
        os.exit()
    end
end

function isdir(path)
    if (lfs.attributes(path, "mode") == "directory") then
      return true
    end
    return false
end

function to_file(contents)
    local num = 1
    for _,v in pairs(contents) do
        if v[2] == "tick.mcfunction" then
            if num == 1 then
                edit_file(tickfile, "")
                num = num + 1
            end
            edit_file_dont_overwrite(tickfile, v[1])
        elseif v[2] == "load.mcfunction" then
            if num == 1 then
                edit_file(loadfile, "")
                num = num + 1
            end
            edit_file_dont_overwrite(loadfile, v[1])
        else
            create_file(main.."/"..v[2])
            if num == 1 then
                edit_file(main.."/"..v[2], "")
                num = num + 1
            end
            edit_file_dont_overwrite(main.."/"..v[2], v[1])
        end
    end
    num = 1
end

function add_command(app, command, file)
    app.elements[#app.elements + 1] = {command,file..".mcfunction"}
end

function dump(o) if type(o) == 'table' then local s = '{ ' for k,v in pairs(o) do if type(k) ~= 'number' then k = '"'..k..'"' end s = s .. '['..k..'] = ' .. dump(v) .. ',' end return s .. '} ' else return tostring(o) end end

--=============--
--##UTILITIES##--
--=============--

chat = {
    color=function(color)
        local colors = {["black"] = "0",["dark_blue"] = "1",["dark_green"] = "2",["dark_aqua"] = "3",["dark_red"] = "4",["dark_purple"] = "5",["gold"] = "6",["gray"] = "7",["dark_gray"] = "8",["blue"] = "9",["green"] = "a",["aqua"] = "b",["red"] = "c",["light_purple"] = "d",["yellow"] = "e",["white"] = "f",}
        return "§"..colors[color]
    end,
    
    style = function(style)
        local styles = {["bold"] = "l",["italic"] = "o",["underline"] = "n",["strikethrough"] = "m",["obfuscated"] = "k",["reset"] = "r"}
        return "§"..styles[style]
    end,
    
    log = function (text,file)
        app.elements[#app.elements + 1] = {"say @s '"..text.."'",file..".mcfunction"}
    end,

    log_with_hex = function (hex,text,file)
        app.elements[#app.elements + 1] = {"tellraw @s {".."text:"..'"'..text..'","color:#"'..tostring(hex)..'"}',file..".mcfunction"}
    end,
}

player = {
    scoreboard = {
        new = function (name,type,file)
            app.elements[#app.elements + 1] = {"scoreboard objectives add" .. name.." "..type,file..".mcfunction"}
        end,

        set = function (player,name,value,file)
            app.elements[#app.elements+1] = {"scoreboard players set "..player.." "..name.." "..tostring(value),file..".mcfunction"}
        end,

        add = function (player,name,value,file)
            app.elements[#app.elements+1] = {"scoreboard players add "..player.." "..name.." "..tostring(value),file..".mcfunction"}
        end,

        reset = function (player,name,file)
            app.elements[#app.elements+1] = {"scoreboard players reset "..player.." "..name,file..".mcfunction"}
        end,

        set_visible = function (name,where,file)
            app.elements[#app.elements+1] = {"scoreboard objectives setdisplay "..where.." "..name,file..".mcfunction"}
        end,

        subtract = function (player,name,value,file)
            app.elements[#app.elements+1] = {"scoreboard players remove "..player.." "..name.." "..tostring(value),file..".mcfunction"}
        end,

        swap = function (player,player2,name,file)
            app.elements[#app.elements+1] = {"scoreboard players operation "..player.." "..name.." >< "..player2.." "..name,file..".mcfunction"}
        end,

        divide = function (player,name,value,file)
            app.elements[#app.elements+1] = {"scoreboard players operation "..player.." "..name.." /= "..tostring(value),file..".mcfunction"}
        end,

        multiply = function (player,name,value,file)
            app.elements[#app.elements+1] = {"scoreboard players operation "..player.." "..name.." *= "..tostring(value),file..".mcfunction"}
        end,
    },

    team = {
        new = function (name,file)
            app.elements[#app.elements + 1] = {"team add "..name,file..".mcfunction"}
        end,

        join = function (name,file)
            app.elements[#app.elements + 1] = {"team join "..name.." @s",file..".mcfunction"}
        end,

        join_player = function (name,file,player)
            app.elements[#app.elements + 1] = {"team join "..name.." "..player,file..".mcfunction"}
        end,

        remove_player = function (name,file,player)
            app.elements[#app.elements + 1] = {"team remove "..name.." "..player,file..".mcfunction"}
        end,

        empty = function (name,file)
            app.elements[#app.elements + 1] = {"team empty "..name,file..".mcfunction"}
        end,

        set_default = function (default_team)
            app.elements[#app.elements + 1] = {"team join @a[team=]"..default_team,"tick.mcfunction"}
        end,

        color = function (name,color,file)
            local colors = {["black"] = "0",["dark_blue"] = "1",["dark_green"] = "2",["dark_aqua"] = "3",["dark_red"] = "4",["dark_purple"] = "5",["gold"] = "6",["gray"] = "7",["dark_gray"] = "8",["blue"] = "9",["green"] = "a",["aqua"] = "b",["red"] = "c",["light_purple"] = "d",["yellow"] = "e",["white"] = "f",}
            if colors[color] then
                app.elements[#app.elements + 1] = {"team modify "..name.." color "..color,file..".mcfunction"}
            else
                error("Please enter a valid minecraft chat color name")
                ext()
            end
        end,

        collide = function (name,mode,file)
            local lod = {["always"] = "always",["never"] = "never",["pushOtherTeams"] = "pushOtherTeams",["pushOwnTeam"] = "pushOwnTeam",}
            if lod[mode] == nil then
                error("This mode isnt valid"); info("Mode options are:"); info("always,"); info("never,"); info("pushOtherTeams,"); info("pushOwnTeam")
                ext()
            end
            app.elements[#app.elements + 1] = {"team modify "..name.." collisionRule "..mode,file..".mcfunction"}
        end,

        show_death_message = function (name,mode,file)
            local lod = {["always"] = "always",["never"] = "never",["hideForOtherTeams"] = "only_team",["hideForOwnTeam"] = "only_player",}
            if lod[mode] == nil then
                error("This mode isnt valid"); info("Mode options are:"); info("always,"); info("never,"); info("hideForOtherTeams,"); info("hideForOwnTeam")
                ext()
            end
            app.elements[#app.elements + 1] = {"team modify "..name.." deathMessageVisibility "..mode,file..".mcfunction"}
        end,

        frendly_fire = function (name,bool,file)
            if bool == true or bool == false then
                app.elements[#app.elements + 1] = {"team modify "..name.." friendlyFire "..tostring(bool),file..".mcfunction"}
            else
                error("Please enter a boolean")
            end
        end,

        name_tag_visible = function (name,mode,file)
            local lod = {["always"] = "always",["never"] = "never",["hideForOtherTeams"] = "only_team",["hideForOwnTeam"] = "only_player",}
            if lod[mode] == nil then
                error("This mode isnt valid"); info("Mode options are:"); info("always,"); info("never,"); info("hideForOtherTeams,"); info("hideForOwnTeam")
                ext()
            end
            app.elements[#app.elements + 1] = {"team modify "..name.." friendlyFire "..tostring(mode),file..".mcfunction"}
        end,

        see_frendly_invisibles = function (name,bool,file)
            if bool == true or bool == false then
                app.elements[#app.elements + 1] = {"team modify "..name.." seeFriendlyInvisibles "..tostring(bool),file..".mcfunction"}
            else
                error("Please enter a boolean")
            end
        end,

        add_prefix = function (name,json,file)
            app.elements[#app.elements + 1] = {"team modify "..name.." prefix "..json,file..".mcfunction"}
        end,

        add_suffix = function (name,json,file)
            app.elements[#app.elements + 1] = {"team modify "..name.." suffix "..json,file..".mcfunction"}
        end,
    }, 

    message = {
        send = function (player,message,file)
            app.elements[#app.elements + 1] = {"tellraw "..player.." "..json.encode(message),file..".mcfunction"}
        end,

        send_as = function (player,message,file)
            app.elements[#app.elements + 1] = {"execute as "..player.." "..json.encode(message),file..".mcfunction"}
        end,

        send_to_all = function (message,file)
            app.elements[#app.elements + 1] = {"tellraw @a "..json.encode(message),file..".mcfunction"}
        end,

        private_message = function (player,message,file)
            app.elements[#app.elements + 1] = {"msg "..player.." "..message,file..".mcfunction"}
        end,
    },

    teleport = {
        teleport = function (x,y,z,file)
            app.elements[#app.elements + 1] = {"tp @s"..tostring(x).." "..tostring(y).." "..tostring(z),file..".mcfunction"}
        end,

        teleport_player = function (player,x,y,z,file)
            app.elements[#app.elements + 1] = {"tp "..player.." "..tostring(x).." "..tostring(y).." "..tostring(z),file..".mcfunction"}
        end,

        teleport_player_to_player = function (player,to,file)
            app.elements[#app.elements + 1] = {"tp "..player.." "..to,file..".mcfunction"}
        end,
    }
}

gamerule = {
    announceAdvancements = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule announceAdvancements "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    commandBlocksEnabled = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule commandBlocksEnabled "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    commandBlockOutput = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule commandBlockOutput "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    disableElytraMovementCheck = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule disableElytraMovementCheck "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    disableRaids = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule disableRaids "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doDaylightCycle = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doDaylightCycle "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doEntityDrops = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doEntityDrops "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doFireTick = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doFireTick "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doInsomnia = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doInsomnia "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doImmediateRespawn = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doImmediateRespawn "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doLimitedCrafting = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doLimitedCrafting "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doMobLoot = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doMobLoot "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doMobSpawning = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doMobSpawning "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doPatrolSpawning = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doPatrolSpawning "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doTileDrops = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doTileDrops "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doTraderSpawning = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doTraderSpawning "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doWeatherCycle = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doWeatherCycle "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    doWardenSpawning = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule doWardenSpawning "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    drowningDamage = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule drowningDamage "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    fallDamage = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule fallDamage "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    fireDamage = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule fireDamage "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    forgiveDeadPlayers = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule forgiveDeadPlayers "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    freezeDamage = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule freezeDamage "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    functionCommandLimit = function (value,file)
        if type(value) == "number" then
            app.elements[#app.elements + 1] = {"gamerule functionCommandLimit "..tostring(value),file..".mcfunction"}
        else
            error("Please enter a number")
        end
    end,
    
    keepInventory = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule keepInventory "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    logAdminCommands = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule logAdminCommands "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    maxCommandChainLength = function (value,file)
        if type(value) == "number" then
            app.elements[#app.elements + 1] = {"gamerule maxCommandChainLength "..tostring(value),file..".mcfunction"}
        else
            error("Please enter a number")
        end
    end,

    maxEntityCramming = function (value,file)
        if type(value) == "number" then
            app.elements[#app.elements + 1] = {"gamerule maxEntityCramming "..tostring(value),file..".mcfunction"}
        else
            error("Please enter a number")
        end
    end,

    mobGriefing = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule mobGriefing "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    naturalRegeneration = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule naturalRegeneration "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    playersSleepingPercentage = function (value,file)
        if type(value) == "number" then
            app.elements[#app.elements + 1] = {"gamerule playersSleepingPercentage "..tostring(value),file..".mcfunction"}
        else
            error("Please enter a number")
        end
    end,

    pvp = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule pvp "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    randomTickSpeed = function (value,file)
        if type(value) == "number" then
            app.elements[#app.elements + 1] = {"gamerule randomTickSpeed "..tostring(value),file..".mcfunction"}
        else
            error("Please enter a number")
        end
    end,

    reducedDebugInfo = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule reducedDebugInfo "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    respawnBlocksExplode = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule respawnBlocksExplode "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    sendCommandFeedback = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule sendCommandFeedback "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    showCoordinates = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule showCoordinates "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    showDeathMessages = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule showDeathMessages "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    showTags = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule showTags "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    spawnRadius = function (value,file)
        if type(value) == "number" then
            app.elements[#app.elements + 1] = {"gamerule spawnRadius "..tostring(value),file..".mcfunction"}
        else
            error("Please enter a number")
        end
    end,

    spectatorsGenerateChunks = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule spectatorsGenerateChunks "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    tntExplodes = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule tntExplodes "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    universalAnger = function (bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"gamerule universalAnger "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,
}

advancement = {
    give_everything = function (player,file)
        app.elements[#app.elements + 1] = {"advancement grant "..player.." everything",file..".mcfunction"}
    end,

    remove_everything = function (player,file)
        app.elements[#app.elements + 1] = {"advancement revoke "..player.." everything",file..".mcfunction"}
    end,

    give_advancement = function (player,advancement,file)
        app.elements[#app.elements + 1] = {"advancement grant "..player.." only minecraft: "..advancement,file..".mcfunction"}
    end, 

    remove_advancement = function (player,advancement,file)
        app.elements[#app.elements + 1] = {"advancement revoke "..player.." only minecraft: "..advancement,file..".mcfunction"}
    end,
}

bossbar = {
    add = function (name,id,file)
        app.elements[#app.elements + 1] = {"bossbar add "..tostring(id).." "..name,file..".mcfunction"}
    end,

    remove = function (id,file)
        app.elements[#app.elements + 1] = {"bossbar remove "..tostring(id),file..".mcfunction"}
    end,

    list = function (file)
        app.elements[#app.elements + 1] = {"bossbar list",file..".mcfunction"}
    end,

    set_style = function (id,style,file)
        local lut = {["notched_10"]="sa",["notched_12"]="sa",["notched_20"]="sa",["notched_6"]="sa",["progress"]="sa"}
        if lut[style] then
            app.elements[#app.elements + 1] = {"bossbar set "..tostring(id).." style "..style,file..".mcfunction"}
        else
            info("Avaible styles: notched_10, notched_12, notched_20, notched_6, progress")
            info("You entered "..style)
            error("Enter a valid style")
        end
    end,

    set_color = function (id,color,file)
        local lut = {["blue"] = "a",["green"]="a",["pink"]="a",["purple"]="a",["red"]="a",["white"]="a",["yellow"]="a"}
        if lut[color] then
            app.elements[#app.elements + 1] = {"bossbar set "..tostring(id).." color "..lut[color],file..".mcfunction"}
        else
            info("colors are blue, green, pink, purple, red, white, yellow")
            info("you entered "..color)
            error("Please enter a valid color")
        end
    end,

    set_max = function (id,value,file)
        if type(value) == "number" then
            app.elements[#app.elements + 1] = {"bossbar set "..tostring(id).." max "..tostring(value),file..".mcfunction"}
        else
            error("Please enter a number")
        end
    end,

    set_name = function (id,name,file)
        app.elements[#app.elements + 1] = {"bossbar set "..tostring(id).." name "..name,file..".mcfunction"}
    end,

    set_players = function (id,players,file)
        app.elements[#app.elements + 1] = {"bossbar set "..tostring(id).." players "..players,file..".mcfunction"}
    end,

    set_value = function (id,value,file)
        if type(value) == "number" then
            app.elements[#app.elements + 1] = {"bossbar set "..tostring(id).." value "..tostring(value),file..".mcfunction"}
        else
            error("Please enter a number")
        end
    end,

    set_visible = function (id,bool,file)
        if type(bool) == "boolean" then
            app.elements[#app.elements + 1] = {"bossbar set "..tostring(id).." visible "..tostring(bool),file..".mcfunction"}
        else
            error("Please enter a boolean")
        end
    end,

    set_to_an_objective_value = function (id,type,objective,file)
        app.elements[#app.elements + 1] = {"execute store result bossbar "..tostring(id).." "..type.." run scoreboard add FakePlayer "..objective,file..".mcfunction"}
    end,
}

ban = {
    ban_player = function (player,file)
        app.elements[#app.elements + 1] = {"ban "..player,file..".mcfunction"}
    end,

    ban_player_with_message = function (player,message,file)
        app.elements[#app.elements + 1] = {"ban "..player.." "..message,file..".mcfunction"}
    end,

    ip_ban_player = function (player,file)
        app.elements[#app.elements + 1] = {"ban-ip "..player,file..".mcfunction"}
    end,

    ip_ban_player_with_message = function (player,message,file)
        app.elements[#app.elements + 1] = {"ban-ip "..player.." "..message,file..".mcfunction"}
    end,

    unban_player = function (player,file)
        app.elements[#app.elements + 1] = {"pardon "..player,file..".mcfunction"}
    end,

    unban_ip_player = function (player,file)
        app.elements[#app.elements + 1] = {"pardon-ip "..player,file..".mcfunction"}
    end,

    ban_list = function (type,file)
        if type == "players" or type == "ips" then
            app.elements[#app.elements + 1] = {"banlist "..type,file..".mcfunction"}
        else
            error("Please enter players or ips")
        end
    end,
}

summon = {
    spawn = function (entitytype,x,y,z,file)
        app.elements[#app.elements + 1] = {"summon "..entitytype.." "..tostring(x)..","..tostring(y)..","..tostring(z),file..".mcfunction"}
    end,

    spawn_with_nbt = function (entitytype,x,y,z,nbt,file)
        app.elements[#app.elements + 1] = {"summon "..entitytype.." "..tostring(x)..","..tostring(y)..","..tostring(z).." "..nbt,file..".mcfunction"}
    end,
}

fill = {
    fill = function (x1,y1,z1,x2,y2,z2,block,file)
        app.elements[#app.elements + 1] = {"fill "..tostring(x1)..","..tostring(y1)..","..tostring(z1).." "..tostring(x2)..","..tostring(y2)..","..tostring(z2).." "..block,file..".mcfunction"}
    end,

    replace = function (x1,y1,z1,x2,y2,z2,block,filter_block,file)
        app.elements[#app.elements + 1] = {"fill "..tostring(x1)..","..tostring(y1)..","..tostring(z1).." "..tostring(x2)..","..tostring(y2)..","..tostring(z2).." "..block.." replace "..filter_block,file..".mcfunction"}
    end,

    hollow = function (x1,y1,z1,x2,y2,z2,block,file)
        app.elements[#app.elements + 1] = {"fill "..tostring(x1)..","..tostring(y1)..","..tostring(z1).." "..tostring(x2)..","..tostring(y2)..","..tostring(z2).." "..block.." hollow",file..".mcfunction"}
    end,

    keep = function (x1,y1,z1,x2,y2,z2,block,file)
        app.elements[#app.elements + 1] = {"fill "..tostring(x1)..","..tostring(y1)..","..tostring(z1).." "..tostring(x2)..","..tostring(y2)..","..tostring(z2).." "..block.." keep",file..".mcfunction"}
    end,

    outline = function (x1,y1,z1,x2,y2,z2,block,file)
        app.elements[#app.elements + 1] = {"fill "..tostring(x1)..","..tostring(y1)..","..tostring(z1).." "..tostring(x2)..","..tostring(y2)..","..tostring(z2).." "..block.." outline",file..".mcfunction"}
    end,
}

clear = function(player,file)
    app.elements[#app.elements + 1] = {"clear "..player,file..".mcfunction"}
end

clone = {

}