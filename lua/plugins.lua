--  plugins.lua

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  --[[ LSP's ]]
  --
  -- Elixir
  -- see ~/.config/lsp/elixir-ls
  --
  -- Lua
  -- https://github.com/sumneko/lua-language-server
  -- see ~/.config/lsp/lua-language-server/
  --
  -- LSP configuration
  -- https://github.com/neovim/nvim-lspconfig
  use 'neovim/nvim-lspconfig'


  --[[ Telescope ]]
  -- alo installed  ~/installs/ripgrep and sudo apt install fd-find
  -- https://github.com/nvim-telescope/telescope.nvim
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
  }

  -- Treesitter
  -- https://github.com/nvim-treesitter/nvim-treesitter
  -- :TSInstall <language_to_install>
  -- `-> https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
  }

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
      'f3fora/cmp-spell',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'octaltree/cmp-look',
      'quangnguyen30192/cmp-nvim-ultisnips'
    }
  }
  use {
      'tzachar/cmp-tabnine',
      run = './install.sh',
      requires = 'hrsh7th/nvim-cmp'
  }

  -- colorschemes
  -- https://github.com/ackyshake/Spacegray.vim
  use 'ackyshake/Spacegray.vim'

  -- https://github.com/ellisonleao/gruvbox.nvim
  use 'ellisonleao/gruvbox.nvim'

  -- https://github.com/glepnir/zephyr-nvim
  -- use "glepnir/zephyr-nvim"
  use({
    'glepnir/zephyr-nvim',
    requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
  })

  -- https://github.com/Mofiqul/dracula.nvim
  use 'Mofiqul/dracula.nvim'

  -- https://github.com/nvim-lua/plenary.nvim
  use 'nvim-lua/plenary.nvim'

  -- https://github.com/nvim-telescope/telescope.nvim
 use {
  'nvim-telescope/telescope.nvim', tag = '0.1.0',
  requires = { {'nvim-lua/plenary.nvim'} }
 }

 --[[ Languages ]]

 -- Lua
 -- https://github.com/WolfgangMehner/lua-support
 use 'WolfgangMehner/lua-support'

 -- Elixir
 use 'elixir-editors/vim-elixir'
 use 'mhinz/vim-mix-format'

 --[[ Terminal ]]
 use 'kassio/neoterm'


 -- https://github.com/andymass/vim-matchup
 use {
    'andymass/vim-matchup',
    setup = function()
      -- may set any options here
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end
  }
  -- JSON
  -- https://github.com/Quramy/vison
  -- use 'Quramy/vison'
  -- https://github.com/elzr/vim-json
  -- use 'elzr/vim-json'

  -- Snippets
  -- https://github.com/SirVer/ultisnips -- old
  use 'SirVer/ultisnips' -- old

  -- Snippets Lua style
  -- https://github.com/L3MON4D3/LuaSnip
  -- use "L3MON4D3/LuaSnip"

  -- Make
  -- https://github.com/neomake/neomake
  use 'neomake/neomake'
  --https://github.com/sbdchd/neoformat
  --use 'sbdchd/neoformat'


  -- Code Navigation
  -- https://github.com/preservim/tagbar -- old
  -- https://github.com/stevearc/aerial.nvim
  -- use 'majutsushi/tagbar' -- old

  -- Coding
  -- https://github.com/rstacruz/vim-closer
  use 'rstacruz/vim-closer'

  -- https://github.com/tpope/vim-commentary
  use 'tpope/vim-commentary'
  -- https://github.com/tpope/vim-endwise
  use 'tpope/vim-endwise'
  -- https://github.com/tpope/vim-fugitive
  use 'tpope/vim-fugitive'
  -- https://github.com/tpope/vim-surround
  use 'tpope/vim-surround'

  -- https://github.com/tomtom/tgpg_vim
  use 'tomtom/tgpg_vim'

  -- Outliners
  -- https://github.com/vim-scripts/VOOM
  use 'vim-voom/VOoM'

  -- https://github.com/simrat39/symbols-outline.nvim
  use 'simrat39/symbols-outline.nvim'

  -- https://github.com/nvim-lualine/lualine.nvim
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
end)
