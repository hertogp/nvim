-- setup language servers.
-- https://github.com/neovim/nvim-lspconfig
-- generic keymaps
local on_attach = function(client, bufnr)
  local opts = {noremap = true, silent = true, buffer = bufnr}

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.keymap.set('n', 'E', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'td', ':Telescope diagnostics<cr>', opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- [[elixir_ls]]
-- https://github.com/elixir-lsp/elixir-ls
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#elixirls

require'lspconfig'.elixirls.setup({
  cmd = {"/home/pdh/.config/lsp/elixir-ls/release/language_server.sh"},
  on_attach = on_attach,
  capabilities = capabilities
})

-- [[luau_lsp]]
-- This NOT Lua but a derivative, see https://luau-lang.org/

-- [[ LUA ]]
-- see ~/.config/lsp/lua-language-server/
-- neodev.vim
-- https://github.com/folke/neodev.nvim
-- setup neodev BEFORE any other lsp
require'neodev'.setup({})

-- https://github.com/sumneko/lua-language-server
-- https://github.com/sumneko/lua-language-server/wiki/Configuration-File#neovim-with-built-in-lsp-client
local lua_lsp_root = vim.fn.expand("~/.config/lsp/lua-language-server")
require'lspconfig'.sumneko_lua.setup({
  cmd = {vim.fn.expand(lua_lsp_root .. "/bin/lua-language-server"), "-E", lua_lsp_root .. "/main.lua"},
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {globals = {'vim', 'use'}},
      runtime = {version = 'Lua 5.1', path = vim.split(package.path, ';')},
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = -- vim.api.nvim_get_runtime_file('', true)
        {
          -- [vim.fn.expand('$XDG_CONFIG_HOME/nvim')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/nvim/lsp')] = true
          -- [vim.fn.stdpath('config') .. '/lua'] = true,
        }
      }
    }
  }
})

--[[ LUA autoformatting ]]
-- uses efm-language server in combination with luaformatter
-- https://github.com/mattn/efm-langserver
-- https://github.com/Koihik/LuaFormatter
-- https://www.chrisatmachine.com/blog/category/neovim/28-neovim-lua-development
require'lspconfig'.efm.setup({
  init_options = {documentFormatting = true},
  filetypes = {"lua"},
  settings = {
    rootMarkers = {".git/"},
    languages = {
      lua = {
        {
          formatCommand = "lua-format -i --indent-width=2 --no-use-tab --no-keep-simple-control-block-one-line --no-keep-simple-function-one-line --no-break-after-operator --column-limit=150 --break-after-table-lb",
          formatStdin = true
        }
      }
    }
  }

})
