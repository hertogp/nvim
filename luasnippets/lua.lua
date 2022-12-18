--[[ LUA SNIPPETS ]]
-- File:/home/pdh/.config/nvim/luasnippets/lua.lua
-- import some global functions to create snippets
local import = vim.fn.expand "$XDG_CONFIG_HOME/nvim/luasnippets/import.lua"
dofile(import)
print("loading snippets from " .. vim.fn.expand "%F")

local function last_label(name)
  local parts = vim.split(name[1][1], ".", { plain = true })
  return parts[#parts] or ""
end

return {
  snippet(
    "req",
    fmt([[local {} = require"{}"]], {
      f(last_label, { 1 }),
      i(1),
    })
  ),
}
