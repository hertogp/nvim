-- File: ~/.config/nvim/lua/pdh/outline.lua
-- [[ Find outline for various filetypes ]]

--
--[[
-- otl is a table: {
  -- sbuf  - source buffer for which outline is requested/created
  -- swin  - window where request was made
  -- dbuf  - destination (i.e. outline) buffer
  -- dwin  - window where it is shown (at some point)
  -- tick  - last changetick
  -- txt   - text for the outline buffer
  -- idx   - corresponding linenrs in source buffer of outline text
--
--this table is stored in both sbuf and dbuf
--
--Functions:
--otl_new, get initial table
--otl_outline, gets the outline for sbuf (checks changedtick)
--otl_show, shows the dbuf in a (new) window
--otl_toggle, hide/show the outline window
--]]

--[[
Corner cases
* sbuf is hidden, but dbuf is not (user switch buffers for example)
  - what is toggle todo if you're in dwin?
* sbuf is unloaded, dbuf & dwin will persist (at the moment) but have
  no relevance anymore ...
* sbuf has split windows on it, swin is the original window from which
  outline was opened.  What todo if that window was closed?
  - toggle should work from any split
  - shuttle should move to the next available window of sbuf

Interesting VIM Buffer functions
- vim.fn.win_findbuf(buf) -> list of window id's that contain bufnr (across all tabs!)
- vim.fn.bufwinnr(buf) -> -1 is buf is not visible in the cur. tabpage, winnr otherwise
- vim.fn.bufwinid(buf) -> -1 is there is no window showing bufnr, (first) winid otherwise
- vim.fn.bufexists(buf) -> 1 if true, buf may be shown, hidden, listed or unlisted
- vim.fn.bufloaded(buf) -> nr, true if exists & loaded (hidden or shown in a window)
- vim.fn.bufnr(buf, [create]) -> -1 if not exists, create is true -> new buf created

Interesting LUA buffer api function
- vim.api.nvim_buf_is_loaded ->
- vim.api.nvim_buf_del_keymap -> unmaps a buffer-local mapping
- vim.api.nvim_buf_del_var -> delete buffer scoped variable
- vim.api.nvim_buf_et_changedtick -> gets the b:changedtick value
- vim.api.nvim_buf_attach -> attach a callback to buf events (changes)
- vim.api.nvim_buf_is_valid -> even if valid, buf may have been unloaded (!)
- vim.api.nvim_buf_line_count -> line count, or 0 is buf was unloaded
- vim.api.nvim_buf_set_keymap
- vim.api.nvim_buf_set_lines
- vim.api.nvim_buf_set_text -> set text (more granular than linewise)
- vim.api.nvim_buf_set_var -> set buf scoped variable

Interesting LUA win api functions
- vim.api.nvim_win_get_cursor -> (1,0) indexed position
- vim.api.nvim_win_set_cursor -> (1,0) indexed position
- vim.api.nvim_win_get_number -> gets window nr in its (!) tabpage (not necessarily the cur.tabpage)
- vim.api.nvim_win_get_tabpage -> tabpage that contains the window
- vim.api.nvim_win_is_valid -> true is valid, even if window is in another tab
- vim.api.nvim_win_set_hs_ns -> sets hl namespace for given window

Interesting VIM commands for scrolling (:he scroll-cursor:)
- z.  redraw line at center of window, cursor on first non blank

Interesting Buffer- or WinEvents
- BufHidden, before buffer becomes hidden (no windows), but it's not unloaded/deleted
- BufDelete, before deleting a buffer from buffer list
- BufUnload, before unloading a buffer (After BufWritePost, before BufDelete)
- WinClosed, when closing a window just before it is removed from the layout (after WinLeave)
and:
- BufWinEnter, after a buffer is displayed in a window (buffer loaded or unhidden)
- BufWinLeave, before buffer is removed from a window (not when it is still visible in another window)
               also triggered when exiting, before BufUnload, BufHidden.  Not triggered when switching
               to another tab


See :he autocmd-buffer-local:
- vim.api.nvim_get_autocmds({buffer=1})
- vim.api.nvim_create_autocmd, use opts = {buffer=N}) to make it buffer local
- vim.api.nvim_del_autocmd(id), id that was returned by nvim_create_autocmd

/usr/local/share/nvim/runtime/lua/vim/lsp/buf.lua

--]]

