-- setup language servers.
-- https://github.com/neovim/nvim-lspconfig

-- generic keymaps
local on_attach = function(client, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.keymap.set('n','E', vim.diagnostic.open_float, opts)
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
-- https://github.com/sumneko/lua-language-server
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#luau_lsp

  require'lspconfig'.luau_lsp.setup({
    cmd = {"/home/pdh/.config/lsp/lua-language-server/bin/lua-language-server"},
    filetypes = { "lua", "luau" },
    on_attach = on_attach,
    capabilities = capabilities
  })
