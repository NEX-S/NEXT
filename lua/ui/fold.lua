local api = vim.api

local fold_options = {
    -- viewdir = "~/.cache/nvim",
    foldenable = true,
    foldcolumn = "1",
    foldminlines = 4,
    foldmethod = "indent",
    foldtext = "v:lua.FOLD_TEXT()",
}

for key, value in pairs(fold_options) do
    api.nvim_set_option_value(key, value, {})
end

_G.FOLD_TEXT = function ()
    local s_row = vim.v.foldstart
    local s_line = api.nvim_buf_get_lines(0, s_row - 1, s_row, false)[1]
    local indent = s_line:find("%S") - 1

    return string.rep(' ', indent - 2) .. ' ' .. s_line:sub(indent + 1)
end

api.nvim_set_keymap('n', ' ', "za", { noremap = true })

-- api.nvim_create_autocmd("BufWinEnter", { command = "silent! loadview" })
-- api.nvim_create_autocmd("BufWinLeave", { command = "silent! mkview" })

-- api.nvim_set_keymap('n', ' ', '', {
--     callback = function ()
--         local cursor_row = api.nvim_win_get_cursor(0)[1]
--         return vim.fn.foldclosed(cursor_row) == -1 and "zc" or "zo"
--     end,
--     expr = true,
--     replace_keycodes = true,
--     noremap = true,
-- })
