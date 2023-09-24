local api = vim.api

vim.fn.sign_define("DiagnosticSignError", { text = '', texthl = "DiagnosticSignError", numhl = "DiagnosticLineNrError", linehl = "" })
vim.fn.sign_define("DiagnosticSignWarn",  { text = '', texthl = "DiagnosticSignWarn",  numhl = "DiagnosticLineNrWarn",  linehl = "" })
vim.fn.sign_define("DiagnosticSignInfo",  { text = '', texthl = "DiagnosticSignInfo",  numhl = "DiagnosticLineNrInfo",  linehl = "" })
vim.fn.sign_define("DiagnosticSignHint",  { text = '', texthl = "DiagnosticSignHint",  numhl = "DiagnosticLineNrHint",  linehl = "" })

vim.diagnostic.config {
    signs = true,
    underline = false,
    update_in_insert = false,
    severity_sort = true,
    virtual_text = {
        spacing = 1,
        prefix = '',
    },
}

local function lsp_attach (client, bufnr)
    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

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
        api.nvim_buf_set_keymap(bufnr, 'n', key, '', { callback = value })
    end
end

local servers =
{
    clangd = {
        on_attach = lsp_attach,
        inlay_hints = { enabled = true },
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
        root_dir = function()
            return _G.GIT_PATH == "" or vim.fn.getcwd()
        end,
    },
    lua_ls = {
        cmd = { "/home/nex/Downloads/lua-language-server-3.7.0-linux-x64/bin/lua-language-server" },
        on_attach = lsp_attach,
        inlay_hints = { enabled = true },
        settings = {
            Lua = {
                diagnostics = {
                    enable = true,
                    globals = { "vim" },
                },
                runtime = {
                    version = "LuaJIT",
                    path = vim.split(package.path, ';'),
                },
                workspace = {
                    library = { vim.env.VIMRUNTIME, },
                    checkThirdParty = false,
                },
            },
        },
    }
}

vim.lsp.handlers["textDocument/definition"] =
function (_, result, _)
    local util = vim.lsp.util

    if result == nil or next(result) == nil then
        return
    end

    api.nvim_command("tabnew")
    util.jump_to_location(result[1])
end

return {
    { "neovim/nvim-lspconfig",
        event = "BufWinEnter",
        opts = {
            inlay_hints = { enabled = true },
        },
        config = function()
            require "lspconfig".clangd.setup(servers.clangd)
            require "lspconfig".lua_ls.setup(servers.lua_ls)

            api.nvim_command("LspStart")
            api.nvim_create_autocmd("BufWinEnter", { command = "LspStart" })
        end
    }
}
