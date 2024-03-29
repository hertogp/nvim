-- File: ~/.config/nvim/lua/keymappings.lua

local nmap = function(keys, cmd, opts)
  vim.keymap.set("n", keys, cmd, opts)
end

local imap = function(keys, cmd, opts)
  vim.keymap.set("i", keys, cmd, opts)
end

-- GENERIC
local opts = { noremap = true, silent = true }

--[[ editing ]]
nmap("Q", "gq}", opts)
nmap("q", "<Nop>", opts)
nmap("Y", "y$", opts) -- yank till eol, like D deletes till eol
-- use <M-j> to split a line, like <S-j> combines lines
nmap("<m-j>", "i<cr><esc>", opts)
imap("<c-p>", "<c-p><c-n>", opts) -- invoke keyword completion
imap("<c-n>", "<c-n><c-p>", opts) -- invoke keyword completion

-- [[ notes ]]
-- do not set cwd since that'll change the working directory
nmap(
  "<space>n",
  "<cmd>lua require'telescope.builtin'.find_files({search_dirs={'~/notes'}, search_file='md'})<cr>",
  opts
)

--[[ coding ]]
nmap("<f2>", "<cmd>NeomakeClean<cr>", opts)
nmap("<space><f2>", "<cmd>NeomakeClean<cr>", opts)
nmap("<f3>", "<cmd>Neomake! makeprg<cr>", opts)
nmap("<space><f3>", "<cmd>NeomakeClean!<cr>", opts)

