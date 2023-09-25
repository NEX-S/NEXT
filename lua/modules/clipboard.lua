local api = vim.api

api.nvim_create_autocmd("BufEnter", { once = true, command = "let @y=@+" })

api.nvim_create_autocmd("FocusGained" , { command = "let @y=@+" })

api.nvim_create_autocmd({ "FocusLost", "VimLeave" }, {
    command = "let @+=@y"
})
