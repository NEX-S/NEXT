local api = vim.api

api.nvim_set_keymap('n', '`', '', {
    callback = function ()
        api.nvim_command("tabnew term://zsh | startinsert!")
        api.nvim_set_option_value("statuscolumn", ' ', { scope = "local" })
        api.nvim_set_option_value("signcolumn", 'no', { scope = "local" })
        api.nvim_buf_set_keymap(0, 'n', '<ESC>', '<CMD>quit<CR>', {})
    end
})

api.nvim_set_keymap('t', '<ESC>',  "<C-\\><C-n>", { noremap = true })

function open_float_win (bufnr)
    local width  = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    local win_width  = math.ceil(width  * 0.7)
    local win_height = math.ceil(height * 0.7)

    local col = math.ceil((width  - win_width)  * 0.5)
    local row = math.ceil((height - win_height) * 0.4)

    local win_config = {
        row       = row,
        col       = col,
        width     = win_width,
        height    = win_height,
        relative  = "editor",
        style     = "minimal",
        noautocmd = true,
        focusable = true,
        border    = "single",
        title     = " [ TERMINAL ] ",
        title_pos = "right",
    }

    local winid = api.nvim_open_win(bufnr, true, win_config)

    api.nvim_win_set_option(winid, "winhl", "Normal:FloatTerm")
    api.nvim_win_set_option(winid, "winblend", 15)

    return winid
end

local term_buf_nr = api.nvim_create_buf(false, true)
local first_open = true
local function float_term ()
    local term_win_id = open_float_win(term_buf_nr)

    if first_open then
        vim.fn.termopen("zsh", { on_exit = function () end})
        first_open = false
    end

    api.nvim_command("startinsert!")

    api.nvim_buf_set_keymap(0, 't', '<ESC>', '', {
        callback = function ()
            api.nvim_win_hide(term_win_id)
        end
    })
end

api.nvim_set_keymap('n', ",x", '', { callback = float_term })
