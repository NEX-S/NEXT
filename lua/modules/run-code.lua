local api = vim.api

local open_messages_win = require "ui.cmdline".open_messages_win

os.execute("mkdir -p /tmp/nvim-run-code/")

local function expand_cmd (str)
    local gsub_tbl = {
        ["%$FILENAME"] = vim.fn.expand("%:r"),
        ["%$FILEPATH"] = api.nvim_buf_get_name(0),
    }

    for key, value in pairs(gsub_tbl) do
        str = str:gsub(key, value)
    end

    return str
end

local function open_vert_win (bufnr)
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

    local winid = api.nvim_open_win(bufnr, true, win_config)

    api.nvim_set_option_value("winhl", "Normal:RunCodeWin", { win = winid })
    api.nvim_set_option_value("winblend", 15, { win = winid })

    return winid
end

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
        title     = " [ RUN CODE ]",
        title_pos = "right",
    }

    local winid = api.nvim_open_win(bufnr, true, win_config)

    api.nvim_win_set_option(winid, "winhl", "Normal:FloatTerm")
    api.nvim_win_set_option(winid, "winblend", 15)

    return winid
end

local ft_cmd_tbl = {
    ["lua"] = function ()
        local output = api.nvim_exec2("source %", { output = true }).output

        if output ~= '' then
            open_messages_win(output)
        end
    end,
    ["c"] = "gcc $FILEPATH -lm -o /tmp/nvim-run-code/$FILENAME.bin && time /tmp/nvim-run-code/$FILENAME.bin",
    ["python"] = "python3 $FILEPATH",
    ["php"] = "php $FILEPATH",
    ["javascript"] = "node $FILEPATH",
    ["typescript"] = "ts-node $FILEPATH",
    -- ["http"] = "cat $FILEPATH | nc httpbin.org 80",
}

local function run_code ()
    api.nvim_command("write ++p")

    local ft_cmd = ft_cmd_tbl[vim.bo.ft]

    if type(ft_cmd) == "function" then
        return ft_cmd()
    end

    -- must before opening the window
    local cmd = expand_cmd(ft_cmd)

    local run_code_bufnr = api.nvim_create_buf(false, true)
    local run_code_winid = open_vert_win(run_code_bufnr)
    -- local run_code_winid = open_float_win(run_code_bufnr)

    vim.fn.termopen(cmd)

    api.nvim_command("startinsert!")

    api.nvim_buf_set_keymap(run_code_bufnr, 't', '<ESC>', '', {
        callback = function ()
            api.nvim_win_hide(run_code_winid)
        end
    })
end

api.nvim_set_keymap('n', ",r", '', { callback = run_code })
