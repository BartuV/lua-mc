local create = require "create"
local lfs = require "lfs"
local eansi = require "eansi"
local tickfile
local loadfile
local main
local ext = os.exit()
error = function(text)print(eansi.toansi "bold red" .. text .. eansi "")end;info  = function(text)print(eansi.toansi "bold bright_green" .. text .. eansi "")end;warn  = function(text)print(eansi.toansi "bold bright_yellow" .. text .. eansi "") end

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
    for i,v in pairs(contents) do
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
}

