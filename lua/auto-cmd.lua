-- auto-cmd.lua

-- :au <Event> shows all autocommands for <Event>
-- :h event shows a lot of events

local augrp = vim.api.nvim_create_autogroup("PdhTst", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", { command = "echo 'Hello Buffy'", group = augrp})
