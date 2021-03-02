/*
 * MIT License
 *
 * Copyright (c) 2020 Jianhui Zhao <zhaojh329@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "lua2json.h"

static int json_encode(lua_State *L)
{
    bool encode_empty_table_as_array;
    json_t *ret;
    char *s;

    luaL_argcheck(L, lua_istable(L, 1), 1, "table expected");

    encode_empty_table_as_array = lua_toboolean(L, 2);

    ret = lua_to_json(L, 1, encode_empty_table_as_array);

    s = json_dumps(ret, 0);

    lua_pushstring(L, s);

    free(s);
    json_decref(ret);

    return 1;
}

static int json_decode(lua_State *L)
{
    const char *s = luaL_checkstring(L, 1);
    json_t *root = json_loads(s, 0, NULL);

    json_to_lua(root, L);

    json_decref(root);

    return 1;
}

static const luaL_Reg regs[] = {
    {"encode", json_encode},
    {"decode", json_decode},
    {NULL, NULL}
};

int luaopen_oui_json(lua_State *L)
{
#if LUA_VERSION_NUM <= 501
    luaL_register(L, "cjson", regs);
#else
    luaL_newlib(L, regs);
    lua_pushvalue(L, -1);
    lua_setglobal(L, "cjson");
#endif
    return 1;
}
