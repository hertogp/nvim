-- lualine.lua
-- https://github.com/nvim-lualine/lualine.nvim
local api = vim.api
local fs = vim.fs

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
  local bufpath = fs.normalize(fs.dirname(api.nvim_buf_get_name(0)))
  local repo_dir = fs.find(".git", { path = bufpath, upward = true })[1]
  if repo_dir then
    return "(" .. fs.basename(fs.dirname(repo_dir)) .. ")"
  else
    return "(none)"
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
      { "branch", icon = "", color = { fg = "blue" }, padding = { left = 1, right = 0 } },
      { repo, icon = "", color = { fg = "yellow" }, padding = { left = 0, right = 1 } },
      "diff",
    },
    lualine_c = { bufnr, "%m", "%F" },
    lualine_x = { "%c:%l/%L", "progress" },
    lualine_y = { fileformat, encoding },
    lualine_z = { "filetype" },
  },
}
