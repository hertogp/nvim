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
-- require "setup.lsp-setup"
-- require "setup.symbols-outline-setup"
-- require "setup.lualine-setup"
-- require "setup.telescope-setup"
-- require "setup.tree-sitter-setup"
-- require "setup.nvim-cmp-setup"
-- require "setup.luasnip-setup"
-- etc...
