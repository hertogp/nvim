-- File: keymappings.lua
local nmap = function(keys, cmd, opts)
  vim.keymap.set('n', keys, cmd, opts)
end

local imap = function(keys, cmd, opts)
  vim.keymap.set('i', keys, cmd, opts)
end

-- GENERIC
local opts = {noremap = true, silent = true}

--[[ editing ]]
nmap('Q', 'gq}', opts)
nmap('Y', 'y$', opts) -- yank till eol, like D deletes till eol
-- use <M-j> to split a line, like <S-j> combines lines
-- note: cannot use ^M to insert a newline apparently (using ^V<return>)
-- that works alright in Vim script, but here it trips up lua-format (!)
nmap('<m-j>', 'i<cr><esc>', opts)
imap('<c-p>', '<c-p><c-n>', opts) -- invoke keyword completion
imap('<c-n>', '<c-n><c-p>', opts) -- invoke keyword completion

--[[ coding ]]
-- TODO: MyNeomakeVar seems to be missing
nmap('<space>?', '<cmd>call MyNeomakeVar("current_errors")<cr>', opts)
nmap('<f2>', '<cmd>NeomakeClean<cr>', opts)
nmap('<space><f2>', '<cmd>NeomakeClean<cr>', opts)
nmap('<f3>', '<cmd>Neomake! makeprg<cr>', opts)
nmap('<space><f3>', '<cmd>NeomakeClean!<cr>', opts)

-- keep centered when jumping
nmap('<c-n>', '<cmd>nohl<cr>', opts)
nmap('n', 'nzz', opts)
nmap('N', 'Nzz', opts)
nmap('*', '*zz', opts)
nmap('#', '#zz', opts)
-- :jumps shows the window's jump list
nmap('<c-o>', '<c-o>zz', opts) -- jumps to entry above current
nmap('<c-i>', '<c-i>zz', opts) -- jumps to entry below current
nmap('<c-u>', '<c-u>zz', opts) -- :h CTRL-u -> scroll window upward
nmap('<c-d>', '<c-d>zz', opts) -- scroll window downard

-- save & redo/undo
imap('jj', '<esc>', opts)
nmap('R', '<c-r>', opts) -- R(edo), u is already undo and r(eplace) is taken
imap('<c-s>', '<esc><cmd>update<cr>', opts)
nmap('<c-s>', '<cmd>update<cr>', opts)
-- function kyes
nmap('<f5>', ':redraw!', opts)

-- navigate splits
nmap('H', ':<c-u>tabprevious<cr>', opts)
nmap('L', ':<c-u>tabnext<cr>', opts)
nmap('<c-j>', '<c-w>j', opts)
nmap('<c-k>', '<c-w>k', opts)
nmap('<c-l>', '<c-w>l', opts)
nmap('<c-h>', '<c-w>h', opts)
nmap('<c-p>', '<c-w>p', opts)

local builtin = require "telescope.builtin"

-- resume last telescope action
nmap('<space><space>', builtin.resume, opts)

-- FIND FILES
-- navigate diagnostics
nmap('<space>d', builtin.diagnostics, opts)
-- until e gets mapped somewhere else.
nmap('<space>e', builtin.diagnostics, opts)

-- find files respecting .gitignore
nmap('<space>f', builtin.find_files, opts)

-- find all files
nmap('<space>F', ':lua require"telescope.builtin".find_files({hidden=true})<cr>', opts)

-- grep for word under cursor (or anything if not on a word)
nmap('<space>g', builtin.grep_string, opts)
nmap('<space>G', builtin.live_grep, opts)

-- filter lines of current buffer
nmap('<space>l', builtin.current_buffer_fuzzy_find, opts)

-- search document SymbolsOutline
nmap('<space>s', builtin.lsp_document_symbols, opts)

-- TODO: would like ' o' to search current buffer and  ' O' files in project dir.
nmap('<space>o', ':lua require"telescope.builtin".grep_string({search="TODO|FIXME|XXX", use_regex=true})<cr>', opts)

-- show markdown outline
-- nmap('<space>m', ':lua require"telescope.builtin".grep_string({search="^#+", use_regex=true})<cr>', opts)
-- search for man pages of all categories
nmap('<space>M', ':lua require"telescope.builtin".man_pages({sections={"ALL"}})<cr>', opts)
-- list and pick a buffer
nmap('<space>b', builtin.buffers, opts)
nmap('<space>B', ':lua require"telescope.builtin".buffers({show_all_buffers=true})<cr>', opts)
-- vim help
nmap('<space>h', builtin.help_tags, opts)

-- quickfix and window loc list
nmap('<space>q', builtin.quickfix, opts)
nmap('<space>w', builtin.loclist, opts)

-- neoterm
nmap('<space>t', ':call ReplStart(expand("<cWORD>"))<cr>', opts)
nmap('<space>r', ':call ReplRun()<cr>', opts)

-- VOoM -- hasn't been updated in years
-- https://github.com/vim-voom/VOoM
-- using symbolsoutline instead
nmap('<space>v', '<cmd>SymbolsOutline<cr>', opts)
nmap('<space>V', '<cmd>VoomToggle<cr>', opts)

--[[ leader keys ]]
-- TODO: at some point, change it to init.lua
nmap('<leader>ev', '<cmd>edit ~/.config/nvim/init.lua<cr>', opts)
nmap('<leader>sv', '<cmd>source ~/.config/nvim/init.lua<cr>', opts)
