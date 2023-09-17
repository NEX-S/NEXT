local api = vim.api

local namespace_id = api.nvim_create_namespace("indnetlines")

-- seems dont need to render all buffer
local function render_buffer ()
end

local indent_str_cache = {}
local function get_indent_str (indent)
    local n = indent / 4 - 1

    if indent_str_cache[n] then
        return indent_str_cache[n]
    end

    local block_1 = "│···"
    local block_2 = "╎···"

    local res = indent >= 4 and "····" or ''
    for i = 1, n do
        res = res .. (i % 2 == 0 and block_1 or block_2)
    end

    indent_str_cache[n] = res
    return res
end

local function line_render (row, str)
    local indent = str:find("%S") or 1
    local indent_str = get_indent_str(indent - 1)
    api.nvim_buf_set_extmark(0, namespace_id, row, 0, {
        hl_mode = "combine",
            virt_text = {
            { indent_str, "NonText" },
        },
        virt_text_pos = "overlay",
        -- strict = false,
        -- right_gravity = true,
    })
end

local function render_window_indentline (re_render)
    local win_s_row = vim.fn.getpos("w0")[2]
    local win_e_row = vim.fn.getpos("w$")[2]

    if re_render == true then
        api.nvim_buf_clear_namespace(0, namespace_id, win_s_row, win_e_row)
    end

    local str_tbl = api.nvim_buf_get_lines(0, win_s_row, win_e_row, false)

    local prev_str = ''

    for i, str in ipairs(str_tbl) do
        if str ~= '' then
            line_render(win_s_row + i - 1, str)
            prev_str = str
        else
            line_render(win_s_row + i - 1, prev_str)
        end
    end
end

api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertCharPre" }, {
    callback = function ()
        vim.defer_fn(function ()
            render_window_indentline(true)
        end, 2)
    end
})
api.nvim_create_autocmd({ "WinScrolled", "BufWinEnter", }, {
    callback = render_window_indentline
})

local function select_indent ()
    local cursor_indent = vim.fn.indent('.')

    local buf_line_tbl = api.nvim_buf_get_lines(0, 0, -1, false)
    local s_row = api.nvim_win_get_cursor(0)[1]
    local e_row = s_row

    for i = s_row - 1, 1, -1 do
        local line_str = buf_line_tbl[i]
        if not line_str:match("^%s*$") then
            if line_str:find("%S") - 1 >= cursor_indent then
                s_row = i
            else
                break
            end
        end
    end

    for i = e_row + 1, api.nvim_buf_line_count(0) do
        local line_str = buf_line_tbl[i]
        if not line_str:match("^%s*$") then
            if line_str:find("%S") - 1 >= cursor_indent then
                e_row = i
            else
                break
            end
        end
    end

    api.nvim_win_set_cursor(0, { s_row, 0 })
    api.nvim_feedkeys('vV' .. (e_row - s_row) .. 'j', 'n', false)
end

api.nvim_set_keymap('x', 'ii', '', { callback = select_indent })
-- longgggggggggggggggggglinelonggggggggggggggggggglinelonggggggggggggggggggglinelonggggggggggggggggggglinelonggggggggggggggggggglinelonggggggggggggggggggglinelonggggggggggggggggggglinelonggggggggggggggggggglinelonggggggggggggggggggglinelonggggggggggggggggggglinelongggggggggggggggggggline
