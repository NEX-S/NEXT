-- local api = vim.api
--
-- local namespace_id = api.nvim_create_namespace("indentline")
--
-- local indent_str_cache = {}
-- local function get_indent_str (line_indent, shiftwidth)
--     local cache = indent_str_cache[line_indent]
--     if cache ~= nil then
--         return cache
--     end
--
--     local indent_str = '·'
--     local char = '╎'
--     for i = 1, line_indent - 1 do
--         if i % shiftwidth == 0 then
--             indent_str = indent_str .. char
--             char = char == '╎' and '│' or '╎'
--         else
--             indent_str = indent_str .. '·'
--         end
--     end
--
--     indent_str_cache[line_indent] = indent_str
--
--     return indent_str
-- end
--
-- local function render_window_indent ()
--     local win_s_row = vim.fn.getpos("w0")[2] - 1
--     local win_e_row = vim.fn.getpos("w$")[2]
--
--     local bufnr = api.nvim_get_current_buf()
--
--     api.nvim_buf_clear_namespace(bufnr, namespace_id, win_s_row, win_e_row)
--
--     local line_tbl = api.nvim_buf_get_lines(bufnr, win_s_row, win_e_row, false)
--
--     local shiftwidth = api.nvim_get_option_value("shiftwidth", {})
--
--     local prev_indent_str = ''
--     for i, str in ipairs(line_tbl) do
--         local line_indent = str:find("%S")
--
--         if line_indent ~= 1 then
--             local indent_str = line_indent == nil
--                 and prev_indent_str or get_indent_str(line_indent - 1, shiftwidth)
--
--             prev_indent_str = indent_str
--
--             api.nvim_buf_set_extmark(bufnr, namespace_id, win_s_row + i - 1, 0, {
--                 hl_mode = "combine",
--                 virt_text = {
--                     { indent_str, "NonText" },
--                 },
--                 virt_text_pos = "overlay",
--                 -- right_gravity = true,
--                 -- ephemeral = true,
--             })
--         else
--             prev_indent_str = ''
--         end
--     end
-- end
--
-- api.nvim_create_autocmd(
--     { "TextChanged", "TextChangedI", "InsertCharPre", }, {
--         callback = render_window_indent
--     }
-- )
--
-- api.nvim_create_autocmd(
--     { "WinScrolled", "BufWinEnter", }, {
--         callback = function ()
--             vim.defer_fn(function ()
--                 render_window_indent()
--             end, 10)
--         end
--     }
-- )
--
-- local function select_indent ()
--     local cursor_indent = vim.fn.indent('.')
--
--     local buf_line_tbl = api.nvim_buf_get_lines(0, 0, -1, false)
--     local s_row = api.nvim_win_get_cursor(0)[1]
--     local e_row = s_row
--
--     if cursor_indent == 0 then
--         local prev_pos = 1
--         for i = s_row, 1, -1 do
--             local line_str = buf_line_tbl[i]
--             local char_pos = line_str:find("%S")
--
--             if char_pos == nil and prev_pos == 1 then
--                 s_row = s_row + 1
--                 break
--             else
--                 prev_pos = char_pos
--                 s_row = s_row - 1
--             end
--         end
--
--         for i = e_row, #buf_line_tbl do
--             local line_str = buf_line_tbl[i]
--             local char_pos = line_str:find("%S")
--
--             if char_pos == nil and prev_pos == 1 then
--                 e_row = e_row - 1
--                 break
--             else
--                 prev_pos = char_pos
--                 e_row = e_row + 1
--             end
--         end
--     else
--         for i = s_row - 1, 1, -1 do
--             local line_str = buf_line_tbl[i]
--             if not line_str:match("^%s*$") then
--                 if line_str:find("%S") - 1 < cursor_indent then break end
--             end
--             s_row = s_row - 1
--         end
--
--         for i = e_row + 1, api.nvim_buf_line_count(0) do
--             local line_str = buf_line_tbl[i]
--             if not line_str:match("^%s*$") then
--                 if line_str:find("%S") - 1 < cursor_indent then break end
--             end
--             e_row = e_row + 1
--         end
--     end
--
--     api.nvim_win_set_cursor(0, { s_row, 0 })
--
--     local offset = e_row - s_row
--
--     if offset == 0 then
--         api.nvim_feedkeys('vV', 'n', false)
--     else
--         api.nvim_feedkeys('vV' .. offset .. 'j', 'n', false)
--     end
-- end
--
-- api.nvim_set_keymap('x', 'ii', '', { callback = select_indent })

