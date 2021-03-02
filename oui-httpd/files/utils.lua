local utils = require "oui.utils.core"

function utils.readfile(name, n)
    local f = io.open(name, "r")
    if not f then return nil end
    local data = f:read(n or "*a")
    f:close()
    return data
end

function utils.writefile(name, data)
    local f = io.open(name, "w")
    if not f then return nil end
    f:write(data)
    f:close()
    return true
end

return utils
