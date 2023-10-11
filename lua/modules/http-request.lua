local api = vim.api

local function str_to_tbl (str)
    local res = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(res, line)
    end
    return res
end

local is_open = false
local response_winid = -1
local response_bufnr = api.nvim_create_buf(false, true)
local function open_response_win ()
    local win_config = {
        relative  = "editor",
        row       = 1,
        col       = vim.o.columns,
        height    = vim.o.lines - 2,
        width     = math.floor(vim.o.columns * 0.5),
        style     = "minimal",
        focusable = true,
        noautocmd = true,
        -- border = "single",
        -- border = "shadow",
        border = {
            '', '', '', '', '', '', '', '│'
        }
    }

    response_winid = api.nvim_open_win(response_bufnr, false, win_config)

    is_open = true

    api.nvim_set_option_value("filetype", "http", { buf = response_bufnr })

    api.nvim_set_option_value("winhl", "Normal:responseWin", { win = response_winid })
    api.nvim_set_option_value("winblend", 0, { win = response_winid })

    api.nvim_set_option_value("foldenable", false, { win = response_winid })

    api.nvim_set_option_value("wrap", false, { win = response_winid })

    return response_winid
end

local M = {}

local uv = vim.loop

local function parse_address_port (input)
    input = input:gsub("^https?://", '')
    input = input:gsub("/$", '')

    local address, port = input:match("^(.-):(%d+)$")

    if not port then
        address = input
        port = 80
    end

    return address, port
end

function M.send_request ()
    local buffer_lines = api.nvim_buf_get_lines(0, 0, -1, false)
    local server_addr, server_port = parse_address_port(buffer_lines[1])

    table.remove(buffer_lines, 1)
    table.remove(buffer_lines, 1)

    local buffer_content = table.concat(buffer_lines, '\r\n') .. "\r\n\r\n"

    -- vim.system({ "nc", server_addr, server_port }, { stdin = buffer_content, text = true },
    --     function (obj)
    --         print(obj.stdout)
    --     end
    -- )

    local stdin = uv.new_pipe()
    local stdout = uv.new_pipe()

    local handle = nil
    handle = uv.spawn("nc", {
        args = { server_addr, server_port },
        stdio = { stdin, stdout, nil },
    },
        function ()
            stdout:read_stop()
            stdout:close()
            handle:close()
        end
    )

    uv.write(stdin, buffer_content, function ()
        stdin:shutdown()
        stdin:close()
    end)

    uv.read_start(stdout, function (_, data)
        if data ~= nil and data ~= '' then
            vim.schedule_wrap(function ()
                api.nvim_buf_set_lines(response_bufnr, 0, -1, false, str_to_tbl(data:gsub('\r', '')))

                if not api.nvim_win_is_valid(response_winid) then
                    response_winid = open_response_win()
                end
            end)()
        end
    end)
end

return M
