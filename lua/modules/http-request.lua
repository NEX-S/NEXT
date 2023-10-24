_G.string.split = function (str, separator)
    local res, last_pos = {}, 0
    for part, pos in str:gmatch("(.-)"..separator.."()") do
        table.insert(res, part)
        last_pos = pos
    end
    table.insert(res, str:sub(last_pos))
    return res
end

local api = vim.api

local http_layout = {
    url = { bufnr = nil, winid = nil },
    req = { bufnr = nil, winid = nil },
    res = { bufnr = nil, winid = nil },
}

local function parse_url (url)
    url = url:gsub("^%s*https?://", '')

    local server_addr, server_port, server_path, request_method, request_data =
    url:match("([^/ ^ ^:]+):?(%d*)/?(%g*)%s?(%g*)%s?(.*)")

    server_port = server_port == '' and 80 or server_port
    request_method = request_method == '' and "GET" or request_method

    return server_addr, server_port, server_path, request_method, request_data
end

local function generate_http_request (server_addr, server_port, server_path, request_method, request_data)
    local http_request = {
        string.upper(request_method) .. " /" .. server_path .. " HTTP/1.1",
        "Host: " .. server_addr .. (server_port == 80 and '' or ':' .. server_port),
        -- "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.5938.132 Safari/537.36",
        -- "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        -- "Accept-Encoding: gzip, deflate, br",
        -- "Accept-Language: en-US,en;q=0.9",
        -- "Connection: close",
    }

    if request_data ~= '' then
        table.insert(http_request, "Content-Length: " .. #request_data)
        table.insert(http_request, "")

        local lines = string.split(request_data, "\\n")
        for _, line in ipairs(lines) do
            table.insert(http_request, line)
        end
    else
        table.insert(http_request, "")
        table.insert(http_request, "")
    end

    return http_request
end

-- local function send_request_async (server_addr, server_port, request_content, callback)
--     local stdin  = uv.new_pipe()
--     local stdout = uv.new_pipe()
-- 
--     local handle = nil
--     handle = uv.spawn("nc", {
--         args = { server_addr, server_port },
--         stdio = { stdin, stdout, nil },
--     },
--         function ()
--             stdout:read_stop()
--             stdout:close()
--             handle:close()
--         end
--     )
-- 
--     uv.write(stdin, request_content, function ()
--         stdin:shutdown()
--         stdin:close()
--     end)
-- 
--     uv.read_start(stdout, function (_, data)
--         if data ~= nil and data:match("^HTTP") then
--             vim.schedule_wrap(callback)(data)
--         end
--     end)
-- end

local function send_request_async(server_addr, server_port, request_content, callback)
    vim.loop.getaddrinfo(server_addr, nil, { socktype = vim.loop.SOCK_STREAM }, function(err, res)
        local server_ip = res[1].addr
        local tcp = vim.loop.new_tcp()

        tcp:connect(server_ip, server_port, function(err)
            tcp:write(request_content, function(err)
                tcp:shutdown(function()
                    tcp:read_start(function(err, data)
                        tcp:close()
                        if data then
                            vim.schedule_wrap(callback)(data)
                        end
                    end)
                end)
            end)
        end)
    end)
end

local function http_request_layout_init ()
    api.nvim_command("tabnew")

    local function set_win_options ()
        api.nvim_set_option_value('statuscolumn', ' ', {})
        api.nvim_set_option_value('signcolumn', 'no', {})
        api.nvim_set_option_value('number', false, {})
        vim.bo.ft = "http"
    end

    http_layout.url.bufnr = api.nvim_create_buf(false, true)
    http_layout.req.bufnr = api.nvim_create_buf(false, true)
    http_layout.res.bufnr = api.nvim_create_buf(false, true)

    -- setup request buffer
    api.nvim_command("split")
    api.nvim_win_set_buf(0, http_layout.req.bufnr)
    http_layout.req.winid = api.nvim_get_current_win()
    set_win_options()

    -- setup response buffer
    api.nvim_command("vsplit")
    api.nvim_win_set_buf(0, http_layout.res.bufnr)
    http_layout.res.winid = api.nvim_get_current_win()
    set_win_options()

    -- setup url buffer
    api.nvim_command("wincmd k")
    api.nvim_win_set_height(0, 1)
    api.nvim_win_set_buf(0, http_layout.url.bufnr)
    http_layout.url.winid = api.nvim_get_current_win()
    api.nvim_set_option_value("buftype", "prompt", { buf = http_layout.url.bufnr })
    vim.fn.prompt_setprompt(http_layout.url.bufnr, " ")
    set_win_options()

    -- api.nvim_set_option_value('ft', "http", { buf = http_layout.req.bufnr })
    -- api.nvim_set_option_value('ft', "http", { buf = http_layout.res.bufnr })

    api.nvim_command("startinsert!")

    api.nvim_buf_set_keymap(http_layout.req.bufnr, 'n', '<CR>', '', {
        callback = function ()
            api.nvim_buf_set_lines(http_layout.res.bufnr, 0, -1, false, {})

            local http_request = api.nvim_buf_get_lines(http_layout.req.bufnr, 0, -1, false)

            local request_content = table.concat(http_request, "\r\n")

            local request_data = request_content:match("\r\n\r\n(.*)$")

            if request_data ~= nil and request_data ~= '' then
                if not request_content:match("Content%-Length: %d+") then
                    request_content = request_content:gsub("\r\n\r\n", "\r\nContent-Length: " .. #request_data .. "\r\n\r\n", 1)
                else
                    request_content = request_content:gsub("Content%-Length: %d+", "Content-Length: " .. #request_data)
                end

                api.nvim_buf_set_lines(http_layout.req.bufnr, 0, -1, false, string.split(request_content, "\r\n"))
            else
                request_content = request_content .. "\r\n\r\n"
            end

            local url = api.nvim_buf_get_lines(http_layout.url.bufnr, 0, 1, false)[1]:sub(5)
            local server_addr, server_port = parse_url(url)

            send_request_async(server_addr, server_port, request_content,
                function (data)
                    local http_response = string.split(data:gsub('\r', ''), '\n')
                    api.nvim_buf_set_lines(http_layout.res.bufnr, 0, -1, false, http_response)
                end
            )
        end
    })

    api.nvim_buf_set_keymap(http_layout.url.bufnr, 'i', '<CR>', '', {
        callback = function ()
            api.nvim_buf_set_lines(http_layout.res.bufnr, 0, -1, false, {})

            local url = api.nvim_buf_get_lines(http_layout.url.bufnr, 0, 1, false)[1]:sub(5)

            local server_addr, server_port, server_path, request_method, request_data = parse_url(url)
            local http_request = generate_http_request(server_addr, server_port, server_path, request_method, request_data)
            api.nvim_buf_set_lines(http_layout.req.bufnr, 0, -1, false, http_request)

            send_request_async(server_addr, server_port, table.concat(http_request, "\r\n"),
                function (data)
                    local http_response = string.split(data:gsub('\r\n', '\n'), '\n')
                    api.nvim_buf_set_lines(http_layout.res.bufnr, 0, -1, false, http_response)
                end
            )
        end
    })
end

api.nvim_create_user_command("HTTP", http_request_layout_init, {})
