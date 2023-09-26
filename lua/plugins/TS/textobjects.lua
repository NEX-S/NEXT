local ts = vim.treesitter
local api = vim.api

local function get_cursor_function_range ()
    local node = ts.get_node()
    while node do
        local node_type = node:type()
        if node_type == "function_definition"
        or node_type == "function_declaration" then
            local func_s_row,
                  func_s_col,
                  func_e_row,
                  func_e_col
            = node:range()

            return func_s_row + 1,
                   func_s_col + 1,
                   func_e_row + 1,
                   func_e_col + 1
        end

        node = node:parent()
    end

    return false
end

api.nvim_set_keymap('x', "af", '', {
    callback = function ()
        local func_s_row,
              func_s_col,
              func_e_row,
              func_e_col
        = get_cursor_function_range()

        if func_s_row == false then
            return
        end

        vim.fn.setpos("'<", { 0, func_s_row, func_s_col, 0 })
        vim.fn.setpos("'>", { 0, func_e_row, func_e_col, 0 })

        api.nvim_input("gv")
    end
})

api.nvim_set_keymap('x', "if", '', {
    callback = function ()
        local func_s_row,
              func_s_col,
              func_e_row,
              func_e_col
        = get_cursor_function_range()

        if func_s_row == false then
            return
        end

        vim.fn.setpos("'<", { 0, func_s_row + 1, 0, 0 })
        vim.fn.setpos("'>", { 0, func_e_row - 1, 2147483647, 0 })

        api.nvim_input("gv")
    end
})
