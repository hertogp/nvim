--  File: /home/pdh/.config/nvim/lua/plugins.lua
-- --[[ BOOTSTRAP ]]
-- see https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua
local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  vim.cmd [[packadd packer.nvim]]
end

return require("packer").startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  --{{ NEOVIM DOCS ]]
  use "nanotee/luv-vimdocs"
  use "milisims/nvim-luaref"

  --[[ LSP ]]
  -- https://github.com/sumneko/lua-language-server
  -- https://github.com/neovim/nvim-lspconfig
  use {
    "neovim/nvim-lspconfig",
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      -- https://github.com/williamboman/mason.nvim
      -- https://github.com/williamboman/mason-lspconfig.nvim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- Useful status updates for LSP
      "j-hui/fidget.nvim",

      -- Additional lua configuration, makes nvim stuff amazing
      "folke/neodev.nvim",
    },
  }

  --[[ TELESCOPE ]]
  -- https://github.com/nvim-telescope
  -- also installed  ~/installs/ripgrep and sudo apt install fd-find
  -- https://github.com/nvim-telescope/telescope.nvim
  use {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.0",
    requires = {
      "nvim-lua/plenary.nvim",
    },
  }

  -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  }

  --https://github.com/nvim-telescope/telescope-file-browser
  -- see https://www.youtube.com/watch?v=nQIJghSU9TU&list=RDLV-InmtHhk2qM&index=5
  use "nvim-telescope/telescope-file-browser.nvim"

  --[[ TREESITTER ]]
  -- https://github.com/nvim-treesitter/nvim-treesitter
  -- :TSInstall <language_to_install>
  -- `-> https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  use {
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update { with_sync = true }
      ts_update()
    end,
  }
  -- https://github.com/nvim-treesitter/playground
  use "nvim-treesitter/playground"

  -- https://github.com/crispgm/telescope-heading.nvim
  use "crispgm/telescope-heading.nvim"

  -- Completion
  -- https://github.com/folke/neodev.nvim
  -- must be setup BEFORE lspconfig
  use "folke/neodev.nvim"
  -- https://github.com/hrsh7th/nvim-cmp
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      -- completion sources
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "f3fora/cmp-spell",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "octaltree/cmp-look",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  }
  -- AI completion of some sort
  -- use {'tzachar/cmp-tabnine', run = './install.sh', requires = 'hrsh7th/nvim-cmp'}

  --[[ COLORS ]]
  -- https://github.com/ackyshake/Spacegray.vim
  use "ackyshake/Spacegray.vim"

  -- https://github.com/ellisonleao/gruvbox.nvim
  use "ellisonleao/gruvbox.nvim"
  -- https://github.com/lifepillar/vim-gruvbox8
  use "lifepillar/vim-gruvbox8"
  -- https://github.com/bluz71/vim-nightfly-colors
  use "bluz71/vim-nightfly-colors"
  -- https://github.com/glepnir/zephyr-nvim
  -- use "glepnir/zephyr-nvim"
  use { "glepnir/zephyr-nvim", requires = { "nvim-treesitter/nvim-treesitter", opt = true } }

  -- https://github.com/Mofiqul/dracula.nvim
  use "Mofiqul/dracula.nvim"

  -- https://github.com/nvim-lua/plenary.nvim
  use "nvim-lua/plenary.nvim"

  --[[ Languages ]]

  -- Lua
  -- https://github.com/WolfgangMehner/lua-support
  -- use "WolfgangMehner/lua-support"
  -- https://github.com/wesleimp/stylua.nvim
  use { "wesleimp/stylua.nvim" }

  -- Elixir
  -- https://github.com/elixir-editors/vim-elixir
  use "elixir-editors/vim-elixir"
  -- https://github.com/mhinz/vim-mix-format
  use "mhinz/vim-mix-format"

  --[[ Terminal ]]
  use "kassio/neoterm"

  -- https://github.com/andymass/vim-matchup
  use {
    "andymass/vim-matchup",
    setup = function()
      -- may set any options here
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  }
  -- JSON
  -- https://github.com/Quramy/vison
  -- use 'Quramy/vison'
  -- https://github.com/elzr/vim-json
  -- use 'elzr/vim-json'

  -- Snippets
  -- https://github.com/SirVer/ultisnips -- old
  -- use 'SirVer/ultisnips' -- old

  -- Snippets Lua style
  -- https://github.com/L3MON4D3/LuaSnip
  use "L3MON4D3/LuaSnip"

  -- Make
  -- https://github.com/neomake/neomake
  use "neomake/neomake"
  -- https://github.com/sbdchd/neoformat
  -- use 'sbdchd/neoformat'

  --[[ CODE NAVIGATION ]]
  -- https://github.com/preservim/tagbar -- old
  -- https://github.com/stevearc/aerial.nvim
  -- use 'majutsushi/tagbar' -- old

  -- Coding
  -- https://github.com/rstacruz/vim-closer
  use "rstacruz/vim-closer"
  -- https://github.com/tpope/vim-commentary
  -- use "tpope/vim-commentary"
  -- https://github.com/numToStr/Comment.nvim
  use {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  }
  -- https://github.com/tpope/vim-endwise
  use "tpope/vim-endwise"
  -- https://github.com/tpope/vim-fugitive
  -- use 'tpope/vim-fugitive'
  -- https://github.com/tpope/vim-surround
  use "tpope/vim-surround"

  --[[ DUBUGGING ]]
  -- neovim's debug adapter protocol implementation
  -- https://github.com/mfussenegger/nvim-dap
  use "mfussenegger/nvim-dap"
  -- https://github.com/rcarriga/nvim-dap-ui
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  -- https://github.com/theHamsta/nvim-dap-virtual-text
  use "theHamsta/nvim-dap-virtual-text"
  -- https://github.com/nvim-telescope/telescope-dap.nvim
  use "nvim-telescope/telescope-dap.nvim"

  -- adapters per language
  -- https://github.com/elixir-lsp/elixir-ls
  -- `-> the elixir dap server (already installed)
  -- LUA
  -- https://github.com/jbyuki/one-small-step-for-vimkind
  use "jbyuki/one-small-step-for-vimkind"
  -- `-> the dap server
  -- https://github.com/actboy168/lua-debug

  -- https://github.com/tomtom/tgpg_vim
  use "tomtom/tgpg_vim"

  --[[ OUTLINE ]]
  -- https://github.com/vim-scripts/VOOM
  -- TODO: keep it or not?
  use "vim-voom/VOoM"

  -- https://github.com/simrat39/symbols-outline.nvim
  use "simrat39/symbols-outline.nvim"

  --[[ STATUSLINE ]]
  -- https://github.com/nvim-tree/nvim-web-devicons
  -- Show lua =require"nvim-web-devicons".get_icons()  -- shows all icons
  use "kyazdani42/nvim-web-devicons"
  -- https://github.com/nvim-lualine/lualine.nvim
  use { "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } }

  if is_bootstrap then
    require("packer").sync()
  end
end)
