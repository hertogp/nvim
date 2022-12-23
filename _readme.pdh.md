---
  author: me
  date: today
---

# nvim configuaration

# TODO:

- [ ] clean up old plugins (incl docs)
- [x] get an outliner for code files/markdown etc..
- [x] understand tree-sitter better
- [x] automatic formatting lua - donot have one-line funcs perse.
- [x] automatic formatting on save for lua
- [x] change to luasnip instead of ultisnips (see: https://www.youtube.com/watch?v=h4g0m0Iwmysc
- [x] fix it so we can push repo again (git remote set-url origin git@github.com:hertogp/nvim.git)
- [x] get rid of these workspace 'luassert' config questions!
- [x] go all lua config
- [x] install neovim from source
- [x] nice statusline
- [x] nice statusline - get repo name in there - FugitiveGitDir on BufReadPort, BufileNew -> set bo.git_repo=... and use that in statusline.
- [x] redo Show (in tab) command in lua
- [x] remove fugitive? Not using it anymore
- [x] space-l to search current buffer lines
- [x] use language servers for lua, elixir
- [x] use packer plugin manager
- [x] use stylua to format lua code, not luarock's lua-format (does weird things with tables)
- [x] use telescope

## Another subsection

- [ ] TODO:

Another section diff style
--------------------------
this is a subsection

Again another one
=================


# dirtree

```bash
~/.config/nvim
.
├── after
│   ├── compiler
│   │   └── pandoc.vim
│   └── plugin
│       └── luasnip.lua
├── colors
│   └── xoria256.vim
├── init.lua
├── lua
│   ├── autocmds.lua
│   ├── colors.lua
│   ├── globals.lua
│   ├── keymappings.lua
│   ├── options.lua
│   ├── plugins.lua
│   └── setup
│       ├── init.lua
│       ├── lsp-config.lua
│       ├── lualine-config.lua
│       ├── luasnip-config.lua
│       ├── nvim-cmp-config.lua
│       ├── symbols-outline-config.lua
│       ├── telescope-config.lua
│       └── tree-sitter-config.lua
├── luasnippets
│   └── lua.lua
├── node_modules
├── plugin
│   ├── packer_compiled.lua
│   └── voomify.vim.org
├── pylib
│   └── voom_vimplugin2657
├── _readme.pdh.md
├── stylua.toml
├── templates
│   └── personal.templates
└── yarn.lock
```

