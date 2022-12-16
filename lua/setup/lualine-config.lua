-- lualine.lua
-- https://github.com/nvim-lualine/lualine.nvim
local function encoding()
  return '[' .. vim.bo.fenc .. ']'
end

local function filetype()
  return '[' .. vim.bo.filetype .. ']'
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'dracula',
    component_separators = {left = '', right = ''},
    section_separators = {left = '', right = ''}
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
    lualine_a = {'mode'},
    -- some icons: i_Ctrl-K <combo>:  k3 ϟ, C% Ч , j4 ㄐ, 2h ⑂, 3h ⑁,  4h ⑃, h3 ⑁, h. ḣ, h, ḩ
    lualine_b = {{'branch', icon = '⑂'}, 'diff'},
    lualine_c = {'%m', '%F'},
    lualine_x = {"%c:%l/%L"},
    lualine_y = {'progress'},
    lualine_z = {encoding, 'bo:fileformat', filetype}
  }
  -- inactive_sections = {
  --   lualine_a = {},
  --   lualine_b = {},
  --   lualine_c = {'filename'},
  --   lualine_x = {},
  --   lualine_y = {},
  --   lualine_z = {}
  -- },
  -- tabline = {},
  -- winbar = {},
  -- inactive_winbar = {},
  -- extensions = {}
}

-- unix = '', -- e712
-- dos = '', -- e70f
-- mac = '', -- e711
