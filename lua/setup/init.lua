-- File: ~/.config/nvim/lua/setup/init.lua
-- init.lua requires "setup" -> which runs this file
-- source all *other* files in this directory.
for file in vim.fs.dir "~/.config/nvim/lua/setup" do
  if file ~= "init.lua" then
    file = string.gsub(file, ".lua$", "")
    require("setup." .. file)
  end
end

--[[ manual method ]]
-- require "setup.lsp-config"
-- require "setup.symbols-outline-config"
-- require "setup.lualine-config"
-- require "setup.telescope-config"
-- require "setup.tree-sitter-config"
-- require "setup.nvim-cmp-config"
-- require "setup.luasnip-config"
