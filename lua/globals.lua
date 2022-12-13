-- lua/globals.lua

--[[ :h vim_diff ]]
-- https://neovim.io/doc/user/vim_diff.html
-- https://neovim.io/doc/user/vim_diff.html#nvim-defaults

--[[ global functions ]]

-- inspect a value and return it.
P = function(value)
  print(vim.inspect(value))
  return value
end

local g=vim.g
local o=vim.o

--[[ global name space ]]
g.mapleader = "\\"
g.netrw_browsex_viewer = "xdg-open"
g.neomake_open_list = 2
g.neomake_list_height = 20
g.neomake_javascript_enabled_makers = { 'eslint' }
g.neomake_scss_enabeld_makers = { 'stylelint' }
g.neomake_python_pylint_exe = 'pylint3'
g.neomake_python_enabled_makers = {'pylint', 'flake8'}
g.neomake_elixir_enabled_makers = { 'credo' }

g.jsx_ext_required = 0
g.jsx_ext_required = 1
g.jsdoc_allow_input_prompt = 1
g.jsdoc_input_description = 1
g.jsdoc_return=0
g.jsdoc_return_type=0
g.vim_json_syntax_conceal = 0


g.neoterm_default_mod = 'vert'
-- automatically start a REPL works via the TREPLxx-commands
-- or use Topen iex -S mix
g.neoterm_auto_repl_cmd = 0
g.neoterm_direct_open_repl = 1
g.neoterm_autoscroll = 1

-- TODO use luasnip instead
g.UltiSnipsExpandTrigger="<c-j>"

--[[ options name space ]]

-- coding
-- haven't used this in a while, might need to check the order of the dirs listed
o.path = o.path .. ',./include,/usr/include/linux,/usr/include/x86_64-linux-gnu,/usr/local/include'

o.signcolumn = "yes"
o.updatetime = 300
o.cmdheight = 2
o.shortmess = o.shortmess .. 'c'
o.signcolumn = "yes"

o.hlsearch = true
o.wildmode = "longest,list:longest,full"
-- see :h E535
o.complete =".,w,b,u,t,k"
o.wildmenu = true
o.lazyredraw = true

o.wrap = false
o.whichwrap = "b,s,<,>,[,]"
o.sidescroll = 10
o.backspace="indent,eol,start"
o.smartindent = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.expandtab=true     -- use C-v<tab> for a real tab
o.history = 50
o.textwidth = 79     -- some filetypes override this
o.formatoptions = "tcrqn2j"
o.number = true
o.numberwidth = 4
o.ruler = true
o.showcmd = true
o.showmode = false
o.incsearch = true
o.laststatus = 2
o.showmatch = true
o.ignorecase = true
o.smartcase = true
o.autowrite = true  -- save before commands like :next and :make

o.mouse="a"
o.cursorline = true
-- vim.api.nvim_set_hl(0, 'CursorLine', { ctermbg = 234 })
vim.api.nvim_set_hl(0, 'ColorColumn', { ctermbg = "DarkGrey", ctermfg = "white" })
vim.api.nvim_set_hl(0, 'Pmenu',    { cterm={italic=true}, ctermfg='white', ctermbg='darkgrey' })
vim.api.nvim_set_hl(0, 'PmenuSel', { cterm={italic = true}, ctermfg='white', ctermbg='darkblue' })
vim.api.nvim_set_hl(0, 'LineNr', { ctermfg=239, ctermbg=234 })
vim.fn.matchadd('ColorColumn', '\\%81v', 100)

o.termguicolors = true

-- clipboard
o.clipboard= "unnamed,unnamedplus"  -- register * for yanking, + for all y,d,c&p operations
o.list = true
-- o.listchars = "tab:→·\\ ,trail:░,precedes:◁ ,extends:▷"
o.listchars = "tab:→\\ ,trail:▓,precedes:◀,extends:▶"

o.splitright = true
