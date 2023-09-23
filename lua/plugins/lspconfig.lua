local api = vim.api

local function on_attach (ev)
    print("on_attach")
    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
    api.nvim_buf_set_keymap(ev.buf, 'n', "gd", '', { callback = vim.lsp.buf.definition })
end

return {
    { "neovim/nvim-lspconfig",
        event = "BufWinEnter",
        opts = {
            clangd = {
                on_attach = on_attach,
                cmd = { "clangd" },
            },
        },
        config = function(_, opts)
            require "lspconfig".clangd.setup(opts.clangd)
        end,
    }
}
