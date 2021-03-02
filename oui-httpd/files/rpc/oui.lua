local sqlite3 = require "lsqlite3"
local utils = require "oui.utils"
local cjson = require "oui.json"
local rpc = require "oui.rpc"
local uci = require "uci"

local M = {}

local RPC_OUI_MENU_FILES = "/usr/share/oui/menu.d/*.json"

local function menu_files(files)
    for _, file in ipairs(files) do
        local f = io.open(file)
        if not f then return false end
        f:close()
    end

    return true
end

function M.get_lang()
    local c = uci.cursor()

    return { lang = c:get("oui", "main", "lang") }
end

function M.set_lang(params)
    local c = uci.cursor()

    if type(params.lang) ~= "string" then
        return rpc.ERROR_CODE_INVALID_PARAMS
    end

    c:set("oui", "main", "lang", params.lang)
    c:commit("oui")

    return { lang = c:get("oui", "main", "lang") }
end

function M.menu(params)
    local menus = {}

    local f = io.popen("ls " .. RPC_OUI_MENU_FILES .. " 2>/dev/null")
    if f then
        for file in f:lines() do
            local menu = cjson.decode(utils.readfile(file))

            for path, item in pairs(menu) do
                local access, files = true, true
                local tmp = {}

                for k, v in pairs(item) do
                    if k == "files" then
                        files = menu_files(v)
                    else
                        tmp[k] = v
                    end
                end

                if files and rpc.access("menu", "/" .. path, "r") then
                    menus[path] = tmp
                end
            end
        end
        f:close()
    end

    return {menu = menus}
end

function M.load_locales(params)
    local locales = {}

    if type(params.locale) ~= "string" then
        return rpc.ERROR_CODE_INVALID_PARAMS
    end

    local cmd = string.format("ls /www/i18n/*.%s.json 2>/dev/null", params.locale)

    local f = io.popen(cmd)
        if f then
        for file in f:lines() do
            local locale = cjson.decode(utils.readfile(file))
            locales[#locales + 1] = locale
        end
        f:close()
    end

    return locales
end

local function set_password(params)
    local username, password = params.username, params.password

    if type(username) ~= "string" or  type(password) ~= "string" then
        return rpc.ERROR_CODE_INVALID_PARAMS
    end

    local db = sqlite3.open("/etc/oui-httpd/oh.db")

    local found = false

    db:exec(string.format("SELECT password FROM account WHERE username = %s", username), function() found = true end)

    if not found then
        local aclgroup = username == "admin" and "admin" or ""
        db:exec(string.format("INSERT INTO account VALUES('%s', '', '%s')", username, aclgroup))
    end

    local hash = utils.md5(username, password)
    db:exec(string.format("UPDATE account SET password = '%s' WHERE username = '%s'", hash, username))

    db:close()
end

function M.set_password(params)
    local s = rpc.session()

    if s.aclgroup ~= "admin" and params.username ~= s.username then
        return rpc.ERROR_CODE_ACCESS
    end
    return set_password(params)
end

function M.first_login()
    local c = uci.cursor()

    return {
        first = c:get("oui", "main", "first") == "1"
    }
end

function M.first_set(params)
    if not M.first_login() then
        return rpc.ERROR_CODE_ACCESS
    end

    local c = uci.cursor()

    c:set("oui", "main", "lang", params.lang)
    c:set("oui", "main", "first", "0")
    c:commit("oui")

    return set_password(params)
end

return M
