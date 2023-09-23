local api = vim.api

-- os.execute("mkdir -p ~/.cache/nvim/view")

local fold_options = {
    foldenable   = true,
    foldmethod   = "indent",
    foldminlines = 4,
    foldcolumn   = '1',
    foldtext     = "v:lua.FOLD_TEXT()",
    -- viewdir      = "~/.cache/nvim/view",

    -- treesitter fold
    -- foldmethod = "expr",
    -- foldexpr = "nvim_treesitter#foldexpr()",
}

vim.opt.fillchars:append("fold: ,foldsep:╎,foldopen:~,foldclose:~")

for key, value in pairs(fold_options) do
    api.nvim_set_option_value(key, value, {})
end

_G.FOLD_TEXT = function ()
    local s_row = vim.v.foldstart
    local s_str = api.nvim_buf_get_lines(0, s_row - 1, s_row, false)[1]

    return s_str .. ' '
end

api.nvim_set_keymap('n', ' ', "za", { noremap = true })

api.nvim_create_autocmd("BufReadPost", {
    callback = function ()
        api.nvim_input("zR")
    end
})

-- api.nvim_create_autocmd("BufReadPost", { command = "loadview" })
-- api.nvim_create_autocmd("BufLeave", { command = "silent! mkview" })
