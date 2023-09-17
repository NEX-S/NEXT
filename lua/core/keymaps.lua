local api = vim.api

local n_mode = {
    ["J"] = "8gj",
    ["K"] = "8gk",
    ["H"] = "_",
    ["L"] = "$",

    ["c"] = "s",
    
    ["x"] = "<C-v>",
    ["s"] = "viw",
    ["S"] = "viW",

    ["U"] = "<C-r>",

    [">"] = ">>",
    ["<"] = "<<",

    ["<ESC>"] = ",",

    ["y"] = '"yy',
    ["p"] = '"yp',

    -- TODO:
    ["/"] = "<CMD>set hls!<CR>",

    -- ["<C-;>"] = "<CMD>set hls!<CR>",
    -- ["\\"] = "<CMD>set hls!<CR>",
    -- ["<CR>"] = "<CMD>set hls!<CR>",

    ["<TAB>"] = "<C-w><C-w>",

    ["gs"] = "gg",
    ["ge"] = "G",

    ["m"] = "%",
    ["+"] = "mjJ`j",

    ["<C-d>"] = '"ddd',
    ["<C-c>"] = "cc",
    ["<C-w>"] = "<CMD>write ++p<CR>",
    ["<C-q>"] = "<CMD>quit!<CR>",
    ["<C-p>"] = '"dp',
    ["<C-s>"] = "<C-w>v",

    ["<C-h>"] = "gT",
    ["<C-j>"] = "gt",
    ["<C-k>"] = "<C-i>",
    ["<C-l>"] = "<C-o>",

    ["<LEFT>"] = "gT",
    ["<RIGHT>"] = "gt",
    ["<DOWN>"] = "<C-i>",
    ["<UP>"] = "<C-o>",

    ["<C-f>"] = "/",
    ["<C-/>"] = "ggVG$",
}

for key, value in pairs(n_mode) do
    api.nvim_set_keymap('n', key, value, { noremap = true })
end 

local i_mode = {
    ["<C-h>"] = "<C-g>u<C-w>",
    ["<C-l>"] = "<C-o>g+",

    -- ["<LEFT>"] = "<C-g>u<C-w>",
    -- ["<RIGHT>"] = "<C-o>u",
}

for key, value in pairs(i_mode) do
    api.nvim_set_keymap('i', key, value, { noremap = true, silent = true })
end 

local x_mode = {
    ["J"] = "8gj",
    ["K"] = "8gk",
    ["H"] = "_",
    ["L"] = "$h",

    ["gs"] = "gg",
    ["ge"] = "G",

    [">"] = ">gv",
    ["<"] = "<gv",

    ["d"] = '"dd',
    ["y"] = 'my"yy`y',
    ["p"] = 'd"yP',
    ["<C-p>"] = 'd"dP',
}

for key, value in pairs(x_mode) do
    api.nvim_set_keymap('x', key, value, { noremap = true })
end

local n_func = {
    ["d"] = function ()
        local cursor_line = api.nvim_get_current_line()

        if cursor_line == '' or cursor_line:match("^%s*$") then
            return "dd"
        end

        return 'x'
    end,
    ["a"] = function ()
        local cursor_line = api.nvim_get_current_line()

        if cursor_line == '' or cursor_line:match("^%s*$") then
            return "S"
        end

        return 'a'
    end
}

for key, value in pairs(n_func) do
    api.nvim_set_keymap('n', key, '', { callback = value, expr = true, noremap = true })
end
