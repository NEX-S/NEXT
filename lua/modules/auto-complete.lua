local api = vim.api

vim.o.infercase   = false
vim.o.completeopt = "menu,menuone,noselect,noinsert"

-- dont affect <C-x><C-p>, affect <C-n>
-- vim.o.complete    = ".,w,b"

-- dont use nvim_input, it will effect dot-repeat behaviour
api.nvim_create_autocmd("InsertCharPre", {
    callback = function ()
        if vim.fn.pumvisible() == 1 then
            return
        end

        -- local cursor_line = api.nvim_get_current_line()
        -- local cursor_colm = api.nvim_win_get_cursor(0)[2]
        -- local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)
        -- 
        -- if cursor_char:match("[%w-_#]") then
        --     api.nvim_feedkeys(
        --         api.nvim_replace_termcodes("<C-x><C-p>", true, true, true), "n", false
        --     )
        -- elseif cursor_char == '/' then
        --     api.nvim_feedkeys(
        --         api.nvim_replace_termcodes("<C-x><C-f>", true, true, true), "n", false
        --     )
        -- end

        local char = vim.v.char
        if char:match("[%w-_#]") then
            api.nvim_feedkeys(
                api.nvim_replace_termcodes("<C-x><C-p>", true, true, true), 'n', false
            )
        elseif char == '/' then
            api.nvim_feedkeys(
                api.nvim_replace_termcodes("<C-x><C-f>", true, true, true), 'n', false
            )
        end
    end
})

local keymap_tbl = {
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
