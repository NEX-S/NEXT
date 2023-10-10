local api = vim.api

local M = {}

local uv = vim.loop

function M.send_request ()
    local buffer_lines = api.nvim_buf_get_lines(0, 0, -1, false)
    local server_addr = buffer_lines[1]:match("^(%g+) ")
    local server_port = buffer_lines[1]:match("^.* (%d+)")

    table.remove(buffer_lines, 1)
    table.remove(buffer_lines, 1)

    local buffer_content = table.concat(buffer_lines, '\n')
    buffer_content = buffer_content .. "\n\n"

    local stdin = uv.new_pipe()
    local stdout = uv.new_pipe()

    local handle = nil
    handle = uv.spawn("nc", {
        args = { server_info, server_port },
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
            print(data)
        end
    end)
end

return M
