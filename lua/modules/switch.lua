local api = vim.api

local switch_tbl = {
    ["true"] = "false",
    ["false"] = "true",
    ["TRUE"] = "FALSE",
    ["FALSE"] = "TRUE",
    ["True"] = "False",
    ["False"] = "True",
    ["and"] = "or",
    ["or"] = "and",

    ["=="] = "!=",
    ["!="] = "==",
    [">>"] = "<<",
    ["<<"] = ">>",
    ["++"] = "--",
    ["--"] = "++",
    ["||"] = "&&",
    ["&&"] = "||",

    ["<="] = ">",
    [">="] = "<",

    ["-"] = "+",
    ["+"] = "-",
    ["<"] = ">=",
    [">"] = "<=",

    ["'"] = '"',
    ['"'] = "'",
    ['('] = ")",
    [')'] = "(",
    ['['] = "]",
    [']'] = "[",
    ['{'] = "}",
    ['}'] = "{",
    ['0'] = "1",
    ['1'] = "0",

    ["not"] = '',
}

local function quick_switch ()

    local cursor_line = api.nvim_get_current_line()
    local cursor_colm = api.nvim_win_get_cursor(0)[2] + 1

    local cursor_char = cursor_line:sub(cursor_colm, cursor_colm)
    if cursor_char:match("%s") then
        return
    end

    local res = switch_tbl[cursor_line:sub(cursor_colm, cursor_colm + 1)]
    if res then return "msxs" .. res .. '<ESC>`s' end

    res = switch_tbl[cursor_line:sub(cursor_colm - 1, cursor_colm)]
    if res then return "mss<BS>" .. res .. '<ESC>`s' end

    res = switch_tbl[cursor_char]
    if res then return "r" .. res end

    res = switch_tbl[vim.fn.expand("<cword>")]
    if res then return "msciw" .. res .. "<ESC>`s" end

    return ''
end

api.nvim_set_keymap('n', '<C-o>', '', { callback = quick_switch, expr = true, replace_keycodes = true, noremap = true })
