local api = vim.api
local lsp = vim.lsp

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
    lsp.semantic_tokens.start(bufnr, client)
end

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

local servers =
{
    clangd = {
        -- on_attach = lsp_attach,
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
            return _G.GIT_PATH == "" and vim.fn.expand("%:p:h") or _G.GIT_PATH
        end,
    },
    lua_ls = {
        cmd = { "/opt/lua-ls/bin/lua-language-server" },
        on_attach = lsp_attach,
        inlay_hints = { enabled = true },
        settings = {
            Lua = {
                hint = {
                    enable = true,
                    array_index = "Enable",
                    setType = true,
                },
                semantic = {
                    enable = true,
                },
                telemetry = {
                    enable = false,
                },
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
                completion = {
                    autoRequire = true,
                    callSnippet = "Replace",
                    displayContext = 1,
                },
            },
        },
        root_dir = function()
            return _G.GIT_PATH == "" and vim.fn.expand("%:p:h") or _G.GIT_PATH
        end,
    }
}

vim.lsp.handlers["textDocument/definition"] =
function (_, result, _)
    local util = vim.lsp.util

    if result == nil or next(result) == nil then
        return
    end

    api.nvim_command("tabnew")
    util.jump_to_location(result[1], "utf-8", true)
end

-- 󰵈                       󰵈 󰇆 󰐡 󰔌 󱊔 
local icons = {
    Class       = "󰵈",
    Color       = "󰵈",
    Constant    = "󰇆",
    Constructor = "",
    Enum        = "",
    EnumMember  = "󰵈",
    Field       = "",
    File        = "󰵈",
    Folder      = "󰵈",
    Function    = "󰵈",
    Interface   = "󰵈",
    Keyword     = "󰵈",
    Method      = "",
    Module      = "",
    Property    = "󰵈",
    Snippet     = "",
    Struct      = "󰵈",
    Text        = "",
    Unit        = "󰵈",
    Value       = "",
    Variable    = "",
}

local kinds = lsp.protocol.CompletionItemKind
for i, kind in ipairs(kinds) do
    kinds[i] = icons[kind] or kind
end

vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

return {
    {  "neovim/nvim-lspconfig",
        event = "BufEnter",
        config = function()
            require "lspconfig".clangd.setup(servers.clangd)
            require "lspconfig".lua_ls.setup(servers.lua_ls)

            api.nvim_command("LspStart")
            api.nvim_create_autocmd("BufEnter", { command = "LspStart" })
            -- lsp.inlay_hint(0, true)
        end
    }
}
