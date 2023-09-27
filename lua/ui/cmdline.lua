local api = vim.api

local function str_to_tbl (str)
    local res = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(res, line)
    end
    return res
end

local M = {}
local messages_winid = 0
local messages_bufnr = api.nvim_create_buf(false, true)
local is_open = false

function M.open_messages_win (str)

    local str_tbl = str_to_tbl(str)

    if is_open == true then
        table.insert(str_tbl, ' ················································')
        table.insert(str_tbl, '')
        api.nvim_buf_set_lines(messages_bufnr, -1, -1, false, str_tbl)
    else
        table.insert(str_tbl, 1, " ")
        table.insert(str_tbl, ' ················································')
        table.insert(str_tbl, '')
        api.nvim_buf_set_lines(messages_bufnr, 0, -1, false, str_tbl)
    end

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

    -- pcall(api.nvim_win_hide, messages_winid)

    messages_winid = api.nvim_open_win(messages_bufnr, false, win_config)

    is_open = true
    api.nvim_set_option_value("filetype", "MESSAGES", { buf = messages_bufnr })

    api.nvim_set_option_value("winhl", "Normal:MessagesWin", { win = messages_winid })
    api.nvim_set_option_value("winblend", 15, { win = messages_winid })

    api.nvim_set_option_value("wrap", true, { win = messages_winid })

    api.nvim_buf_set_keymap(messages_bufnr, 'n', '<ESC>', '', {
        callback = function ()
            is_open = false
            pcall(api.nvim_win_hide, messages_winid)
        end
    })

    return messages_winid
end

_G.CMDLINE_OMNIFUNC = function (findstart, base)
    if findstart == 1 then
        local str = api.nvim_get_current_line():sub(1)
        local _, res = str:find(".*%s")
        return res
    end

    local dict_src = {
        ["command"]    =  "  [COMMAND]",
        ["highlight"]  =  "  [HIGHLIGHT]",
        ["event"]      =  "  [EVENT]",
        ["file"]       =  "  [FILE]",
        ["help"]       =  "  [HELP]",
        ["dir"]        =  "  [DIR]",
        ["option"]     =  "  [OPTION]",
        ["function"]   =  "  [FUNCTION]",
    }

    for src, kind in pairs(dict_src) do
        local src_dict = vim.fn.getcompletion(base, src)
        for i = 1, #src_dict do
            vim.fn.complete_add({ word = src_dict[i], kind = kind })
        end
    end
end

local history_tbl = {}
local history_idx = nil
local function get_cmdline_history ()
    local history_cmd = api.nvim_exec2("history cmd", { output = true }).output
    local history_tbl = str_to_tbl(history_cmd)

    local result = {}
    for i = #history_tbl, 3, -1 do
        local line = history_tbl[i]
        local _, pos = line:find("%d+ +")
        table.insert(result, line:sub(pos + 1))
    end

    return result
end

local cmdline_winid = 0
local cmdline_bufnr = api.nvim_create_buf(false, true)

local function cmdline_init ()
    api.nvim_set_option_value("buftype", "prompt", { buf = cmdline_bufnr })
    api.nvim_set_option_value("omnifunc", "v:lua.CMDLINE_OMNIFUNC", { buf = cmdline_bufnr })

    vim.fn.prompt_setprompt(cmdline_bufnr, "┃ ")
    vim.fn.prompt_setcallback(cmdline_bufnr,
        function (command)
            vim.fn.histadd("cmd", command)

            local output = api.nvim_exec2(command, { output = true }).output

            M.open_messages_win(output)
        end
    )

    local cmdline_keymap = {
        ["<TAB>"] = function ()
            return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-x><C-o>"
        end,
        ["<UP>"] = function ()
            local cmd = history_tbl[history_idx]
            return "<C-u>" .. (cmd ~= nil and cmd or '')
        end,
        ["<DOWN>"] = function ()
            local cmd = history_tbl[history_idx - 2]
            return "<C-u>" .. (cmd ~= nil and cmd or '')
        end,
        ["<ESC>"] = function ()
            return (vim.fn.pumvisible() == 1 and "<C-x>" or '') .. "<CMD>hide<CR>"
        end
    }

    for key, value in pairs(cmdline_keymap) do
        api.nvim_buf_set_keymap(cmdline_bufnr, 'i', key, '', { callback = value, expr = true, replace_keycodes = true, noremap = true })
    end
end

local function open_cmdline_window ()
    local nvim_width  = api.nvim_get_option_value("columns", {})

    local float_width = math.ceil(nvim_width * 0.45)
    local float_colmn = math.ceil(nvim_width - float_width) * 0.5

    local win_config =  {
        row       = 2,
        height    = 1,
        width     = float_width,
        col       = float_colmn,
        noautocmd = true,
        focusable = true,
        relative  = "editor",
        style     = "minimal",
        border    = "none",
    }

    cmdline_winid = api.nvim_open_win(cmdline_bufnr, true, win_config)

    api.nvim_set_option_value("winblend", 25, { win = cmdline_winid })
    api.nvim_set_option_value("winhl", "Normal:CmdLine,FloatBorder:CmdLineBorder", { win = cmdline_winid })
end

cmdline_init()

api.nvim_set_keymap('n', '<F12>', '', {
    callback = function ()
        open_cmdline_window()
        api.nvim_command("startinsert!")

        history_idx = 1
        history_tbl = get_cmdline_history()
    end
})

-- move to clipboard
-- api.nvim_create_autocmd("ExitPre", {
--     callback = function ()
--         api.nvim_command("let @+=@y")
--         os.exit()
--         -- api.nvim_buf_delete(cmdline_bufnr, { force = true })
--     end
-- })

api.nvim_create_user_command("M",
    function ()
        local messages = api.nvim_exec2("messages", { output = true }).output

        if messages ~= '' then
            M.open_messages_win(messages)
        end
    end, {}
)

return M