--[[ GLOBALS ]]

vim.api.nvim_create_augroup("OTL", { clear = true })
vim.api.nvim_create_autocmd("BufWinLeave", {
  buffer = 1,
  callback = function()
    print "BufWinLeave for buffer 1"
  end,
})
--tmp see https://github.com/nvim-telescope/telescope.nvim/blob/30e2dc5232d0dd63709ef8b44a5d6184005e8602/lua/telescope/actions/set.lua
--lines 201-219

function centerline(buf, linenr)
  local win = vim.fn.bufwinid(buf)
  vim.api.nvim_win_set_cursor(win, { line, 0 })
  vim.api.nvim_win_call(win, function()
    vim.cmd "z."
  end)
  -- local cline = vim.api.nvim_get_cursor()[1]

  -- vim.api.nvim_win_call(status.results_win, function()
  --   vim.cmd([[normal! ]] .. math.floor(speed) .. input)
  -- end)
  --
  -- action_set.shift_selection(prompt_bufnr, math.floor(speed) * direction)
end

local api = vim.api

local ft2qry = {
  -- Treesitter queries that yield an outline for a given file type
  ["markdown"] = [[(section (atx_heading) @head) ]],
}

local M = {}

--[[ BUFFER funcs ]]

local function buf_sanitize(bufnr)
  -- return a real, valid bufnr or nil
  if bufnr == nil or bufnr == 0 then
    return vim.api.nvim_get_current_buf()
  elseif vim.api.nvim_buf_is_valid(bufnr) then
    return bufnr
  end
  return nil
end

