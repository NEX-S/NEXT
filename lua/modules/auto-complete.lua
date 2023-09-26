-- local api = vim.api
-- 
-- vim.o.infercase   = false
-- vim.o.completeopt = "menu,menuone,noselect,noinsert"
-- 
-- -- dont affect <C-x><C-p>, affect <C-n>
-- -- vim.o.complete    = ".,w,b"
-- 
-- local key_tbl = {
--     'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
--     'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
--     'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
--     'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
--     '_', '#', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
-- }
-- 
-- _G.COMPLETE_PATH = false
-- for _, key in ipairs(key_tbl) do
--     api.nvim_set_keymap('i', key, '', {
--         callback = function ()
--             if vim.fn.pumvisible() == 1 then
--                 return key
--             end
-- 
--             return key .. (_G.COMPLETE_PATH == true and "<C-x><C-f>" or "<C-x><C-p>")
--         end,
--         expr = true,
--         replace_keycodes = true,
--         noremap = true,
--     })
-- end
-- 
-- -- api.nvim_create_autocmd("InsertCharPre", {
-- --     callback = function ()
-- --         if vim.fn.pumvisible() == 1 then
-- --             return
-- --         end
-- -- 
-- --         local char = vim.v.char
-- --         if char:match("[%w-_#]") then
-- --             api.nvim_feedkeys(
-- --                 api.nvim_replace_termcodes("<C-x><C-p>", true, true, true), 'n', false
-- --             )
-- --         elseif char == '/' then
-- --             api.nvim_feedkeys(
-- --                 api.nvim_replace_termcodes("<C-x><C-f>", true, true, true), 'n', false
-- --             )
-- --         end
-- --     end
-- -- })

local api = vim.api

local keymap_tbl = {
    ['/'] = function ()
        _G.COMPLETE_PATH = true
        return '/' .. "<C-x><C-f>"
    end,
    ['<TAB>'] = function ()
        if vim.fn.pumvisible() == 1 then
            return '<C-n>'
        end

        return '<TAB>'
    end,
    ['<S-TAB>'] = function ()
        if vim.fn.pumvisible() == 1 then
            return '<C-p>'
        end

        return '<S-TAB>'
    end,
}

for key, value in pairs(keymap_tbl) do
    api.nvim_set_keymap('i', key, '', { callback = value, expr = true, replace_keycodes = true, noremap = true })
end

api.nvim_create_autocmd("InsertLeave", {
    callback = function ()
        _G.COMPLETE_PATH = false
    end
})

local search_tbl = {
    ['a'] = true, ['b'] = true, ['c'] = true, ['d'] = true, ['e'] = true,
    ['f'] = true, ['g'] = true, ['h'] = true, ['i'] = true, ['j'] = true,
    ['k'] = true, ['l'] = true, ['m'] = true, ['n'] = true, ['o'] = true,
    ['p'] = true, ['q'] = true, ['r'] = true, ['s'] = true, ['t'] = true,
    ['u'] = true, ['v'] = true, ['w'] = true, ['x'] = true, ['y'] = true,
    ['z'] = true, ['A'] = true, ['B'] = true, ['C'] = true, ['D'] = true,
    ['E'] = true, ['F'] = true, ['G'] = true, ['H'] = true, ['I'] = true,
    ['J'] = true, ['K'] = true, ['L'] = true, ['M'] = true, ['N'] = true,
    ['O'] = true, ['P'] = true, ['Q'] = true, ['R'] = true, ['S'] = true,
    ['T'] = true, ['U'] = true, ['V'] = true, ['W'] = true, ['X'] = true,
    ['Y'] = true, ['Z'] = true, ['_'] = true, ['#'] = true, ['0'] = true,
    ['1'] = true, ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true,
    ['6'] = true, ['7'] = true, ['8'] = true, ['9'] = true
}

vim.o.infercase   = false
vim.o.completeopt = "menu,menuone,noselect,noinsert"
vim.o.updatetime = 30
api.nvim_create_autocmd("CursorHoldI", {
    callback = function ()
        if vim.fn.pumvisible() == 1 then
            return
        end

        local cursor_line = api.nvim_get_current_line()
        local cursor_colm = api.nvim_win_get_cursor(0)[2]
        local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)
        local next_char = cursor_line:sub(cursor_colm + 1, cursor_colm + 1)

        if search_tbl[cursor_char] and not search_tbl[next_char] then
            api.nvim_input(_G.COMPLETE_PATH == true and "<C-x><C-f>" or "<C-x><C-p>")
            -- api.nvim_feedkeys(
            --     api.nvim_replace_termcodes(
            --         _G.COMPLETE_PATH == true and "<C-x><C-f>" or "<C-x><C-p>", true, true, true
            --     ), 'n', false
            -- )
        end
    end
})
