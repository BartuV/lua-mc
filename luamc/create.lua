local eansi = require "eansi"
local log = {error = function(text)print(eansi.toansi "bold red" .. text .. eansi "")end;info  = function(text)print(eansi.toansi "bold bright_green" .. text .. eansi "")end;warn  = function(text)print(eansi.toansi "bold bright_yellow" .. text .. eansi "") end}
local json = require "lunajson"
--[[
    writen by BartuV
    github profile: github.com/BartuV
    github project: github.com/BartuV/LuaMC
]]--

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
        log.error("Could not open file" .. source)
    end
end

--write a function that edits a file but dont overwrite the existing contents in the file
function edit_file_dont_overwrite(file, command)
    local file = io.open(file, "a")
    if file then
        file:write(command .. "\n")
        file:close()
    else
        log.error("Could not open file" .. file)
    end
end

local function copy_directory_rename(source, destination,name)
    local lfs = require "lfs"
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

local function rename(old,new)
    os.rename(old,new)
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