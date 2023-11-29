local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--     vim.fn.system({
--         "git",
--         "clone",
--         "--filter=blob:none",
--         "https://github.com/folke/lazy.nvim.git",
--         "--branch=stable", -- latest stable release
--         lazypath,
--     })
-- end
vim.opt.rtp:prepend(lazypath)

require "lazy".setup {
    root = vim.fn.stdpath("data") .. "/lazy",
    defaults = { lazy = true, },
    lockfile = vim.fn.stdpath("cache") .. "lazy-lock.json",
    ui = {
        size = { width = 0.75, height = 0.75 },
        border = "rounded",
        icons = {
            -- cmd     = " ",
            -- config  = " ",
            -- event   = " ",
            -- ft      = " ",
            -- init    = " ",
            -- keys    = "ﱕ ",
            -- plugin  = " ",
            -- runtime = " ",
            -- source  = " ",
            -- start   = " ",
            -- task    = " ",
        },
    },
    checker = {
        enabled = false,
        notify = false,
        frequency = 3600,
    },
    change_detection = {
        enabled = false,
        notify = false,
    },
    performance = {
        cache = {
            enabled = true,
            path = vim.fn.stdpath("cache"),
        },
        reset_packpath = true,
        rtp = {
            reset = true,
            paths = {},
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "filetype",
                "health",
                "man",
                "shada",
                "spellfile",
                "nvim",
                "rplugin",
                "zipPlugin",
            },
        },
    },
    spec = {
        { import = "plugins.treesitter" },
        { import = "plugins.lspconfig" },
        { import = "plugins.dap" },
    },
}
