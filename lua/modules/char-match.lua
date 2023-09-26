local api = vim.api
local ts  = vim.treesitter

local function ts_function_navigate ()
    local node = ts.get_node()

    local node_type = node:type()

    if node_type == "return_statement" then
        while node do
            local t = node:type()
            if t == "function_definition"
            or t == "function_declaration" then
                local func_s_row, func_s_col = node:range()
                api.nvim_win_set_cursor(0, { func_s_row + 1, func_s_col })
                return
            end

            node = node:parent()
        end
    end

    if node_type == "function_definition" or node_type == "function_declaration" then
        local cursor_row = api.nvim_win_get_cursor(0)[1]

        local func_s_row, _, func_e_row, _ = node:range()

        if cursor_row == func_e_row + 1 then
            api.nvim_win_set_cursor(0, { func_s_row + 1, 0 })
        elseif cursor_row == func_s_row + 1 then
            api.nvim_win_set_cursor(0, { func_e_row + 1, 0 })
        end
    end

    return '%'
end

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

    return ts_function_navigate()
end

api.nvim_set_keymap('n', 'm', '', { callback = quote_match, expr = true, noremap = false, })
api.nvim_set_keymap('x', 'm', '', { callback = quote_match, expr = true, noremap = true, })
