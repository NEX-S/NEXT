local api = vim.api

os.execute("mkdir -p ~/.cache/nvim/view")

local fold_options = {
    viewdir = "~/.cache/nvim/view",
    foldenable = true,
    foldcolumn = "1",
    foldminlines = 4,
    foldmethod = "indent",
    foldtext = "v:lua.FOLD_TEXT()",
}

vim.opt.fillchars:append("fold: ,foldsep:╎,foldopen:~,foldclose:~")

for key, value in pairs(fold_options) do
    api.nvim_set_option_value(key, value, {})
end

_G.FOLD_TEXT = function ()
    local s_row = vim.v.foldstart
    local i = 0
    local s_str = api.nvim_buf_get_lines(0, s_row - 1, s_row, false)[1]

    return s_str .. ' '
end

api.nvim_set_keymap('n', ' ', "za", { noremap = true })

api.nvim_create_autocmd("BufReadPost", { command = "silent! loadview" })
api.nvim_create_autocmd("BufWinLeave", { command = "silent! mkview" })
