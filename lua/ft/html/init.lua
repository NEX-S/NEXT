local api = vim.api

require "ft.html.auto-render"

local complete_tag = {
    ["html"] = true,
    ["head"] = true,
    ["body"] = true,
    ["form"] = true,
    ["header"] = true,
    ["footer"] = true,
    ["main"] = true,
    ["article"] = true,
    ["a"] = true,
    ["p"] = true,
    ["b"] = true,
    ["div"] = true,
    ["li"] = true,
    ["h1"] = true,
    ["h2"] = true,
    ["h3"] = true,
    ["h4"] = true,
    ["h5"] = true,
    ["h6"] = true,
}

api.nvim_set_keymap('i', '>', '', {
    callback = function ()
        local cursor_str = api.nvim_get_current_line()
        local cursor_pos = api.nvim_win_get_cursor(0)
        local prev_str = cursor_str:sub(0, cursor_pos[2])
        local next_str = cursor_str:sub(cursor_pos[2] + 1)

        local comp_tag = prev_str:match("<(%w+)")

        if not complete_tag[comp_tag] or next_str:match("</" .. comp_tag .. ">") then
            return next_str:byte() == 62 and '<RIGHT>' or '>'
        end

        local comp_str = '</' .. comp_tag .. '>'

        return '<RIGHT>' .. comp_str .. string.rep('<LEFT>', #comp_str)
    end,
    expr = true,
    replace_keycodes = true,
    noremap = true,
})

api.nvim_set_keymap('i', '<CR>', '', {
    callback = function ()
        local cursor_str = api.nvim_get_current_line()
        local cursor_col = api.nvim_win_get_cursor(0)[2]
        local cursor_chr = cursor_str:sub(cursor_col, cursor_col + 1)

        return cursor_chr == "><" and "<CR><CR><UP><TAB>" or "<C-x><C-z><CR>"
    end,
    expr = true,
    replace_keycodes = true,
    noremap = true,
})
