
return {
    { "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "BufEnter",
        -- event = "BufReadPost",
        opts = {
            auto_install = false,
            ensure_installed = { "lua", "c", "python", "markdown", "json" },
            sync_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            incremental_selection = { enable = false },
        },
        config = function (plugin, opts)
            require "nvim-treesitter.configs".setup(opts)
            require "plugins.TS.textobjects"
        end
    }
}
