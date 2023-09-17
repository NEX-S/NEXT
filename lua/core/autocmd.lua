
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