local function buf_isvalid(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if api.nvim_buf_is_valid(bufnr) and api.nvim_buf_is_loaded(bufnr) then
    return true, bufnr, ""
  end

  return false, bufnr, "invalid bufnr" .. vim.inspect(bufnr)
end

--[[ WINDOW funcs ]]

local function win_isvalid(winid)
  if winid == 0 then
    return true
  elseif winid == nil then
    return false
  else
    return vim.api.nvim_win_is_valid(winid)
  end
end

local function win_goto(winid)
  if winid == nil or winid == 0 or winid == vim.api.nvim_get_current_win() then
    return
  end
  if vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
  else
    vim.notify("[warn] could not move to invalid winid", vim.log.levels.WARN)
  end
end

--[[ OTL funcs ]]

local function otl_close()
  -- close otl window, move to src buffer
  local otl = vim.b.otl

  if otl and win_isvalid(otl.dwin) then
    vim.api.nvim_win_close(otl.dwin, true)
    win_goto(otl.swin)
  else
    vim.notify("[warn] closing outline was not needed", vim.log.levels.WARN)
  end
  if buf_isvalid(otl.sbuf) then
    vim.b[otl.sbuf].otl = nil
  end
end

---get outline, set otl.idx and fill otl.dbuf with lines
---@param buf number
local function otl_outline(buf)
  -- otl must contain src bufnr at least.
  -- TODO: actually implement this.
  -- NOTE: leading space is so cursor doesn't hide first char.
  local txt = { " one", " ten", " twenty", " thirty" }
  local idx = { 1, 10, 20, 30 }
  return idx, txt
end

---sync otl table between src/dst
---@param otl table
local function otl_sync(otl)
  -- store otl as src/dst buffer variable, assumes a valid otl
  -- alt: vim.b[otl.dbuf].otl = otl
  vim.api.nvim_buf_set_var(otl.dbuf, "otl", otl)
  vim.api.nvim_buf_set_var(otl.sbuf, "otl", otl)
  return otl
end

local function otl_settings(otl)
  -- otl window options
  vim.api.nvim_win_set_option(otl.dwin, "list", false)
  vim.api.nvim_win_set_option(otl.dwin, "winfixwidth", true)
  vim.api.nvim_win_set_option(otl.dwin, "number", false)
  vim.api.nvim_win_set_option(otl.dwin, "signcolumn", "no")
  vim.api.nvim_win_set_option(otl.dwin, "foldcolumn", "0")
  vim.api.nvim_win_set_option(otl.dwin, "relativenumber", false)
  vim.api.nvim_win_set_option(otl.dwin, "wrap", false)
  vim.api.nvim_win_set_option(otl.dwin, "spell", false)
  vim.api.nvim_win_set_option(otl.dwin, "cursorline", true)
  vim.api.nvim_win_set_option(otl.dwin, "winhighlight", "CursorLine:Visual")

  -- otl buffer
  vim.api.nvim_buf_set_name(otl.dbuf, "Otl #" .. otl.dbuf)

  vim.api.nvim_buf_set_option(otl.dbuf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(otl.dbuf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(otl.dbuf, "buflisted", false)
  vim.api.nvim_buf_set_option(otl.dbuf, "swapfile", false)
  vim.api.nvim_buf_set_option(otl.dbuf, "modifiable", false)
  vim.api.nvim_buf_set_option(otl.dbuf, "filetype", "otl-outline")

  -- otl keymaps
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(otl.dbuf, "n", "q", "<cmd>lua require'pdh.outline'.close()<cr>", opts)
  local shuttle = "<cmd>lua require'pdh.outline'.shuttle()<cr>"
  vim.api.nvim_buf_set_keymap(otl.dbuf, "n", "<cr>", shuttle, opts)
  vim.api.nvim_buf_set_keymap(otl.sbuf, "n", "<cr>", shuttle, opts)
end

local function otl_open()
  local otl = vim.b.otl

  if otl then
    -- simply focus on existing otl
    if otl.dwin and vim.api.nvim_win_is_valid(otl.dwin) then
      win_goto(otl.dwin)
      return true
    else
      return false
    end
  else
    -- create new otl window with outline
    local sbuf = vim.api.nvim_get_current_buf()
    local swin = vim.api.nvim_get_current_win()
    local tick = vim.b.changedtick
    local idx, lines = otl_outline(sbuf)
    vim.api.nvim_command "noautocmd topleft 40vnew"
    local dbuf = vim.api.nvim_get_current_buf()
    local dwin = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_lines(dbuf, 0, -1, false, lines)
    otl = {
      sbuf = sbuf,
      swin = swin,
      tick = tick,
      dbuf = dbuf,
      dwin = dwin,
      idx = idx,
    }
    otl_settings(otl)
    otl_sync(otl)
  end
end

local function otl_move(n)
  -- move line in otl window n lines up/down, wraps around and scroll sbuf
  -- so associated sbuf line is centered
  local otl = vim.b.otl
  if otl == nil then
    vim.notify("[warn] otl_move sees no otl", vim.log.levels.WARN)
    return
  end
  local oline = vim.api.nvim_win_get_cursor(otl.dwin)[1]
  vim.api.nvim_win_set_cursor(otl.dwin, { oline, 0 })
end

local function otl_select(sline)
  -- given the linenr in sbuf (sline), find the closest match in otl.idx
  -- and move to the associated otl buffer line (oline)
  local line = 1
  local otl = vim.b.otl
  if otl then
    for otl_line, idx in ipairs(otl.idx) do
      if idx <= sline then
        line = otl_line
      end
    end
    vim.api.nvim_win_set_cursor(otl.dwin, { line, 0 })
  end
end

--[[ MODULE ]]

M.close = function()
  -- so we can map "q" to M.close()
  otl_close()
end

M.move = function(n)
  otl_move(n)
end

M.open = function()
  -- we have a close, so add open as well
  otl_open()
end

M.shuttle = function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local buf = vim.api.nvim_get_current_buf()
  local otl = vim.b.otl

  -- no otl available
  if otl == nil then
    return
  end

  -- moveto otl window
  if buf == otl.sbuf then
    win_goto(otl.dwin)
    otl_select(line)
    return
  end

  -- moveto src window
  if not win_isvalid(otl.swin) then
    otl.swin = vim.fn.win_findbuf(otl.sbuf)[1]
    otl_sync(otl)
  end

  if otl.swin then
    win_goto(otl.swin)
  else
    vim.notify("[error] shuttle: no window for src buf", vim.log.levels.ERROR)
  end
end

M.toggle = function(buf)
  buf = buf_sanitize(buf)
  if not buf then
    vim.notify("[error] toggle was given an invalid bufnr", vim.log.levels.ERROR)
    return
  end

  if vim.b[buf].otl then
    otl_close()
  else
    otl_open()
  end
end

-- TODO: not sure if this is the right way
-- but with this: luafile % (or \\x) will reload the module
require("plenary.reload").reload_module "pdh.outline"

return M
