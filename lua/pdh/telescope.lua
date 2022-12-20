-- File: ~/.config/nvim/lua/pdh/telescope.lua

--[[ USAGE ]]
-- fzf is installed and in the search prompt, you can do:
-- asdf   -- fuzzy search                   includes items with those letters
-- 'asdf  -- exact match                    includes items wih asdf exactly
-- ^asdf  -- prefix-exact match             includes items that start with asdf
-- asdf$  -- suffix-exact match             includes items that end with asdf
-- !asdf  -- inverse-exact-match            excludes with asdf exactly
-- !^asdf -- inverse-prefix-exact-match     excludes items that start with asdf
-- !asdf$ -- inverse-suffix-exact-match     excludes items that end with asdf
-- CAPS   -- is an exact-match

P "File: ~/.config/nvim/lua/pdh/telescope.lua required!"
local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local sorters = require "telescope.sorters"
-- local config = require("telescope.config").values
local M = {}

--[[ Helpers ]]

local function filter_buf_lines(bufnr, words)
  -- match lines on any of the words and return a list of {linenr, line}
  -- for lines that matched.
  local ok, lines = pcall(function()
    return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end)

  if not ok or #lines == 0 then
    return {}
  end

  words = words or {}
  local matches = {}
  local linenr = 1
  for _, line in ipairs(lines) do
    for _, word in ipairs(words) do
      if string.find(line, word) then
        matches[#matches + 1] = { linenr, line }
        goto next
      end
    end
    ::next::
    linenr = linenr + 1
  end
  return matches
end

local function attach_goto_selection(prompt_bufnr)
  -- assumes entry consists of {linenr, line}
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    P(selection)
    if selection then
      local linenr = selection.value[1]
      vim.api.nvim_win_set_cursor(0, { linenr, 0 })
    else
      print "nothing selected"
    end
  end)
  return true
end

--[[ outine ]]
-- lvimgrep /#\+/ %
-- require"telescope.builtin".loclist {
-- prompt_title = "navigate markdown"
-- results_title = "markdown headers"
-- }

--[[ Find in Buffer]]
M.find_in_buf = function(opts)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  opts = opts or {}
  pickers
    .new({ sorting_strategy = "ascending" }, {
      prompt_title = "fuzzy find in buffer",
      finder = finders.new_table { results = lines },
      sorter = sorters.get_substr_matcher(),

      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            vim.api.nvim_win_set_cursor(0, { selection.index, 0 })
          else
            print "nothing selected"
          end
        end)
        return true
      end,
    })
    :find()
end

M.todos = function(opts)
  opts.prompt_title = "Search TODO's"
  if opts and opts.buffer then
    -- use lvimgrep and the window's location list
    local ok, _ = pcall(function()
      vim.cmd.lvimgrep([[/(FIXME\|TODO\|XXX):/j]], "%")
    end)
    if ok then
      require("telescope.builtin").loclist {
        prompt_title = "Search TODO's",
        results_title = [[\ TODO, FIXME, XXX /]],
        filename_width = 0,
      }
    else
      vim.notify("[info] no TODO, FIXME or XXX's found", vim.log.levels.INFO)
    end
  else
    require("telescope.builtin").grep_string {
      search = "TODO:|FIXME:|XXX:",
      use_regex = true,
    }
  end
end

M.buffers = function()
  require("telescope.builtin").buffers {
    attach_mappings = function(prompt_bufnr, map)
      map("n", "d", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.api.nvim_buf_delete(selection.bufnr, { force = true })
      end)
      return true
    end,
  }
end

-- grep Neovim source using <cword>
function M.grep_nvim_src()
  require("telescope.builtin").grep_string {
    results_title = "neovim source code",
    prompt_title = "Search neovim source",
    path_display = { "smart" },
    search = nil,
    search_dirs = {
      "~/installs/neovim/neovim/runtime",
      "~/installs/neovim/neovim/src/nvim",
    },
  }
end

return M
