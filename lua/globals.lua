-- lua/globals.lua

--[[ :h vim_diff ]]
-- https://neovim.io/doc/user/vim_diff.html
-- https://neovim.io/doc/user/vim_diff.html#nvim-defaults

--[[ global functions ]]
--
-- inspect a value and return it.
P = function(value)
  print(vim.inspect(value))
  return value
end

local g=vim.g    -- namespace for global variables
local go=vim.go  -- namespace for global options
local api = vim.api

--[[ global variables ]]

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

-- for pw <file>
g.tgpgOptions = '-q --batch --force-mdc --no-secmem-warning'

g.neoterm_default_mod = 'vert'
-- automatically start a REPL works via the TREPLxx-commands
-- or use Topen iex -S mix
g.neoterm_auto_repl_cmd = 0
g.neoterm_direct_open_repl = 1
g.neoterm_autoscroll = 1

g.UltiSnipsExpandTrigger="<c-j>"
-- TODO use luasnip instead

--[[ global options ]]

go.startofline = false
-- are these in vim.go namespace of vim.o namespace?
-- TODO: packpath defaults to runtimepath, so is this necessary?
go.packpath=go.runtimepath

--[[ global user commands ]]

-- Show
-- run a vim command and show it's output, e.g.
-- - Show let b:      -- show all buffer variables in a new tab
-- - Show lua =vim    -- show the lua vim table
-- - Show map         -- show all mappings
local function show_in_tab(t)
  -- x = vim.api.nvim_exec(t.args, x)
  local ok, x = pcall(function()
    local cmd = api.nvim_parse_cmd(t.args, {})
    local output = api.nvim_cmd(cmd, {output=true})
    -- return lines table, no newlines allowed by nvim_buf_set_lines()
    local lines = {}
    -- return vim.split(lines, "\r?\n", {trimempty = true}
    for line in output:gmatch("[^\r\n]+") do
      table.insert(lines, line)
    end
    return lines
  end)

  -- open a new tab
  api.nvim_command('tabnew')
  -- set filetype=nofile  so 'q' just works in normal mode
  -- api.nvim_buf_set_option(0, 'filetype', 'nofile')
  -- api.nvim_buf_set_option(0, 'buftype', 'nofile')
  api.nvim_buf_set_option(0, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(0, 'swapfile', false)
  api.nvim_buf_set_option(0, 'buflisted', false)
  api.nvim_buf_set_lines(0, 0, 0, false, {"Show " .. t.args, "-----"})

  -- insert results (good or bad) in the buffer
  if ok then
    api.nvim_buf_set_lines(0, -1, -1, false, x)
  else
     api.nvim_buf_set_lines(0, -1, -1, false, {"error", vim.inspect(x)})
   end

  api.nvim_buf_set_option(0, 'modified', false)
  api.nvim_buf_set_keymap(0, 'n', 'q', '<cmd>close<cr>', {noremap=true, silent=true})
end
api.nvim_create_user_command('Show', show_in_tab, {complete='shellcmd', nargs='+'})
