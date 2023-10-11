local api = vim.api

local function str_to_tbl (str)
    local res = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(res, line)
    end
    return res
end

local response_winid = -1
local response_bufnr = api.nvim_create_buf(false, true)
local function open_response_win (http_response)

    api.nvim_buf_set_lines(
        response_bufnr, 0, -1, false, str_to_tbl(http_response:gsub('\r', ''))
    )

    if api.nvim_win_is_valid(response_winid) then
        return
    end

    local win_config = {
        relative  = "editor",
        row       = 1,
        col       = vim.o.columns,
        height    = vim.o.lines - 2,
        width     = math.floor(vim.o.columns * 0.5),
        style     = "minimal",
        focusable = true,
        noautocmd = true,
        border = { '', '', '', '', '', '', '', '│' }
    }

    response_winid = api.nvim_open_win(response_bufnr, false, win_config)

    api.nvim_set_option_value("filetype", "http", { buf = response_bufnr })
    api.nvim_set_option_value("winhl", "Normal:responseWin", { win = response_winid })
    api.nvim_set_option_value("winblend", 0, { win = response_winid })
    api.nvim_set_option_value("foldenable", false, { win = response_winid })
    api.nvim_set_option_value("wrap", false, { win = response_winid })

    return response_winid
end

local function parse_url (url)
    url = url:gsub("^https?://", '')

    local host, port, path, method, post_data = string.match(url, "([^:/]+):?(%d*)/?(%g*)%s?(%g*)%s?(.*)")

    if port == '' then
        port = 80
    end

    if method == '' then
        method = "GET"
    end

    print(host, port, path, string.upper(method), post_data)

    return host, port, path, string.upper(method), post_data
end

local function generate_http_request (host, port, path, method, post_data)
    if method == "POST" then
        return {
            "",
            "POST /" .. path .. " HTTP/1.1",
            "Host: " .. host .. ':' .. port,
            "Content-Length: " .. #post_data,
            "Connection: close",
            "",
            post_data
        }
    end

    if method == "GET" then
        return {
            "",
            "GET /" .. path .. " HTTP/1.1",
            "Host: " .. host .. ':' .. port,
            "Connection: close",
        }
    end

    -- TODO: other method
    return {
        "",
        "GET /" .. path .. " HTTP/1.1",
        "Host: " .. host .. ':' .. port,
        "Connection: close",
    }
end

local uv = vim.loop
local function async_send_request (server_addr, server_port, http_request)
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

    uv.write(stdin, http_request, function ()
        stdin:shutdown()
        stdin:close()
    end)

    uv.read_start(stdout, function (_, data)
        if data ~= nila and data:match("^HTTP") then
            vim.schedule_wrap(open_response_win)(data)
        end
    end)
end

local M = {}

function M.send_request ()
    local buffer_lines = api.nvim_buf_get_lines(0, 0, -1, false)

    local server_addr, server_port, request_path, request_method, post_data = parse_url(buffer_lines[1])

    local http_request = {}

    if #buffer_lines == 1 then
        http_request = generate_http_request(server_addr, server_port, request_path, request_method, post_data)
        api.nvim_buf_set_lines(0, -1, -1, false, http_request)
    else
        http_request = buffer_lines
        table.remove(http_request, 1)
        table.remove(http_request, 1)
    end

    async_send_request(
        server_addr,
        server_port,
        table.concat(http_request, '\r\n') .. "\r\n\r\n"
    )

    -- vim.system({ "nc", server_addr, server_port }, { stdin = buffer_content, text = true },
    --     function (obj)
    --         print(obj.stdout)
    --     end
    -- )
end

return M
