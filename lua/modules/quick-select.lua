-- local api = vim.api
-- 
-- local n_map = {
--     ["'"] = "vi'",
--     ['"'] = 'vi"',
--     ["("] = "vi(",
--     ["["] = "vi[",
--     ["{"] = "vi{",
-- 
--     [")"] = "vi(",
--     ["]"] = "vi[",
--     ["}"] = "vi{",
-- }
-- 
-- for key, value in pairs(n_map) do
--     api.nvim_set_keymap('n', key, value, { noremap = true })
-- end
-- 
-- local x_map = {
--     ['"'] = 'vF"vf"',
--     ["'"] = "vF'vf'",
-- 
--     [")"] = "<ESC>f(v%",
--     ["]"] = "<ESC>f[v%",
--     ["}"] = "<ESC>f{v%",
-- }
-- 
-- for key, value in pairs(x_map) do
--     api.nvim_set_keymap('x', key, value, { noremap = true })
-- end
-- 
-- local bracket_tbl = {
-- 	['('] = ')',
-- 	['['] = ']',
-- 	['{'] = '}',
-- }
-- 
-- for key, value in pairs(bracket_tbl) do
--     api.nvim_set_keymap('x', key, '', {
-- 	    callback = function ()
--             local cursor_line = api.nvim_get_current_line()
--             local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1
-- 
--             local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)
--             if cursor_char == value then
--                 return 'i' .. value
--             end
--             return 'a' .. value
-- 	    end,
-- 	    expr = true,
-- 	    noremap = true
--     })
-- end
-- 
-- -- (sadfasdfsadf(aaaaaaaaaaaaaaaaaaaaa(bbbbbbbbbbbbbbbbbbbbbbbb)aaaaaaaaaaaaaaaaa)bvvv)
-- -- aaaaaaaaaaaa(sadfasfasdfsaf)asdfasdfasdf(dasfasfdasfd)asddfasfsadf(sdafasdfasfd)saddfasfasdf(dsafasdfasdf)
-- aaaaa"aaaaaaaaaaaaa"aaaaaaaaaaaaaaaaaaaaa"bbbbbbbbbbbbbbbbbbbbbb"bbbbbbbbbbbbbbbbbbBB"ccccccccccccccccccccccC"ccccccccccccc

local api = vim.api

local n_map = {
    ["'"] = "vi'",
    ['"'] = 'vi"',

    ["("] = "vi(",
    ["["] = "vi[",
    ["{"] = "vi{",

    [")"] = "f(va(",
    ["]"] = "f[va[",
    ["}"] = "f{va{",
}

-- todo: add [ ] { }
local x_map = {
    ['"'] = function ()
        local cursor_line = api.nvim_get_current_line()
        local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1
        local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)

        return cursor_char == '"' and 'vlvi"' or 'vva"'
    end,

    ["'"] = function ()
        local cursor_line = api.nvim_get_current_line()
        local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1
        local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)

        return cursor_char == "'" and "vlvi'" or "vva'"
    end,

    ["("] = function ()
        local cursor_line = api.nvim_get_current_line()
        local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1
        local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)

        return cursor_char == ')' and "i)" or "a)"
    end,

    [")"] = function ()
        local cursor_line = api.nvim_get_current_line()
        local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1
        local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)

        return cursor_char == ')' and "vvi(" or "ovf(va("
    end,
}

for key, value in pairs(n_map) do
    api.nvim_set_keymap('n', key, value, { noremap = true })
end

for key, value in pairs(x_map) do
    api.nvim_set_keymap('x', key, '', { callback = value, expr = true, replace_keycodes = false, noremap = true })
end

