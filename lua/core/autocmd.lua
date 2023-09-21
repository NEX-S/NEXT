
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


api.nvim_create_autocmd("BufWInEnter", {
    callback = function ()
        local line = vim.fn.line([['"]])
        local col = vim.fn.col([['"]])

        if line > 0 and line <= vim.fn.line("$") then
            api.nvim_win_set_cursor(0, {line, col - 1})
        end
    end
})
