local api = vim.api

-- os.execute("mkdir -p ~/.cache/nvim/view")

local fold_options = {
    foldenable   = true,
    foldmethod   = "indent",
    foldminlines = 4,
    foldcolumn   = '1',
    foldtext     = "v:lua.FOLD_TEXT()",
    -- viewdir      = "~/.cache/nvim/view",

    -- treesitter fold
    -- foldmethod = "expr",
    -- foldexpr = "nvim_treesitter#foldexpr()",
}

vim.opt.fillchars:append("fold: ,foldsep:╎,foldopen:~,foldclose:~")

for key, value in pairs(fold_options) do
    api.nvim_set_option_value(key, value, {})
end

_G.FOLD_TEXT = function ()
    local s_row = vim.v.foldstart
    local s_str = api.nvim_buf_get_lines(0, s_row - 1, s_row, false)[1]
    local indent = s_str:find("%S") - 1

    -- return s_str .. ' '
    return string.rep(' ', indent - 2) .. '' .. s_str:sub(indent) .. " ..."
end

api.nvim_set_keymap('n', ' ', "za", { noremap = true })
