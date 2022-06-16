package = "lua-mc"
version = "1.0-1"
source = {
   url = "..." -- We don't have one yet
}
description = {
   summary = "An example for the LuaRocks tutorial.",
   detailed = [[
      This is an example for the LuaRocks tutorial.
      Here we would put a detailed, typically
      paragraph-long description.
   ]],
   homepage = "http://...", -- We don't have one yet
   license = "MIT/X11" -- or whatever you like
}
dependencies = {
   "lua >= 5.1, < 5.4",
   "luajson >= 1.3.4-1",
   "luafilesystem >= 1.8.0-1",
   "eansi >= 1.1-1"
}
build = {
   type = "builtin",
   modules = {
    compile = "../luamc/compile.lua",
    create = "../luamc/create.lua"
   }
}