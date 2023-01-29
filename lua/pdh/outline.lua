-- File: ~/.config/nvim/lua/pdh/outline.lua
-- [[ Find outline for various filetypes ]]

--[[
Behaviour
- otl is toggle'd from a buffer in window x:
  * buffer has no b.otl -> create one, note x as otl.swin, select otl window
  * buffer has an b.otl -> close its window, remove b.otl, stay in current window
  * toggle should ignore calls when org window is a floating window
- when shuttle'ing, otl attaches to the win showing sbuf
- swin becomes invisible -> otl is hidden as well
- swin becomes visible   -> otl becomes visible again
- otl becomes invisible  -> otl is destroyed and sbuf.otl is removed and swin is selected
--]]

--[[ GLOBALS ]]

local M = {}

M.queries = {
  -- Treesitter queries that yield an outline for a given file type
  -- see https://github.com/elixir-lang/tree-sitter-elixir/tree/main/queries
  elixir = [[
    ((comment) @head (#lua-match? @head "^[%s#]+%[%[[^\n]+%]%]$"))
    (((call (identifier) @x) (#any-of? @x "defmodule" "use" "alias" "def" "defp")) @head)
    (((unary_operator (call (identifier) @h)) @head) (#not-any-of? @h "spec" "doc" "moduledoc"))
  ]],

  lua = [[
    ((comment) @head (#lua-match? @head "^--%[%[[^\n]+%]%]$"))
    ((function_declaration) @head)
    ((assignment_statement) @head)
    ((variable_declaration) @head)
    ]],

  markdown = [[
    (section (atx_heading) @head)
    (setext_heading (paragraph) @head)
  ]],
}

M.depth = {
  elixir = 2,
  lua = 1,
  markdown = 6,
}

--[[ BUFFER funcs ]]

local function buf_sanitize(buf)
  -- return a real, valid buffer number or nil
  if buf == nil or buf == 0 then
    return vim.api.nvim_get_current_buf()
  elseif vim.api.nvim_buf_is_valid(buf) then
    return buf
  end
  return nil
end

--[[ WINDOW funcs ]]

local function win_centerline(win, linenr)
  -- try to center linenr in window win
  if vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_win_set_cursor, win, { linenr, 0 })
    vim.api.nvim_win_call(win, function()
      vim.cmd "normal! zz"
    end)
  end
end

local function win_isvalid(winid)
  if type(winid) == "number" then
    return vim.api.nvim_win_is_valid(winid)
  else
    return false
  end
end

local function win_close(winid)
  -- safely close a window by its id.
  if win_isvalid(winid) then
    vim.api.nvim_win_close(winid, true)
  end
end

local function win_goto(winid)
  if winid == 0 or winid == vim.api.nvim_get_current_win() then
    return
  end
  if vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
  end
end

--[[ TS funcs ]]

local function ts_depth(node, root)
  -- how deep is node relative to root?
  local depth = 0
  local p = node:parent()
  while p and p ~= root do
    depth = depth + 1
    p = p:parent()
  end
  return depth
end

local function ts_outline(bufnr)
  -- return two lists: {linenrs}, {lines} based on a filetype specific TS query
  local ft = vim.bo[bufnr].filetype
  local max_depth = M.depth[ft] or 0
  local qry = M.queries[ft]
  if qry == nil then
    vim.notify("[WARN] unsupported filetype: " .. ft, vim.log.levels.WARN)
    return {}, {}
  end

  local query = vim.treesitter.parse_query(ft, qry)
  local parser = vim.treesitter.get_parser(bufnr, ft, {})
  local tree = parser:parse()
  local root = tree[1]:root()

  local blines = {}
  local idx = {}
  local lines
  for id, node, _ in query:iter_captures(root, 0, 0, -1) do
    local depth = ts_depth(node, root)
    local capture = query.captures[id]

    local linenr = node:range() -- ignore start_col, end_row, end_col
    local prev_line = idx[#idx] or -1 -- use -1 when `idx` is still empty
    if depth <= max_depth and capture == "head" and linenr ~= prev_line then
      lines = vim.treesitter.query.get_node_text(node, bufnr, { concat = false })

      if #lines > 0 then
        blines[#blines + 1] = " " .. lines[1]
        idx[#idx + 1] = linenr + 1
      end
    end
  end
  return idx, blines
end

--[[ OTL funcs ]]

---get outline, set otl.idx and fill otl.obuf with lines
---@param otl table
local function otl_outline(otl)
  -- get the outline for otl.sbuf & create/fill owin/obuf if needed
  -- local lines = { " one", " ten", " twenty", " thirty", " sixty", " hundred" }
  -- otl.idx = { 1, 10, 20, 30, 60, 100 }
  local idx, lines = ts_outline(otl.sbuf)
  otl.idx = idx
  otl.tick = vim.b[otl.sbuf].changedtick
  if otl.owin == nil then
    vim.api.nvim_command "noautocmd topleft 40vnew"
    otl.obuf = vim.api.nvim_get_current_buf()
    otl.owin = vim.api.nvim_get_current_win()
  end
  vim.api.nvim_buf_set_option(otl.obuf, "modifiable", true)
  vim.api.nvim_buf_set_lines(otl.obuf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(otl.obuf, "modifiable", false)
  return otl
end

---sync otl table between src/dst
---@param otl table
local function otl_sync(otl)
  -- store otl as src/dst buffer variable, assumes a valid otl
  -- alt: vim.b[otl.obuf].otl = otl
  vim.api.nvim_buf_set_var(otl.obuf, "otl", otl)
  vim.api.nvim_buf_set_var(otl.sbuf, "otl", otl)
  return otl
end

local function otl_settings(otl)
  -- otl window options
  vim.api.nvim_win_set_option(otl.owin, "list", false)
  vim.api.nvim_win_set_option(otl.owin, "winfixwidth", true)
  vim.api.nvim_win_set_option(otl.owin, "number", false)
  vim.api.nvim_win_set_option(otl.owin, "signcolumn", "no")
  vim.api.nvim_win_set_option(otl.owin, "foldcolumn", "0")
  vim.api.nvim_win_set_option(otl.owin, "relativenumber", false)
  vim.api.nvim_win_set_option(otl.owin, "wrap", false)
  vim.api.nvim_win_set_option(otl.owin, "spell", false)
  vim.api.nvim_win_set_option(otl.owin, "cursorline", true)
  vim.api.nvim_win_set_option(otl.owin, "winhighlight", "CursorLine:Visual")

  -- otl buffer
  vim.api.nvim_buf_set_name(otl.obuf, "Otl #" .. otl.obuf)
  vim.api.nvim_buf_set_option(otl.obuf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(otl.obuf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(otl.obuf, "buflisted", false)
  vim.api.nvim_buf_set_option(otl.obuf, "swapfile", false)
  vim.api.nvim_buf_set_option(otl.obuf, "modifiable", false)
  vim.api.nvim_buf_set_option(otl.obuf, "filetype", "otl-outline")

  -- otl keymaps
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(otl.obuf, "n", "q", "<cmd>lua require'pdh.outline'.close()<cr>", opts)

  local up = "<cmd>lua require'pdh.outline'.up()<cr>"
  local down = "<cmd>lua require'pdh.outline'.down()<cr>"
  vim.api.nvim_buf_set_keymap(otl.obuf, "n", "<Up>", up, opts)
  vim.api.nvim_buf_set_keymap(otl.obuf, "n", "K", up, opts)
  vim.api.nvim_buf_set_keymap(otl.obuf, "n", "<Down>", down, opts)
  vim.api.nvim_buf_set_keymap(otl.obuf, "n", "J", down, opts)

  local shuttle = "<cmd>lua require'pdh.outline'.shuttle()<cr>"
  vim.api.nvim_buf_set_keymap(otl.obuf, "n", "<cr>", shuttle, opts)
  vim.api.nvim_buf_set_keymap(otl.sbuf, "n", "<cr>", shuttle, opts)

  -- otl autocmds
  vim.api.nvim_create_augroup("OtlAuGrp", { clear = true })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    -- last window showing sbuf closed -> close otl.
    buffer = otl.sbuf,
    group = "OtlAuGrp",
    desc = "OTL wipe otl window and vars",
    callback = function()
      if vim.b[otl.sbuf].otl then
        -- triggered by something else than M.toggle
        M.close(otl.sbuf)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    -- the otl buffer is going away (switch buf or close window)
    buffer = otl.obuf,
    group = "OtlAuGrp",
    desc = "OTL wipe otl window and vars",
    callback = function()
      if vim.b[otl.obuf].otl then
        -- triggered by something else than M.toggle
        M.close(otl.sbuf)
      end
    end,
  })
  vim.api.nvim_create_autocmd("WinEnter", {
    -- Upon entering the otl window -> check changedtick & update if necessary
    buffer = otl.obuf,
    group = "OtlAuGrp",
    desc = "OTL maybe update outline",
    callback = function()
      if vim.b[otl.obuf].otl then
        local otick = otl.tick
        local stick = vim.b[otl.sbuf].changedtick
        if stick > otick then
          otl_outline(otl)
        end
      end
    end,
  })
end

local function otl_nosettings(otl)
  -- remove otl keymaps in sbuf
  pcall(vim.api.nvim_buf_del_keymap, otl.sbuf, "n", "<cr>")

  -- remove otl autogrp
  pcall(vim.api.nvim_del_augroup_by_name, "OtlAuGrp")
end

local function otl_select(sline)
  -- given the linenr in sbuf (sline), find the closest match in otl.idx
  -- and move to the associated otl buffer line (oline)
  local line = 1
  local otl = vim.b[0].otl
  if otl then
    for otl_line, idx in ipairs(otl.idx) do
      if idx <= sline then
        line = otl_line
      end
    end
    vim.api.nvim_win_set_cursor(otl.owin, { line, 0 })
  end
end

--[[ MODULE ]]

M.open = function(buf)
  -- open otl window for given buf number
  buf = buf_sanitize(buf)

  if vim.b[buf].otl then
    vim.notify("[error](open) otl already exists?", vim.log.levels.ERROR)
    return
  end

  local otl = {}

  -- create new otl window with outline
  otl.sbuf = buf
  otl.swin = vim.api.nvim_get_current_win()
  otl_outline(otl)
  otl_settings(otl)
  otl_sync(otl)
  local line = vim.api.nvim_win_get_cursor(otl.swin)[1]
  otl_select(line)
end

M.close = function(buf)
  -- close otl window, move to swin
  buf = buf_sanitize(buf)
  if buf == nil then
    vim.notify("[error](close) invalid buffer number", vim.log.levels.ERROR)
    return
  end

  local otl = vim.b[buf].otl
  if otl == nil then
    -- nothing todo
    return
  end

  -- wipe the otl association
  otl_nosettings(otl)
  vim.b[otl.sbuf].otl = nil
  vim.b[otl.obuf].otl = nil

  win_close(otl.owin)
  win_goto(otl.swin)
end

M.shuttle = function()
  -- move back and forth between the associated otl windows
  local buf = vim.api.nvim_get_current_buf()
  local otl = vim.b[buf].otl

  if otl == nil then
    -- noop since there isn't an otl available
    return
  end

  local win = vim.api.nvim_get_current_win()
  local line = vim.api.nvim_win_get_cursor(win)[1]

  if buf == otl.sbuf then
    -- shuttle in *a* window showing sbuf, adopt it as swin and moveto otl
    otl.swin = win
    otl_sync(otl)
    win_goto(otl.owin)
    otl_select(line)
    return
  end

  if win_isvalid(otl.swin) and otl.sbuf == vim.api.nvim_win_get_buf(otl.swin) then
    -- shuttle called in the otl window and swin still shows sbuf
    line = otl.idx[line]
    win_goto(otl.swin)
    win_centerline(otl.swin, line)
    return
  end

  -- shuttle called in owin and need to adopt antoher swin
  otl.swin = vim.fn.bufwinid(otl.sbuf)
  if otl.swin == -1 then
    return M.close()
  else
    line = otl.idx[line]
    otl_sync(otl)
    win_goto(otl.swin)
    win_centerline(otl.swin, line)
  end

  -- vim.notify("[error] shuttle: no window for src buf", vim.log.levels.ERROR)
end

M.toggle = function()
  -- open or close otl for current buffer
  local buf = vim.api.nvim_get_current_buf()
  local otl = vim.b[buf].otl

  if otl == nil then
    -- toggle for buf that has no otl, so create new otl
    return M.open(buf)
  end

  -- Note: toggle calls close, that wipes the otl's and closing the
  -- owin itriggers BufWinLeave for owin.
  M.close(otl.sbuf)
end

M.up = function()
  -- <Up> in otl window
  local buf = vim.api.nvim_get_current_buf()
  local otl = vim.b[buf].otl

  if otl == nil then
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  if line == 1 then
    line = vim.api.nvim_buf_line_count(0)
  else
    line = line - 1
  end

  win_centerline(otl.owin, line)
  line = otl.idx[line]
  win_centerline(otl.swin, line)
end

M.down = function()
  -- <Down> in otl window
  local buf = vim.api.nvim_get_current_buf()
  local otl = vim.b[buf].otl

  if otl == nil then
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  if line == vim.api.nvim_buf_line_count(0) then
    line = 1
  else
    line = line + 1
  end

  win_centerline(otl.owin, line)
  line = otl.idx[line]
  win_centerline(otl.swin, line)
end

-- TODO: not sure if this is the right way
-- but with this: luafile % (or \\x) will reload the module
require("plenary.reload").reload_module "pdh.outline"

return M
