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
  local bufpath = fs.dirname(api.nvim_buf_get_name(0))
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
    section_separators = { left = "", right = "" },
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
    -- some icons: i_Ctrl-K <combo>:  k3 ϟ, C% Ч , j4 ㄐ, 2h ⑂, 3h ⑁,  4h ⑃, h3 ⑁, h. ḣ, h, ḩ
    --ㄓ ⑂
    lualine_b = {
      { "branch", icon = "ㄓ", color = { fg = "blue" }, padding = { left = 1, right = 0 } },
      { repo, icon = "→", color = { fg = "yellow" }, padding = { left = 0, right = 1 } },
      "diff",
    },
    lualine_c = { bufnr, "%m", "%F" },
    lualine_x = { "%c:%l/%L" },
    lualine_y = { "progress" },
    lualine_z = { "filetype", fileformat, encoding },
  },
}
