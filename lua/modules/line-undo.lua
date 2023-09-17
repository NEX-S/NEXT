local api = vim.api

local first_ctrl_h = false
local first_ctrl_h_pos = {}
api.nvim_create_autocmd("InsertEnter", {
    callback = function ()
        first_ctrl_h = true
        first_ctrl_h_pos = {}
    end
})

api.nvim_create_autocmd("InsertLeave", {
    callback = function ()
        first_ctrl_h = false
        first_ctrl_h_pos = {}
    end
})

api.nvim_set_keymap('i', '<LEFT>', '', {
    callback = function ()
        if first_ctrl_h then
            first_ctrl_h = false
            first_ctrl_h_pos = api.nvim_win_get_cursor(0)
        end
        return '<C-g>u<C-w>'
    end,
    noremap = true,
    expr = true,
    replace_keycodes = true,
})

api.nvim_set_keymap('i', '<RIGHT>', '', {
    callback = function ()
        local cursor_pos = api.nvim_win_get_cursor(0)
        if cursor_pos[1] == first_ctrl_h_pos[1] and cursor_pos[2] == first_ctrl_h_pos[2] then
            return ''
        end

        return '<CMD>normal!u<CR>'
    end,
    noremap = true,
    expr = true,
    replace_keycodes = true,
})
