local api = vim.api

api.nvim_create_autocmd({ "FocusGained", "UIEnter" }, {
    command = "let @y=@+"
})

api.nvim_create_autocmd({ "FocusLost" }, {
    command = "let @+=@y"
})

api.nvim_create_autocmd({ "QuitPre" }, {
    callback = function ()
        api.nvim_command("let @+=@y")
        os.exit()
    end
})
