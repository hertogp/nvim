# nvim configuaration

# TODO

    [ ] understand tree-sitter better
    [x] automatic formatting on save for lua
    [x] automatic formatting lua - donot have one-line funcs perse.
    [x] go all lua config
    [x] install neovim from source
    [x] nice statusline
    [x] nice statusline - get repo name in there - FugitiveGitDir on BufReadPort, BufileNew -> set bo.git_repo=... and use that in statusline.
    [x] redo Show (in tab) command in lua
    [x] space-l to search current buffer lines
    [x] use language servers for lua, elixir
    [x] use packer plugin manager
    [x] use telescope
    [ ] get rid of these \ntw template/luassert config questions!
    [ ] clean up old plugins (incl docs)
    [x] remove fugitive? Not using it anymore
    [ ] get an outliner for code files/markdown etc..


## dirtree

```
~/.config/nvim
`-- lua
    `-- pdh
        `-- core
        `-- plugins
            `-- lualine.lua
            `--- telescope.lua
        `-- plugins-setup.lua


