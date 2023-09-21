local api = vim.api

local namespace_id = api.nvim_create_namespace("indnetlines")

local indent_str_cache = {}
local function get_indent_str (line_indent, shiftwidth)

    local n = math.floor(line_indent / shiftwidth)

    local cache_str = indent_str_cache[n]
    if cache_str ~= nil then
        return cache_str
    end

    local block_1 = '╎' .. string.rep('·', shiftwidth - 1)
    local block_2 = '│' .. string.rep('·', shiftwidth - 1)

    local indent_str = string.rep('·', shiftwidth)
    for i = 2, n do
        indent_str = indent_str .. (i % 2 == 0 and block_1 or block_2)
    end

    indent_str_cache[n] = indent_str

    return indent_str
end

local function render_window_indent (re_render)
    local win_s_row = vim.fn.getpos("w0")[2] - 1
    local win_e_row = vim.fn.getpos("w$")[2]

    local bufnr = api.nvim_get_current_buf()

    if re_render == true then
        api.nvim_buf_clear_namespace(bufnr, namespace_id, win_s_row, win_e_row)
    end

    local line_tbl = api.nvim_buf_get_lines(bufnr, win_s_row, win_e_row, false)

    local shiftwidth = api.nvim_get_option_value("shiftwidth", {})

    local prev_indent_str = ''
    for i, str in ipairs(line_tbl) do
        local line_indent = str:find("%S")

        if line_indent ~= 1 then
            local indent_str = line_indent == nil
                and prev_indent_str or get_indent_str(line_indent, shiftwidth)

            prev_indent_str = indent_str

            api.nvim_buf_set_extmark(bufnr, namespace_id, win_s_row + i - 1, 0, {
                hl_mode = "combine",
                virt_text = {
                    { indent_str, "NonText" },
                },
                virt_text_pos = "overlay",
            })
        else
            prev_indent_str = ''
        end
    end
end

api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    callback = function ()
        vim.defer_fn(function ()
            render_window_indent(true)
        end, 5)
    end
})

api.nvim_create_autocmd("InsertCharPre", {
    callback = function ()
        vim.defer_fn(function ()
            render_window_indent(true)
        end, 5)
    end
})

api.nvim_create_autocmd({ "WinScrolled", "BufWinEnter", }, {
    callback = function ()
        vim.defer_fn(function ()
            render_window_indent(false)
        end, 10)
	end
})

----------------------------

local function select_indent ()
    local cursor_indent = vim.fn.indent('.')

    local buf_line_tbl = api.nvim_buf_get_lines(0, 0, -1, false)
    local s_row = api.nvim_win_get_cursor(0)[1]
    local e_row = s_row

    if cursor_indent == 0 then
        for i = s_row - 1, 1, -1 do
            local line_str = buf_line_tbl[i]
            if line_str:match("^%s*$") then break end
            s_row = s_row - 1
        end

        for i = e_row + 1, api.nvim_buf_line_count(0) do
            local line_str = buf_line_tbl[i]
            if line_str:match("^%s*$") then break end
            e_row = e_row + 1
        end
    else
        for i = s_row - 1, 1, -1 do
            local line_str = buf_line_tbl[i]
            if not line_str:match("^%s*$") then
                if line_str:find("%S") - 1 < cursor_indent then break end
            end
            s_row = s_row - 1
        end

        for i = e_row + 1, api.nvim_buf_line_count(0) do
            local line_str = buf_line_tbl[i]
            if not line_str:match("^%s*$") then
                if line_str:find("%S") - 1 < cursor_indent then break end
            end
            e_row = e_row + 1
        end
    end

    api.nvim_win_set_cursor(0, { s_row, 0 })
    local offset = e_row - s_row

    if offset == 0 then
        api.nvim_feedkeys('vV', 'n', false)
    else
        api.nvim_feedkeys('vV' .. offset .. 'j', 'n', false)
    end
end

api.nvim_set_keymap('x', 'ii', '', { callback = select_indent })


-- local api = vim.api
-- 
-- local namespace_id = api.nvim_create_namespace("indnetlines")
-- 
-- local indent_str_cache = {}
-- local function get_indent_str (indent)
--     local n = indent / 4 - 1
-- 
--     if indent_str_cache[n] then
--         return indent_str_cache[n]
--     end
-- 
--     local block_1 = "│···"
--     local block_2 = "╎···"
-- 
--     local res = indent >= 4 and "····" or ''
--     for i = 1, n do
--         res = res .. (i % 2 == 0 and block_1 or block_2)
--     end
-- 
--     indent_str_cache[n] = res
--     return res
-- end
-- 
-- local function line_render (row, str)
--     local indent = str:find("%S") or 1
--     local indent_str = get_indent_str(indent - 1)
--     api.nvim_buf_set_extmark(0, namespace_id, row, 0, {
--         hl_mode = "combine",
--             virt_text = {
--             { indent_str, "NonText" },
--         },
--         virt_text_pos = "overlay",
--     })
-- end
-- 
-- local function render_window_indentline (re_render)
--     local win_s_row = vim.fn.getpos("w0")[2]
--     local win_e_row = vim.fn.getpos("w$")[2]
-- 
--     if re_render == true then
--         api.nvim_buf_clear_namespace(0, namespace_id, win_s_row, win_e_row)
--     end
-- 
--     local str_tbl = api.nvim_buf_get_lines(0, win_s_row, win_e_row, false)
-- 
--     local prev_str = ''
-- 
--     for i, str in ipairs(str_tbl) do
--         if str ~= '' then
--             line_render(win_s_row + i - 1, str)
--             prev_str = str
--         else
--             line_render(win_s_row + i - 1, prev_str)
--         end
--     end
-- end
-- 
-- api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertCharPre" }, {
--     callback = function ()
--         vim.defer_fn(function ()
--             render_window_indentline(true)
--         end, 2)
--     end
-- })
-- api.nvim_create_autocmd({ "WinScrolled", "BufWinEnter", }, {
--     callback = render_window_indentline
-- })
