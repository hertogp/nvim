--[[ buffer/window options ]]

local o=vim.o    -- namespace for buffer/window options

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
