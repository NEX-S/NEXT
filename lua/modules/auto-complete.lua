local api = vim.api

vim.o.infercase   = false
vim.o.completeopt = "menu,menuone,noselect,noinsert"

-- dont affect <C-x><C-p>, affect <C-n>
-- vim.o.complete    = ".,w,b"

local key_tbl = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '_', '#', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
}

_G.COMPLETE_PATH = false
for _, key in ipairs(key_tbl) do
    api.nvim_set_keymap('i', key, '', {
        callback = function ()
            if vim.fn.pumvisible() == 1 then
                return key
            end

            if _G.COMPLETE_PATH then
                return key .. "<C-x><C-f>"
            end

            -- return key .. "<C-x><C-p>"
            return key .. "<C-x><C-o>"
        end,
        expr = true,
        replace_keycodes = true,
        noremap = true,
    })
end

-- api.nvim_set_keymap('i', '/', '', {
--     callback = function ()
--         if vim.fn.pumvisible() == 1 then
--             return '/'
--         end
-- 
--         return '/' .. "<C-x><C-f>"
--     end,
--     expr = true,
--     replace_keycodes = true,
--     noremap = true,
-- })


-- api.nvim_create_autocmd("InsertCharPre", {
--     callback = function ()
--         if vim.fn.pumvisible() == 1 then
--             return
--         end
-- 
--         local char = vim.v.char
--         if char:match("[%w-_#]") then
--             api.nvim_feedkeys(
--                 api.nvim_replace_termcodes("<C-x><C-p>", true, true, true), 'n', false
--             )
--         elseif char == '/' then
--             api.nvim_feedkeys(
--                 api.nvim_replace_termcodes("<C-x><C-f>", true, true, true), 'n', false
--             )
--         end
--     end
-- })

local keymap_tbl = {
    ['/'] = function ()
        _G.COMPLETE_PATH = true

        -- if vim.fn.pumvisible() == 1 then
        --     return '/'
        -- end

        return '/' .. "<C-x><C-f>"
    end,
    -- [' '] = function ()
    --     _G.COMPLETE_PATH = false
    --     return ' '
    -- end,
    ['<TAB>'] = function ()
        if vim.fn.pumvisible() == 1 then
            return '<C-n>'
        end

        if _G.COMPLETE_PATH then
            return "<C-x><C-f>"
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
