local api = vim.api

local n_mode = {
    ["j"] = "gj",
    ["k"] = "gk",
    ["J"] = "8gj",
    ["K"] = "8gk",
    ["H"] = "_",
    ["L"] = "$",

    ["c"] = "s",

    ["x"] = "<C-v>",
    ["s"] = "viw",
    ["S"] = "viW",
    ["e"] = "ve",
    ["E"] = "vE",

    ["z"] = "m'",

    ["U"] = "<C-r>",

    [">"] = ">>",
    ["<"] = "<<",

    ["<ESC>"] = ",",

    ["y"] = '"yy',
    ["p"] = '"yp',

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

    -- file action
    ["gf"] = "<CMD>tabnew <cfile><CR>"
}

for key, value in pairs(n_mode) do
    api.nvim_set_keymap('n', key, value, { noremap = true })
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
    ["<C-r>"] = '"ay<CMD>let @/=@a<CR>cgn',
}

for key, value in pairs(x_mode) do
    api.nvim_set_keymap('x', key, value, { noremap = true, silent = true })
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
    end,
    ["<C-s>"] = function ()
        local cursor_file = vim.fn.expand("<cfile>")
        local file_prefix = cursor_file:sub(1, 1)
        if file_prefix == '/' or file_prefix == '~' then
            return "<CMD>vsp " .. cursor_file .. "<CR>"
        end

        return "<C-w>v"
    end
}

for key, value in pairs(n_func) do
    api.nvim_set_keymap('n', key, '', { callback = value, expr = true, replace_keycodes = true, noremap = true })
end