-----------------------------------------------------------------------------------------------------
-- local api = vim.api
-- 
-- local nvim_create_autocmd, nvim_buf_set_extmark = api.nvim_create_autocmd, api.nvim_buf_set_extmark
-- local mini = {}
-- 
-- local ns = api.nvim_create_namespace('IndentLine')
-- 
-- local function col_in_screen(col)
--     local leftcol = vim.fn.winsaveview().leftcol
--     return col >= leftcol
-- end
-- 
-- local function hl_group()
--     return 'IndentLine'
-- end
-- 
-- local function indent_step(bufnr)
--     if vim.fn.exists('*shiftwidth') == 1 then
--         return vim.fn.shiftwidth()
--     elseif vim.fn.exists('&shiftwidth') == 1 then
--         -- implementation of shiftwidth builtin
--         if vim.bo[bufnr].shiftwidth ~= 0 then
--             return vim.bo[bufnr].shiftwidth
--         elseif vim.bo[bufnr].tabstop ~= 0 then
--             return vim.bo[bufnr].tabstop
--         end
--     end
-- end
-- 
-- local function indentline()
--     local function on_win(_, _, bufnr, _)
--         if bufnr ~= vim.api.nvim_get_current_buf() then
--             return false
--         end
--     end
-- 
--     local ctx = {}
--     local function on_line(_, _, bufnr, row)
--         local indent = vim.fn.indent(row + 1)
--         local ok, lines = pcall(api.nvim_buf_get_text, bufnr, row, 0, row, -1, {})
--         if not ok then
--             return
--         end
--         local text = lines[1]
--         local prev = ctx[row - 1] or 0
--         if indent == 0 and #text == 0 and prev > 0 then
--             indent = prev > 20 and 4 or prev
--         end
-- 
--         local hi_name = hl_group()
-- 
--         ctx[row] = indent
-- 
--         for i = 1, indent - 1, indent_step(bufnr) do
--             if col_in_screen(i - 1) then
--                 local param, col = {}, 0
--                 if #text == 0 and i - 1 > 0 then
--                     param = {
--                         virt_text = { { mini.char, hi_name } },
--                         virt_text_pos = 'overlay',
--                         virt_text_win_col = i - 1,
--                         hl_mode = 'combine',
--                         ephemeral = true,
--                     }
--                 else
--                     param = {
--                         virt_text = { { mini.char, hi_name } },
--                         virt_text_pos = 'overlay',
--                         hl_mode = 'combine',
--                         ephemeral = true,
--                     }
--                     col = i - 1
--                 end
-- 
--                 nvim_buf_set_extmark(bufnr, ns, row, col, param)
--             end
--         end
--     end
-- 
--     local function on_end()
--         ctx = {}
--     end
-- 
--     local function on_start(_, _)
--         local bufnr = api.nvim_get_current_buf()
--         local exclude_buftype = { 'nofile', 'terminal' }
--         if
--             vim.tbl_contains(exclude_buftype, vim.bo[bufnr].buftype)
--             or not vim.bo[bufnr].expandtab
--             or vim.tbl_contains(mini.exclude, vim.bo[bufnr].ft)
--         then
--             return false
--         end
--     end
-- 
--     api.nvim_set_decoration_provider(ns, {
--         on_win = on_win,
--         on_start = on_start,
--         on_line = on_line,
--         on_end = on_end,
--     })
-- end
-- 
-- local function default_exclude()
--     return { 'dashboard', 'lazy', 'help', 'markdown' }
-- end
-- 
-- local function setup(opt)
--     mini = vim.tbl_extend('force', {
--         char = '┇',
--         exclude = default_exclude(),
--     }, opt or {})
-- 
--     local group = api.nvim_create_augroup('IndentMini', { clear = true })
--     nvim_create_autocmd('BufEnter', {
--         group = group,
--         callback = function()
--             indentline()
--         end,
--     })
-- end
-- 
-- setup()
-- 
-- return {
--     setup = setup,
-- }

local api = vim.api

local namespace_id = api.nvim_create_namespace("indentline")

local indent_str_cache = {}
local function get_indent_str (line_indent, shiftwidth)
    local cache = indent_str_cache[line_indent]
    if cache ~= nil then
        return cache
    end

    local indent_str = '·'
    local char = '╎'
    for i = 1, line_indent - 1 do
        if i % shiftwidth == 0 then
            indent_str = indent_str .. char
            char = char == '╎' and '│' or '╎'
        else
            indent_str = indent_str .. '·'
        end
    end

    indent_str_cache[line_indent] = indent_str

    return indent_str
end

local shiftwidth = 0
local function render_window_indent (_, _, bufnr, win_s_row, win_e_row)
    -- api.nvim_buf_clear_namespace(bufnr, namespace_id, win_s_row, win_e_row)
    local line_tbl = api.nvim_buf_get_lines(bufnr, win_s_row , win_e_row, false)

    local prev_indent_str = ''
    for i, str in ipairs(line_tbl) do
        local line_indent = str:find("%S")

        if line_indent ~= 1 then
            local indent_str = line_indent == nil
                and prev_indent_str or get_indent_str(line_indent - 1, shiftwidth)

            prev_indent_str = indent_str

            api.nvim_buf_set_extmark(bufnr, namespace_id, win_s_row + i - 1, 0, {
                hl_mode = "combine",
                virt_text = {
                    { indent_str, "NonText" },
                },
                virt_text_pos = "overlay",
                ephemeral = true,
            })
        else
            prev_indent_str = ''
        end
    end
end

local exclude_buftype = {
    ["help"] = true,
}

api.nvim_create_autocmd("BufEnter", {
    callback = function ()
        shiftwidth = api.nvim_get_option_value("shiftwidth", {})
        api.nvim_set_decoration_provider(namespace_id, {
            on_start = function ()
                local buftype = api.nvim_get_option_value("buftype", {
                    buf = api.nvim_get_current_buf()
                })

                if exclude_buftype[buftype] then
                    return false
                end
            end,
            on_win = render_window_indent,
        })
    end
})
