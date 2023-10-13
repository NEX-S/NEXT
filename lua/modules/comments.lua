local api = vim.api

local cms_tbl = {
    ["lua"] = "%-%-",
    ["php"] = "//",
    ["c"] = "//",
    ["python"] = "#",
}

local function toggle_line_comment ()
    local cms = cms_tbl[vim.bo.ft]
    local cursor_line = api.nvim_get_current_line()

    if cursor_line:match("^%s*$") then
        return api.nvim_feedkeys("S" .. cms:gsub("%%", '') .. ' ', 'n', false)
    end

    local cursor_row = api.nvim_win_get_cursor(0)[1]

    if cursor_line:match("^%s*" .. cms) then
        cursor_line = cursor_line:gsub("^(%s*)" .. cms .. " ?", "%1")
    else
        cursor_line = cursor_line:gsub("^(%s*)", "%1" .. cms .. " ")
    end

    api.nvim_set_current_line(cursor_line)
end

local function get_select_info (select_tbl, cms)
    local is_commented = true
    local min_indent = math.huge

    for _, str in ipairs(select_tbl) do
        min_indent = math.min(str:find("%S") or math.huge, min_indent)

        if is_commented and not str:match("^%s*" .. cms) then
            is_commented = false
            if min_indent == 1 then break end
        end
    end

    return is_commented, min_indent == math.huge and 0 or min_indent
end


local function toggle_select_comment ()
    local s_row = vim.fn.getpos("v")[2]
    local e_row = api.nvim_win_get_cursor(0)[1]

    local cms = cms_tbl[vim.bo.ft]

    if s_row == e_row then
        return api.nvim_feedkeys("c" .. cms:gsub("%%", '') .. ' ', 'n', false)
    end

    if s_row > e_row then
        s_row, e_row = e_row, s_row
    end
    s_row = s_row - 1

    local select_tbl = api.nvim_buf_get_lines(0, s_row, e_row, false)

    local is_commented, min_indent = get_select_info(select_tbl, cms)

    if is_commented then
        for i, str in ipairs(select_tbl) do
            select_tbl[i] = str:match("^%s*" .. cms .. "%s*$") and '' or str:gsub("^(%s*)" .. cms .. " ?", "%1")
        end
    else
        cms = cms:gsub("%%", '')
        local indent = string.rep(' ', min_indent - 1)
        for i, str in ipairs(select_tbl) do
            select_tbl[i] = indent .. cms .. ' ' .. str:sub(min_indent)
        end
    end

    api.nvim_buf_set_lines(0, s_row, e_row, false, select_tbl)
end

-- maybe vip can replace this?
local function select_comment ()
    local cms = cms_tbl[vim.bo.ft]

    local buffer_lines = api.nvim_buf_get_lines(0, 0, -1, false)
    local cursor_row = api.nvim_win_get_cursor(0)[1]

    local s_row = cursor_row
    local e_row = cursor_row

    for i = s_row, 1, -1 do
        if not buffer_lines[i]:match("^%s*" .. cms) then
            s_row = i + 1
            break
        end
    end

    for i = e_row, #buffer_lines do
        if not buffer_lines[i]:match("^%s*" .. cms) then
            e_row = i - 1
            break
        end
    end

    if s_row - 1 == e_row + 1 then
        return
    end

    vim.fn.setpos("'<", { 0, s_row, 1, 0 })
    vim.fn.setpos("'>", { 0, e_row, 2147483647, 0 })
    api.nvim_input("gv")
end

api.nvim_set_keymap('n', ",c", '', { callback = toggle_line_comment })
api.nvim_set_keymap('x', ",c", '', { callback = toggle_select_comment })
api.nvim_set_keymap('x', "ic", '', { callback = select_comment })
