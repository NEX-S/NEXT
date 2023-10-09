local api = vim.api

local function open_float_win (bufnr)
    local width  = api.nvim_get_option_value("columns", {})
    local height = api.nvim_get_option_value("lines", {})

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

    api.nvim_set_option_value("winhl", "Normal:FloatTerm", { win = winid })
    api.nvim_set_option_value("winblend", 15, { win = winid })

    return winid
end

local term_winid = 0
local term_bufnr = api.nvim_create_buf(false, true)
local first_open = true

local function on_float_stdout (_, data, _)
    -- for _, line in ipairs(data) do
    --     -- TERM-RELATED
    --     local file = line:match(".+;nvim (%g+)%G.+")
    --     if file then
    --         -- api.nvim_feedkeys(
    --         --     api.nvim_replace_termcodes(":quit!<CR>", true, true, true), 'n', false
    --         -- )
    --         api.nvim_input(":quit!<CR>")
    --         vim.defer_fn(function ()
    --             api.nvim_win_hide(term_winid)
    --             api.nvim_command("tabnew " .. file)
    --         end, 5)
    --     end
    -- end
end

local function float_term ()
    term_winid = open_float_win(term_bufnr)

    if first_open then
        vim.fn.termopen("fish", {
            -- on_stdout = on_float_stdout,
            on_exit = function ()
                term_bufnr = api.nvim_create_buf(false, true)
                first_open = true
            end
        })
        first_open = false
    end

    vim.bo.ft = "TERMINAL"

    api.nvim_buf_set_keymap(0, 't', '<ESC>', '', {
        callback = function ()
            api.nvim_win_hide(term_winid)
        end
    })
end

api.nvim_set_keymap('n', '`', '', {
    callback = function ()
        api.nvim_command("tabnew")

        vim.fn.termopen("fish", {
            on_stdout = function (_, data, _)
                -- for _, line in ipairs(data) do
                --     -- TERM-RELATED
                --     local file = line:match(".+;nvim (%g+)%G.+")
                --     if file then
                --         api.nvim_input(":quit!<CR>")
                --         vim.defer_fn(function ()
                --             api.nvim_command("tabnew " .. file)
                --         end, 5)
                --     end
                -- end
            end,
            on_exit = function ()
                api.nvim_command("quit!")
            end
        })

        vim.bo.ft = "TERMINAL"

        api.nvim_set_option_value("statuscolumn", ' ', { scope = "local" })
        api.nvim_set_option_value("signcolumn", 'no', { scope = "local" })
        api.nvim_buf_set_keymap(0, 't', '<ESC>', '<CMD>quit<CR>', {})
    end
})

-- api.nvim_set_keymap('t', '<ESC>',  "<C-\\><C-n>", { noremap = true })

api.nvim_set_keymap('n', ",x", '', { callback = float_term })

api.nvim_create_autocmd("WinEnter", {
    callback = function ()
        vim.defer_fn(function ()
            if vim.bo.ft == "TERMINAL" then
                api.nvim_command("startinsert!")
            end
        end, 5)
    end
})
