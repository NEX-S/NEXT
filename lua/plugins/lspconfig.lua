local api = vim.api

local lsp_keymap = {
    ["gd"] = vim.lsp.buf.definition,
    ["gD"] = vim.lsp.buf.declaration,
    ["gr"] = vim.lsp.buf.references,
    ["gh"] = vim.lsp.buf.hover,

    ["<A-f>"] = vim.lsp.buf.format,
    ["<C-,>"] = vim.diagnostic.goto_prev,
    ["<C-.>"] = vim.diagnostic.goto_next,
    ["<C-r>"] = vim.lsp.buf.rename,
}

for key, value in pairs(lsp_keymap) do
    api.nvim_set_keymap('n', key, '', { callback = value })
end

vim.diagnostic.config {
    underline = false,
    update_in_insert = false,
    -- severity_sort = true,
    virtual_text = {
        spacing = 0,
        -- source = "if_many",
        -- prefix = '▎',
        prefix = '',
    },
}

local function lsp_attach ()
    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
end

-- asdf = asdf

local servers =
{
    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--header-insertion=iwyu",
            "--clang-tidy",
            -- "--completion-style=detailed",
            -- "--function-arg-placeholders",
            "--fallback-style=llvm",
        },
        capabilities = {
            offsetEncoding = { "utf-16" },
        },
        root_dir = function ()
            return _G.GIT_PATH or vim.fn.getcwd()
        end,
    },
    lua_ls = {
        -- cmd = { "/home/nex/Downloads/lua-language-server-3.7.0-linux-x64/bin/lua-language-server" },
        diagnostics = {
            enable = true,
            globals = {
                "vim"
            },
        },
        runtime = {
            version = 'LuaJIT',
            path = vim.split(package.path, ';'),
        },
        workspace = {
            library = { vim.env.VIMRUNTIME, },
            checkThirdParty = false,
        },
    }
}


return {
    { "neovim/nvim-lspconfig",
        event = "BufWinEnter",
        opts = {
            inlay_hints = { enabled = true },
        },
        config = function ()
            require "lspconfig".clangd.setup(servers.clangd)
            require "lspconfig".lua_ls.setup(servers.lua_ls)

            api.nvim_command("LspStart")
            api.nvim_create_autocmd("BufWinEnter", { command = "LspStart" })
        end
    }
}
