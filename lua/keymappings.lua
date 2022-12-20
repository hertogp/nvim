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
nmap("Y", "y$", opts) -- yank till eol, like D deletes till eol
-- use <M-j> to split a line, like <S-j> combines lines
nmap("<m-j>", "i<cr><esc>", opts)
imap("<c-p>", "<c-p><c-n>", opts) -- invoke keyword completion
imap("<c-n>", "<c-n><c-p>", opts) -- invoke keyword completion
-- find notes
nmap(
  "<space>n",
  "<cmd>lua require'telescope.builtin'.find_files({cwd='~/notes/', search_dirs={'~/notes'}})<cr>",
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
nmap("<c-u>", "<c-u>zz", opts) -- :h CTRL-u -> scroll window upward
nmap("<c-d>", "<c-d>zz", opts) -- scroll window downard

-- save & redo/undo
imap("jj", "<esc>", opts)
nmap("R", "<c-r>", opts) -- R(edo), u is already undo and r(eplace) is taken
imap("<c-s>", "<esc><cmd>update<cr>", opts)
nmap("<c-s>", "<cmd>update<cr>", opts)
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

-- find files respecting .gitignore
nmap("<space>f", builtin.find_files, opts)
nmap("<space>F", ':lua require"telescope.builtin".find_files({hidden=true})<cr>', opts) -- find hidden files

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
nmap("<space>s", builtin.lsp_document_symbols, opts)

-- search todo, fixme and xxx's, either in local buffer or in cwd and lower
nmap("<space>t", ':lua require"pdh.telescope".todos({buffer=true})<cr>', opts)
nmap("<space>T", ':lua require"pdh.telescope".todos({})<cr>', opts)

-- show markdown outline
nmap("<space>m", "<cmd>Telescope heading<cr>", opts)
-- search for man pages of all categories
nmap("<space>M", ':lua require"telescope.builtin".man_pages({sections={"ALL"}})<cr>', opts)
-- list and pick a buffer
-- nmap("<space>b", builtin.buffers, opts)
nmap("<space>b", "<cmd>lua require'pdh.telescope'.buffers()<cr>", opts)
nmap("<space>B", ':lua require"telescope.builtin".buffers({show_all_buffers=true})<cr>', opts)

-- vim help
nmap("<space>h", builtin.help_tags, opts)

-- quickfix and window loc list
nmap("<space>q", builtin.quickfix, opts)
nmap("<space>w", builtin.loclist, opts)

-- neoterm
-- nmap("<space>t", ':call ReplStart(expand("<cWORD>"))<cr>', opts)
-- nmap("<space>r", ":call ReplRun()<cr>", opts)

-- VOoM -- hasn't been updated in years
-- https://github.com/vim-voom/VOoM
-- using symbolsoutline instead
nmap("<space>v", "<cmd>SymbolsOutline<cr>", opts)
nmap("<space>V", "<cmd>VoomToggle<cr>", opts)

--[[ leader keys ]]
nmap("<leader>ev", "<cmd>edit ~/.config/nvim/init.lua<cr>", opts)
nmap("<leader>sv", "<cmd>source ~/.config/nvim/init.lua<cr>", opts)
