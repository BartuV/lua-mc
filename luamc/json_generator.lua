local json = require "lunajson"
local ext = os.exit()
local eansi = require "eansi"
error = function(text)print(eansi.toansi "bold red" .. text .. eansi "")end;info  = function(text)print(eansi.toansi "bold bright_green" .. text .. eansi "")end;warn  = function(text)print(eansi.toansi "bold bright_yellow" .. text .. eansi "") end

function generate_colored_text(text,color)
    if not type(color) == "string" then
        error("color must be a minecraft default color name or a hex color")
        ext()
    end
    local base = {
        ["text"] = text,
        ["color"] = color
    }
end