-- File: ~/.config/nvim/lua/pdh/outline.lua
-- [[ Find outline for various filetypes ]]

-- local M = {}
-- local hdrs = queries["markdown"]
-- M.qry = vim.treesitter.parse_query("markdown", hdrs)
--
-- P(M.qry)
-- P(vim.api.nvim_buf_get_number(0))
--
-- M.parser = vim.treesitter.get_parser(0, "markdown", {})
-- M.tree = M.parser:parse()
-- M.root = M.tree[1]:root()

-- local lines = {}
-- for id, node in M.qry:iter_captures(M.root, 0, 0, -1) do
--   local head = M.qry.captures[id]
--   -- range = {start_row, start_col, end_row, end_col}
--   local range = { node:range() }
--   local text = vim.treesitter.get_node_text(node, 0)
--   lines[#lines + 1] = { range[1], text }
-- end
--
-- M.lines = lines

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
