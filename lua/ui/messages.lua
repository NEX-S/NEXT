local M = {}

local api = vim.api

function M.str_to_tbl (str)
    local res = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(res, line)
    end
    return res
end

local messages_winid = 0
local messages_bufnr = api.nvim_create_buf(false, true)
local is_open = false

function M.open_messages_win (str)
    -- replace all contents
    -- api.nvim_buf_set_lines(messages_bufnr, 0, -1, false, str)

    -- append contents
    api.nvim_buf_set_lines(messages_bufnr, -1, -1, false, str)

    if is_open then
        return messages_winid
    end

    local win_config = {
        relative  = "editor",
        row       = 1,
        col       = vim.o.columns,
        height    = vim.o.lines - 2,
        width     = math.floor(vim.o.columns * 0.3),
        style     = "minimal",
        focusable = true,
        noautocmd = true,
    }

    pcall(api.nvim_win_hide, messages_winid)

    messages_winid = api.nvim_open_win(messages_bufnr, false, win_config)

    is_open = true

    api.nvim_win_set_option(messages_winid, "winhl", "Normal:MessagesWin")
    api.nvim_win_set_option(messages_winid, "winblend", 15)

    api.nvim_set_option_value("wrap", true, { win = messages_winid })

    api.nvim_buf_set_keymap(messages_bufnr, 'n', '<ESC>', '', {
        callback = function ()
            is_open = false
            api.nvim_win_hide(messages_winid)
        end
    })
    api.nvim_buf_set_keymap(0, 'n', '<ESC>', '', {
        callback = function ()
            is_open = false
            pcall(api.nvim_win_hide, messages_winid)
        end
    })
    

    return messages_winid
end

api.nvim_create_user_command("M",
    function ()
        local messages = M.str_to_tbl(
            api.nvim_exec2("messages", { output = true }).output
        )

        if messages ~= '' then
            M.open_messages_win(messages)
        end
    end, {}
)

return M