-- snippits, use Ctrl-Space
local ls = require "luasnip"
-- move forward in snippet
vim.keymap.set({ "i", "s" }, "<c-j>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, opts)
-- if you need a digraph, simply do :Show digraphs en copy the char
-- with Ctrl-V,y and get something like →
-- move backwards in snippet
vim.keymap.set({ "i", "s" }, "<c-k>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, opts)
-- select within a list of options
vim.keymap.set({ "i", "s" }, "<c-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, opts)
-- reload snippets
nmap("<leader>ss", '<cmd>lua require"luasnip.loaders.from_lua".load()<cr>', opts)

-- keep centered when jumping
nmap("<c-n>", "<cmd>nohl<cr>", opts)
nmap("n", "nzz", opts)
nmap("N", "Nzz", opts)
nmap("*", "*zz", opts)
nmap("#", "#zz", opts)
-- :jumps shows the window's jump list
nmap("<c-o>", "<c-o>zz", opts) -- jumps to entry above current
nmap("<c-i>", "<c-i>zz", opts) -- jumps to entry below current
-- keep cursor centered when scrolling
nmap("<c-u>", "<c-u>zz", opts) -- :h CTRL-u -> scroll window upward
nmap("<c-d>", "<c-d>zz", opts) -- scroll window downard

-- save & redo/undo
imap("jj", "<esc>", opts)
nmap("R", "<c-r>", opts) -- R(edo), u is already undo and r(eplace) is taken
imap("<c-s>", "<esc><cmd>SaveKeepPos<cr>", opts)
nmap("<c-s>", "<cmd>SaveKeepPos<cr>", opts)
-- function kyes
nmap("<f5>", ":redraw!", opts)

-- navigate splits
nmap("H", ":<c-u>tabprevious<cr>", opts)
nmap("L", ":<c-u>tabnext<cr>", opts)
nmap("<c-j>", "<c-w>j", opts)
nmap("<c-k>", "<c-w>k", opts)
nmap("<c-l>", "<c-w>l", opts)
nmap("<c-h>", "<c-w>h", opts)
nmap("<c-p>", "<c-w>p", opts)

local builtin = require "telescope.builtin"

-- resume last telescope action
nmap("<space><space>", builtin.resume, opts)

-- FIND FILES
-- navigate diagnostics
nmap("<space>d", builtin.diagnostics, opts)
-- until e gets mapped somewhere else.
nmap("<space>e", builtin.diagnostics, opts)

-- find files respecting .gitignore, works from current working directory
nmap("<space>f", builtin.find_files, opts)
nmap("<space>F", ':lua require"telescope.builtin".find_files({hidden=true})<cr>', opts) -- find hidden files
-- TODO: telescope files relative to buffer directory
nmap(
  "<leader>f",
  "<cmd>lua require 'telescope.builtin'.find_files({cwd=vim.fn.expand('%:p:h')})<cr>",
  opts
)
nmap(
  "<leader>F",
  "<cmd>lua require 'telescope.builtin'.find_files({hidden=true, cwd=vim.fn.expand('%:p:h')})<cr>",
  opts
)
-- `-> expand('%:p:h') will give the buffer location in the filesystem

-- grep for word under cursor (or anything if not on a word)
nmap("<space>g", builtin.grep_string, opts)
nmap("<space>G", builtin.live_grep, opts)

-- filter lines of current buffer
-- nmap('<space>l', builtin.current_buffer_fuzzy_find, opts)
-- See https://github.com/nvim-telescope/telescope.nvim/issues/2192, so we use:
-- nmap("<space>l", Pdh_find_in_buf, opts)
nmap("<space>l", "<cmd>lua require'pdh.telescope'.find_in_buf()<cr>", opts)
nmap("<space>L", function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require("telescope.builtin").current_buffer_fuzzy_find(
    require("telescope.themes").get_dropdown { winblend = 10, previewer = false }
  )
end, { desc = "[/] Fuzzily search in current buffer]" })

-- search document SymbolsOutline
nmap("<space>o", "<cmd>lua require'pdh.outline'.toggle()<cr>")
nmap("<space>O", "<cmd>SymbolsOutline<cr>")
nmap("<space>s", builtin.lsp_document_symbols, opts)

-- search todo, fixme, xxx's etc.., either in local buffer or in cwd and lower
nmap("<space>t", ':lua require"pdh.telescope".todos({buffer=true})<cr>', opts)
nmap("<space>T", ':lua require"pdh.telescope".todos({})<cr>', opts)

-- show markdown outline oO0
nmap("<space>m", "<cmd>Telescope heading<cr>", opts)
-- search for man pages of all categories
nmap("<space>M", ':lua require"telescope.builtin".man_pages({sections={"ALL"}})<cr>', opts)
-- list and pick a buffer
-- nmap("<space>b", builtin.buffers, opts)
nmap("<space>b", "<cmd>lua require'pdh.telescope'.buffers({sort_mru=true})<cr>", opts)
nmap(
  "<space>B",
  ':lua require"telescope.builtin".buffers({hidden=true, show_all_buffers=true,  sort_mru=true})<cr>',
  opts
)

-- codespell to find spelling mistakes
-- TODO:
-- - make <space>c codespell the current buffer only
-- - make <space>C codespell the current project (respecting .codespellrc)
nmap("<space>c", "<cmd>lua require'pdh.telescope'.codespell(0)<cr>", opts)
nmap("<space>C", "<cmd>lua require'pdh.telescope'.codespell()<cr>", opts)

-- vim help
nmap("<space>h", builtin.help_tags, opts)

-- quickfix and window loc list
nmap("<space>q", builtin.quickfix, opts)
nmap("<space>w", builtin.loclist, opts)

-- neoterm
-- nmap("<space>t", ':call ReplStart(expand("<cWORD>"))<cr>', opts)
-- nmap("<space>r", ":call ReplRun()<cr>", opts)

--[[ OUTLINE ]]
-- VOoM -- hasn't been updated in years
-- https://github.com/vim-voom/VOoM
-- using symbolsoutline instead
nmap("<space>v", "<cmd>lua require'pdh.telescope'.outline()<cr>", opts)
nmap("<space>V", "<cmd>VoomToggle<cr>", opts)

--[[ leader keys ]]
nmap("<leader>ev", "<cmd>edit ~/.config/nvim/init.lua<cr>", opts)
nmap("<leader>sv", "<cmd>source ~/.config/nvim/init.lua<cr>", opts)
nmap("<leader><leader>x", "<cmd>write|source %<cr>", opts)
nmap("<leader><leader>X", "<cmd>write|source %<cr>", opts)

--[[ DEBUGGING ]]
nmap("<F8>", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
nmap(
  "<S-F8>",
  "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  opts
)
nmap("<F9>", "<cmd>lua require'dap'.continue()<CR>", opts)
nmap("<F10>", "<cmd>lua require'dap'.step_over()<CR>", opts)
nmap("<S-F10>", "<cmd>lua require'dap'.step_into()<CR>", opts)
-- F11/F12 toggle terminal stuff, so neovim won't see those.
nmap("<S-F11>", "<cmd>lua require'dap'.step_out()<CR>", opts)
nmap("<S-F12>", "<cmd>lua require'dap.ui.widgets'.hover()<cr>", opts)
nmap(
  "<Leader>lp",
  " <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
  opts
)
nmap("<Leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", opts)
nmap("<Leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", opts)
