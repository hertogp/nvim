-- lualine.lua
-- https://github.com/nvim-lualine/lualine.nvim
local api = vim.api
local fs = vim.fs
local uv = require "luv"

local function encoding()
  return "[" .. vim.bo.fenc .. "]"
end

local function fileformat()
  return "[" .. vim.bo.fileformat .. "]"
end

local function bufnr()
  return "[#" .. api.nvim_get_current_buf() .. "]"
end

local function repo()
  -- scratch buffers -> fallback to cwd
  local bufpath = fs.dirname(api.nvim_buf_get_name(0))
  if #bufpath < 1 or bufpath == "." then
    bufpath = uv.cwd()
  end
  bufpath = fs.normalize(bufpath)
  local repo_dir = fs.find(".git", { path = bufpath, upward = true })[1]
  if repo_dir then
    return fs.basename(fs.dirname(repo_dir))
  else
    return "(-)"
  end
end

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "dracula",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    -- disabled_filetypes = {
    --   statusline = {},
    --   winbar = {},
  },
  -- ignore_focus = {},
  -- always_divide_middle = true,
  -- globalstatus = false,
  -- refresh = {
  --   statusline = 1000,
  --   tabline = 1000,
  --   winbar = 1000,
  -- }
  -- },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      { repo, icon = "", color = { fg = "yellow" }, padding = { left = 0, right = 0 } },
      { "branch", icon = "", color = { fg = "blue" }, padding = { left = 1, right = 0 } },
      "diff",
    },
    lualine_c = { bufnr, "%m", "%F" },
    lualine_x = { "%c:%l/%L", "progress" },
    lualine_y = { fileformat, encoding },
    lualine_z = { "filetype" },
  },
}
