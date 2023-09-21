
local api = vim.api

api.nvim_create_autocmd("Filetype", {
    pattern = "help",
    callback = function ()
        api.nvim_command("wincmd L")
        api.nvim_command("vert resize 80")
        api.nvim_set_option_value("statuscolumn", ' ', { scope = "local" })
        api.nvim_set_option_value("signcolumn", 'no', { scope = "local" })
    end,
})

api.nvim_create_autocmd("BufWinEnter", {
    callback = function ()
        local last_pos = vim.fn.getpos("'\"")
        pcall(api.nvim_win_set_cursor, { 0, { last_pos[2], last_pos[3] - 1 }})
    end
})
