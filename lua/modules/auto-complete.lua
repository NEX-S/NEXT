local api = vim.api

vim.o.infercase   = false
vim.o.completeopt = "menu,menuone,noselect,noinsert"

-- dont affect <C-x><C-p>, affect <C-n>
-- vim.o.complete    = ".,w,b"

api.nvim_create_autocmd("InsertCharPre", {
    callback = function ()
        if vim.fn.pumvisible() == 1 then
            return
        end

        local char = vim.v.char
        if char:match("[%w-_#]") then
            api.nvim_input("<C-x><C-p>")
        elseif char == '/' then
            api.nvim_input("<C-x><C-f>")
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
