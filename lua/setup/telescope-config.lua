-- File: telescope.lua
require("telescope").setup({
  -- in normal mode, 'q' quits telescope (see :h telescope.mappings)
  -- this should probably move to lua/setup/telescope.lua file.
  defaults = {mappings = {n = {["q"] = "close"}}}
})

require"telescope".load_extension('fzf')

