local api = vim.api

require "ft.html.auto-render"

-- some are html5 tag (main article etc)
-- until then, front-end developers use div class="main" :)
local complete_tag = {
    ["a"]  = true,
    ["p"]  = true,
    ["b"]  = true,
    ["i"]  = true,
    ["u"]  = true,
    ["s"]  = true,
    ["q"]  = true,
    ["li"] = true,
    ["rp"] = true,
    ["rt"] = true,
    ["rb"] = true,
    ["ol"] = true,
    ["ul"] = true,
    ["dl"] = true,
    ["dt"] = true,
    ["dd"] = true,
    ["em"] = true,
    ["h1"] = true,
    ["h2"] = true,
    ["h3"] = true,
    ["h4"] = true,
    ["h5"] = true,
    ["h6"] = true,
    ["tr"] = true,
    ["th"] = true,
    ["td"] = true,
    ["div"]  = true,
    ["nav"]  = true,
    ["pre"]  = true,
    ["sub"]  = true,
    ["sup"]  = true,
    ["del"]  = true,
    ["ins"]  = true,
    ["dfn"]  = true,
    ["var"]  = true,
    ["kbd"]  = true,
    ["rbc"]  = true,
    ["bdo"]  = true,
    ["bdi"]  = true,
    ["html"] = true,
    ["head"] = true,
    ["body"] = true,
    ["form"] = true,
    ["span"] = true,
    ["time"] = true,
    ["data"] = true,
    ["code"] = true,
    ["abbr"] = true,
    ["ruby"] = true,
    ["main"] = true,
    ["samp"] = true,
    ["cite"] = true,
    ["mark"] = true,
    ["aside"] = true,
    ["lable"] = true,
    ["small"] = true,
    ["video"] = true,
    ["audeo"] = true,
    ["table"] = true,
    ["thead"] = true,
    ["tbody"] = true,
    ["meter"] = true,
    ["tfoot"] = true,
    ["select"] = true,
    ["dialog"] = true,
    ["header"] = true,
    ["iframe"] = true,
    ["script"] = true,
    ["footer"] = true,
    ["strong"] = true,
    ["legend"] = true,
    ["button"] = true,
    ["object"] = true,
    ["option"] = true,
    ["figure"] = true,
    ["hgroup"] = true,
    ["output"] = true,
    ["section"]  = true,
    ["caption"]  = true,
    ["address"]  = true,
    ["article"]  = true,
    ["details"]  = true,
    ["summary"]  = true,
    ["noscript"] = true,
    ["fieldset"] = true,
    ["colgroup"] = true,
    ["optgroup"] = true,
    ["progress"] = true,
    ["datalist"] = true,
    ["textarea"] = true,
    ["blockquote"] = true,
    ["figcaption"] = true,
}

api.nvim_set_keymap('i', '>', '', {
    callback = function ()
        local cursor_str = api.nvim_get_current_line()
        local cursor_pos = api.nvim_win_get_cursor(0)
        local prev_str = cursor_str:sub(0, cursor_pos[2])
        local next_str = cursor_str:sub(cursor_pos[2] + 1)

        local comp_tag = prev_str:match("<(%w+)")

        -- fixme: <html>...</html|> 
        --                       ^ press > will tag trigger complete.
        -- maybe using stack is better option?
        if not complete_tag[comp_tag] or next_str:match("</" .. comp_tag .. ">") then
            return next_str:byte() == 62 and '<RIGHT>' or '>'
        end

        local comp_str = '</' .. comp_tag .. '>'

        return '<RIGHT>' .. comp_str .. string.rep('<LEFT>', #comp_str)
    end,
    expr = true,
    replace_keycodes = true,
    noremap = true,
})

api.nvim_set_keymap('i', '<CR>', '', {
    callback = function ()
        local cursor_str = api.nvim_get_current_line()
        local cursor_col = api.nvim_win_get_cursor(0)[2]
        local cursor_chr = cursor_str:sub(cursor_col, cursor_col + 1)

        return cursor_chr == "><" and "<CR><CR><UP><TAB>" or "<C-x><C-z><CR>"
    end,
    expr = true,
    replace_keycodes = true,
    noremap = true,
})
