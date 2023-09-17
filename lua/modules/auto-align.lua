local api = vim.api

local function get_max_pos (line_tbl, align_char)
    local max_pos = 0
    for i, str in ipairs(line_tbl) do
        local char_pos = str:find(align_char, 1, true) or 0
        max_pos = math.max(max_pos, char_pos)
    end

    return max_pos
end

local function auto_align (table)
    local align_char = table.args

    local s_row = vim.fn.getpos("'<")[2] - 1
    local e_row = vim.fn.getpos("'>")[2]

    local line_tbl = api.nvim_buf_get_lines(0, s_row, e_row, false)

    local max_pos = get_max_pos(line_tbl, align_char)

    for i, str in ipairs(line_tbl) do
        local char_pos = str:find(align_char, 1, true)
        if char_pos ~= nil then
            local padding = string.rep(' ', max_pos - char_pos)
            str = str:sub(1, char_pos - 1) .. padding .. str:sub(char_pos)
            line_tbl[i] = str
        end
    end

    api.nvim_buf_set_lines(0, s_row, e_row, false, line_tbl)
end

api.nvim_create_user_command("A", auto_align, {
    nargs = 1,
    range = '%',
    complete = function ()
        return { "=", "{" }
    end,
})
