-- ALL snippets
-- File: /home/pdh/.config/nvim/luasnippets/all.lua
local import = vim.fn.expand "$XDG_CONFIG_HOME/nvim/luasnippets/import.lua"
dofile(import)
print("loading snippets from " .. vim.fn.expand "%F")

--[[ helpers ]]
local fname = function()
  return "File: " .. vim.fn.expand(vim.api.nvim_buf_get_name(0))
end

--[[ snippets ]]
return {

  snippet("xxx", {
    c(1, { t "-- FIXME: ", t "-- XXX: ", t "-- TODO: " }),
  }),

  snippet({
    trig = "file:",
    name = "File:",
    desc = "expands to filename of current buffer (if any)",
  }, {
    f(fname, {}),
  }),
}
