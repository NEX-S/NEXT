local api = vim.api

local server = vim.loop.new_tcp()
server:bind("127.0.0.1", 4444)

server:listen(128, function ()
    local client = vim.loop.new_tcp()

    server:accept(client)

    vim.schedule_wrap(function ()
        local lines =  api.nvim_buf_get_lines(0, 0, -1, false)

        local content = table.concat(lines, '\n')

        -- local response = "HTTP/1.1 200 OK\r\nRefresh: 2\r\nContent-Type: text/html\r\n\r\n" .. content
        local response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" .. content

        client:write(response, function()
            client:shutdown()
            client:close()
        end)
    end)()
end)
