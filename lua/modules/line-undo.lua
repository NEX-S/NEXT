local api = vim.api

local count = 0

api.nvim_create_autocmd("InsertLeave", {
    callback = function ()
        count = 0
    end
})

api.nvim_set_keymap('i', '<LEFT>', '', {
    callback = function ()
        count = count + 1
        return '<C-g>u<C-w>'
    end,
    expr = true,
    replace_keycodes = true,
    noremap = true,
})

api.nvim_set_keymap('i', '<RIGHT>', '', {
    callback = function ()
        if count == 0 then
            return
        end

        count = count - 1

        return "<CMD>normal! u<CR>"
    end,
    expr = true,
    replace_keycodes = true,
    noremap = true,
})
