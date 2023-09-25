local api = vim.api

local quote_tbl = {
    ['"'] = true,
    ['`'] = true,
    ["'"] = true,
}

local search_back = false
local function quote_match ()
    local cursor_line = api.nvim_get_current_line()
    local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1
    local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)

    if quote_tbl[cursor_char] then
        local cursor_right = cursor_line:sub(cursor_colm + 1)
        if not search_back and cursor_right:match(".*" .. cursor_char) then
            search_back = true
            return 'f' .. cursor_char
        end
        search_back = false
        return 'F' .. cursor_char
    end

    return '%'
end

-- testsetset"sasetasdfasfas"asdfasfasfasfasfd"fsdafasfasfasdf"asdfasfasfasfd"fasdfasfasfasf"aaa
api.nvim_set_keymap('n', 'm', '', { callback = quote_match, expr = true, noremap = true, })
api.nvim_set_keymap('x', 'm', '', { callback = quote_match, expr = true, noremap = true, })
