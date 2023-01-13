-- File: ~/.config/nvim/lua/pdh/outline.lua
-- [[ Find outline for various filetypes ]]

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
--otl_get_tbl, get initial table
--otl_get_outline, gets the outline for sbuf (checks changedtick)
--otl_show, shows the dbuf in a (new) window
--otl_toggle, hide/show the outline window
--]]

--[[ GLOBALS ]]

local api = vim.api

-- Treesitter queries that yield an outline for a given file type
local ft2qry = {
  ["markdown"] = [[(section (atx_heading) @head) ]],
}

--[[ BUFFER funcs ]]

-- note:
-- bufnr's and winid's are supposed to have been validated

local function buf_isvalid(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if api.nvim_buf_is_valid(bufnr) and api.nvim_buf_is_loaded(bufnr) then
    return true, bufnr, ""
  end

  return false, bufnr, "invalid bufnr" .. vim.inspect(bufnr)
end

---@param bufnr nil|integer
local function buf_goto(bufnr)
  vim.cmd(string.format("noautocmd b %d", bufnr))
end

--[[ WINDOW funcs ]]

local function win_getid(bufnr, winid)
  -- favor current window if bufnr is current buffer
  if bufnr == vim.api.nvim_get_current_buf() then
    return vim.api.nvim_get_current_win()
  end

  local winids = vim.fn.win_findbuf(bufnr)
  for _, win in ipairs(winids) do
    if win == winid then
      return P(win)
    end
    return winids[1]
  end
end

local function win_goto(winid)
  if winid == nil or winid == 0 or winid == vim.api.nvim_get_current_win() then
    return
  end
  -- win_gotoid(winid)
  local winnr = vim.api.nvim_win_get_number(winid)
  vim.cmd(string.format("noautocmd %dwincmd w", winnr))
end

--[[ OTL funcs ]]

local function otl_get_outline(otl)
  -- otl must contain src bufnr at least.
  -- TODO: actually implement this.
  -- NOTE: leading space is so cursor doesn't hide first char.
  local txt = { " one", " ten", " twenty", " thirty" }
  otl.idx = { 1, 10, 20, 30 }
  vim.api.nvim_buf_set_option(otl.dbuf, "modifiable", true)
  vim.api.nvim_buf_set_lines(otl.dbuf, 0, -1, false, txt)
  vim.api.nvim_buf_set_option(otl.dbuf, "modifiable", false)
  return otl
end

local function otl_sync(otl)
  -- store otl as src/dst buffer variable
  vim.api.nvim_buf_set_var(otl.dbuf, "otl", otl)
  vim.api.nvim_buf_set_var(otl.sbuf, "otl", otl)
  return otl
end

local function otl_get_tbl(buf)
  -- used by M.open to get src/dst relations

  -- get the real buffer number
  if buf == nil or buf == 0 then
    buf = api.nvim_get_current_buf()
  end

  -- check if buf already has an otl table
  local otl = vim.b[buf].otl
  if otl and otl.dbuf and vim.api.nvim_buf_is_valid(otl.dbuf) then
    -- if dbuf is valid, it must be visible in its window
    -- todo: if curbuf == sbuf, use current window id instead
    otl.swin = win_getid(otl.sbuf, otl.swin)
    if otl.swin == nil then
      vim.notify("[error] source buffer not available", vim.log.levels.ERROR)
      return nil
    end

    return otl_sync(otl)
  end

  -- no otl found so create one using buf as src
  otl = { sbuf = buf, swin = vim.api.nvim_get_current_win() }
  otl.dbuf = api.nvim_create_buf(false, true) -- unlisted, scratch buffer
  vim.api.nvim_buf_set_name(otl.dbuf, "Otl #" .. otl.dbuf)
  -- scratch buffer options
  vim.api.nvim_buf_set_option(otl.dbuf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(otl.dbuf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(otl.dbuf, "buflisted", false)
  vim.api.nvim_buf_set_option(otl.dbuf, "swapfile", false)
  vim.api.nvim_buf_set_option(otl.dbuf, "modifiable", false)
  vim.api.nvim_buf_set_option(otl.dbuf, "filetype", "otl-outline")
  -- otl.dbuf keymaps
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(otl.dbuf, "n", "q", "<cmd>close<cr>", opts)

  -- TODO: srcbuf keymaps (<cr> to shuttle back and forth)

  -- sync both buffers with otl table
  return otl_sync(otl)
end

local function otl_show(otl)
  -- goto otl if already shown
  if otl.dwin and vim.api.nvim_win_is_valid(otl.dwin) then
    win_goto(otl.dwin)
    return true
  end

  -- create, show and goto new otl window
  -- TODO: use setup to let user specify preferences like topleft or whatnot
  vim.cmd(string.format("noautocmd vertical %s 40split", "topleft"))
  otl.dwin = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(otl.dwin, otl.dbuf)

  -- sync otl
  otl_sync(otl)

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

  return true
end

--[[ MODULE ]]

local M = {}

M.open = function(bufnr)
  -- open/show an outline for bufnr
  -- 1. create an outline buffer (otlbufnr) if necessary
  -- 2. fill outline buffer with outline contents
  -- 3. open/update a possible new window for otlbufnr
  -- 4. select the line (or closest line above) the current line in buffer
  -- 5. center the selected line in otlwin
  -- TODO:
  -- - shuttle between winid's using <CR> keymap
  -- - if srcwinid is no longer valid, search for another one
  -- - when called in an otlwinid, no nothing

  -- get valid srcbufnr, otlbufnr  or error out
  local otl = otl_get_tbl(bufnr)
  otl_get_outline(otl)
  otl_show(otl)
end

M.close = function(bufnr)
  -- close the otlwinid
  -- remove (unnload) otlbufnr
  -- update srcbufnr by setting its bo.otlbufnr to nil
  -- may triggered by 'q' in normal mode
end

M.outline = function(bufnr)
  -- return an outline vor bufnr as a list of {linenr, line}
  -- * called on a buffer
  -- * if an otl buffer does not exist:
  --   - create one (if possible, if not emit warning)
  --   - fill buffer with outline
  --   - open it in a window
  --   - move cursor to it, on the line based on current cursor in srcbuf

  -- sanity checks
  local ok, bufno, msg = buf_isvalid(bufnr)
  if not ok then
    vim.notify("[WARN] bufnr " .. bufno .. ": " .. msg, vim.log.levels.WARN)
    return {}
  end
  local ft = vim.bo.filetype
  if ft2qry[ft] == nil then
    vim.notify("[WARN] unsupported filetype: " .. ft, vim.log.levels.WARN)
    return {}
  end

  local query = vim.treesitter.parse_query(ft, ft2qry[ft])
  local parser = vim.treesitter.get_parser(bufno, ft, {})
  local tree = parser:parse()
  local root = tree[1]:root()

  local lines = {}
  for _, node in query:iter_captures(root, 0, 0, -1) do
    -- local items = query.captures[_id]
    -- range = {start_row, start_col, end_row, end_col}
    local range = { node:range() }
    local text = vim.treesitter.get_node_text(node, 0)
    -- list of {lineno, text}
    lines[#lines + 1] = { range[1], text }
  end

  return lines
end

-- TODO: not sure if this is the right way
-- but with this: luafile % (or \\x) will reload the module
require("plenary.reload").reload_module "pdh.outline"

return M
