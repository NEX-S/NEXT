local api = vim.api

local function str_char_count (str, char)
    local count = 0
    local char_byte = char:byte(1)
    for i = 1, #str do
        if str:byte(i) == char_byte then
            count = count + 1
        end
    end
    return count
end

local quote_tbl = {
    ['"'] = '"',
    ["'"] = "'",
    ['`'] = '`',
}

for _, value in pairs(quote_tbl) do
    api.nvim_set_keymap('i', value, '', {
        callback = function ()
            local cursor_line = api.nvim_get_current_line()
            local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1

            local cursor_rchr = cursor_line:sub(cursor_colm, cursor_colm)

            if cursor_rchr == value then
                return '<RIGHT>'
            end

            if cursor_rchr:match("[%w\"']") then
                return value
            end

            if str_char_count(cursor_line, value) % 2 == 0 then
                return value .. value .. '<LEFT>'
            end

            return value
        end,
        expr = true,
        replace_keycodes = true,
        noremap = true,
    })
end

local bracket_tbl = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
}

for key, value in pairs(bracket_tbl) do
    api.nvim_set_keymap('i', key, '', {
        callback = function ()
            local cursor_line = api.nvim_get_current_line()
            local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1

            if cursor_line:sub(cursor_colm, cursor_colm):match("[%w\"']") then
                return key
            end

            if str_char_count(cursor_line, key) >= str_char_count(cursor_line, value) then
                return key .. value .. '<LEFT>'
            end

            return key
        end,
        expr = true,
        replace_keycodes = true,
        noremap = true,
    })
end

local r_bracket_tbl = { ")", "]", "}" }
for _, key in ipairs(r_bracket_tbl) do
    api.nvim_set_keymap('i', key, '', {
        callback = function ()
            local cursor_line = api.nvim_get_current_line()
            local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1

            local cursor_rchr = cursor_line:sub(cursor_colm, cursor_colm)

            if cursor_rchr == key then
                return '<RIGHT>'
            end

            return key
        end,
        expr = true,
        replace_keycodes = true,
        noremap = true,
    })
end

local special_keymap = {
    ["<BS>"] = function ()
        local cursor_line = api.nvim_get_current_line()
        local cursor_colm = api.nvim_win_get_cursor(0)[2]

        local cursor_l = cursor_line:sub(cursor_colm, cursor_colm)
        local cursor_r = cursor_line:sub(cursor_colm + 1, cursor_colm + 1)

        local prev_char = cursor_line:sub(cursor_colm - 1, cursor_colm - 1)

        if quote_tbl[cursor_l] == cursor_r and
            str_char_count(cursor_line, cursor_l) % 2 == 0
            then return "<BS><DEL>" .. (prev_char:match("[%w_-]") and "<C-x><C-p>" or '')
        end

        if bracket_tbl[cursor_l] == cursor_r and
            str_char_count(cursor_line, cursor_l) <= str_char_count(cursor_line, cursor_r)
            then return "<BS><DEL>" .. (prev_char:match("[%w_-]") and "<C-x><C-p>" or '')
        end

        if _G.COMPLETE_PATH then
            return "<BS><C-x><C-f>"
        end

        return '<BS>'
    end,
    ["<CR>"] = function ()
        _G.COMPLETE_PATH = false
        if vim.fn.pumvisible() == 1 then
            return '<C-x><C-z><CR>'
        end

        local cursor_line = api.nvim_get_current_line()
        local cursor_colm = api.nvim_win_get_cursor(0)[2]

        local is_bracket =
            bracket_tbl[cursor_line:sub(cursor_colm, cursor_colm)] == cursor_line:sub(cursor_colm + 1, cursor_colm + 1)

        if is_bracket then
            return "<CR><CR><UP><TAB>"
            -- return "<CR><C-o>O"
        end

        return "<CR>"
    end,
    ["<"] = function ()
        local ft = vim.bo.ft
        local cursor_line = api.nvim_get_current_line()
        if ft == "c" and cursor_line:match("^#include") then
            return "<><LEFT>"
        end

        if ft == "html" and str_char_count(cursor_line, '<') == str_char_count(cursor_line, '>') then
            return "<><LEFT>"
        end

        return "<"
    end,
    [">"] = function ()
        -- local ft = vim.bo.ft
        local cursor_line = api.nvim_get_current_line()
        local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1

        local cursor_r = cursor_line:sub(cursor_colm, cursor_colm)

        if cursor_r == '>' then
            return '<RIGHT>'
        end

        return '>'
    end,
}

for key, value in pairs(special_keymap) do
    api.nvim_set_keymap('i', key, '', { callback = value, expr = true, replace_keycodes = true, noremap = true })
end
