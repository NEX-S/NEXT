local api = vim.api

api.nvim_create_autocmd({ "FocusGained", "UIEnter" }, {
    command = "let @y=@+"
})

api.nvim_create_autocmd({ "FocusLost", "UILeave" }, {
    command = "let @+=@y"
})
