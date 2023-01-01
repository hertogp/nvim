-- File: ~/.config/nvim/lua/pdh/outline.lua
-- [[ Find outline for various filetypes ]]

--[[ HELPERS ]]

local function create_outline_buffer(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- check if it has been created
  if vim.b.outline_buffer then
    return vim.b.outline_buffer
  end

  local otl_bufnr = vim.api.nvim_create_buf(false, true)

  -- buffer vars
  -- vim.fn.win_findbuf(bufnr) -> list of winid's that contain bufnr
  vim.api.nvim_buf_set_var(bufnr, "outline_buffer", otl_bufnr)
  vim.api.nvim_buf_set_var(otl_bufnr, "source_buffer", bufnr)
  -- buffer options
  vim.api.nvim_buf_set_option(otl_bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(otl_bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(otl_bufnr, "buflisted", false)
  vim.api.nvim_buf_set_option(otl_bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(otl_bufnr, "modifiable", false)
  -- easy quit
  vim.api.nvim_buf_set_keymap(
    otl_bufnr,
    "n",
    "q",
    "<cmd>close<cr>",
    { noremap = true, silent = true }
  )

  return otl_bufnr
end
local function setup_outline_win(src_winid, otl_winid, otl_bufnr)
  vim.api.nvim_win_set_buf(otl_winid, otl_bufnr)
  vim.api.nvim_win_set_option(otl_winid, "list", false)
  vim.api.nvim_win_set_option(otl_winid, "winfixwidth", true)
  vim.api.nvim_win_set_option(otl_winid, "number", false)
  vim.api.nvim_win_set_option(otl_winid, "signcolumn", "no")
  vim.api.nvim_win_set_option(otl_winid, "foldcolumn", "0")
  vim.api.nvim_win_set_option(otl_winid, "relativenumber", false)
  vim.api.nvim_win_set_option(otl_winid, "wrap", false)
  vim.api.nvim_win_set_option(otl_winid, "spell", false)
  vim.api.nvim_win_set_var(otl_winid, "is_outline_win", true)

  vim.api.nvim_win_set_var(otl_winid, "source_win", src_winid)
  vim.api.nvim_win_set_var(src_winid, "outline_win", otl_winid)
  -- Set the filetype only after we enter the buffer so that ftplugins behave properly
  -- vim.api.nvim_buf_set_option(otl_bufnr, "filetype", "outline")
  -- util.restore_width(otl_winid, otl_bufnr)
end

local function go_win_no_au(winid)
  if winid == nil or winid == 0 or winid == vim.api.nvim_get_current_win() then
    return
  end
  local winnr = vim.api.nvim_win_get_number(winid)
  vim.cmd(string.format("noautocmd %dwincmd w", winnr))
end

---@param bufnr nil|integer
local function go_buf_no_au(bufnr)
  if bufnr == nil or bufnr == 0 or bufnr == vim.api.nvim_get_current_buf() then
    return
  end
  vim.cmd(string.format("noautocmd b %d", bufnr))
end

local function create_outline_window(bufnr, otl_bufnr, existing_win)
  if otl_bufnr == -1 then
    otl_bufnr = create_outline_buffer(bufnr)
  end

  local my_winid = vim.api.nvim_get_current_win()
  local otl_winid
  if not existing_win then
    local modifier = "topleft"
    vim.cmd(string.format("noautocmd vertical %s 20split", modifier))
    otl_winid = vim.api.nvim_get_current_win()
  else
    otl_winid = existing_win
  end

  go_win_no_au(otl_winid)
  setup_outline_win(my_winid, otl_winid, otl_bufnr)
  go_win_no_au(my_winid)

  return otl_winid
end

--[[ Usage:
-- local outline = require "lua.pdh.outline".outline
-- outline(0) -> {{lineno, text}, ...}
]]

local api = vim.api
-- Treesitter queries that yield an outline for a given file type
local ft2qry = {
  ["markdown"] = [[(section (atx_heading) @head) ]],
}

local M = {}

local function validate_bufnr(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if api.nvim_buf_is_valid(bufnr) and api.nvim_buf_is_loaded(bufnr) then
    return true, bufnr, ""
  end

  return false, bufnr, "invalid bufnr " .. bufnr
end

M.open = function(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local otl_bufnr = create_outline_buffer(bufnr)
  create_outline_window(bufnr, otl_bufnr)
  return otl_bufnr
end
M.outline = function(bufnr)
  -- sanity checks
  local ok, bufno, msg = validate_bufnr(bufnr)
  if not ok then
    vim.notify("[WARN][bufnr] " .. bufno .. " (" .. msg .. ")", vim.log.levels.WARN)
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

return M
