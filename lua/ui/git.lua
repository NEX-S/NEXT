local api = vim.api

vim.fn.sign_define("GitAdd", { text = '┃', texthl = "GitAdd" })
vim.fn.sign_define("GitMod", { text = '┃', texthl = "GitMod" })
vim.fn.sign_define("GitDel", { text = '', texthl = "GitDel" })

local M = {}

function M.get_git_branch ()
    local dir = vim.fn.expand("%:h")

    local io_handle = io.popen("git branch --show-current", 'r')

    if io_handle == nil then
        return "UNKNOWN"
    end

    local git_branch = io_handle:read()

    io_handle:close()

    return git_branch
end

local function parse_diff_output (diff_output)
    local diff_result = {
        add = {},
        mod = {},
        del = {},
    }

    local x1, y1, x2, y2 = 0, 0, 0, 0
    local check_next_prefix = false
    for diff_str in diff_output:gmatch("[^\n]+") do
        local prefix = diff_str:sub(1, 1)

        if check_next_prefix == true then
            if prefix == '+' then
                for i = 1, y2 do
                    table.insert(diff_result.add, x2 + i - 1)
                end
            elseif prefix == '-' and y1 == y2 then
                for i = 0, y2 - 1 do
                    table.insert(diff_result.mod, x2 + i)
                end
            else
                table.insert(diff_result.del, x2 + 1)
            end
            check_next_prefix = false
        end

        if prefix == '@' then
            x1, y1, x2, y2 = diff_str:match("@@ %-([%d]+),?([%d]*) %+([%d]+),?([%d]*) @@")
            x1 = tonumber(x1)
            x2 = tonumber(x2)

            y1 = y1 == '' and 1 or tonumber(y1)
            y2 = y2 == '' and 1 or tonumber(y2)
            check_next_prefix = true
        end

        -- if diff_str:match("^@@ .* @@$") then
        --     x1, y1, x2, y2 = diff_str:match("@@ %-([%d]+),?([%d]*) %+([%d]+),?([%d]*) @@")
        --     x1 = tonumber(x1)
        --     x2 = tonumber(x2)
        -- 
        --     y1 = y1 == '' and 1 or tonumber(y1)
        --     y2 = y2 == '' and 1 or tonumber(y2)
        --     check_next_prefix = true
        -- end
        -- 
        -- if check_next_prefix then
        --     if diff_str:match("^%+") then
        --         for i = 1, y2 do
        --             table.insert(diff_result.add, x2 + i - 1)
        --         end
        --         check_next_prefix = false
        --     elseif diff_str:match("^-") and y1 == y2 then
        --         for i = 0, y2 - 1 do
        --             table.insert(diff_result.mod, x2 + i)
        --         end
        --         check_next_prefix = false
        --     elseif diff_str:match("^-") then
        --         table.insert(diff_result.del, x2 + 1)
        --         check_next_prefix = false
        --     end
        -- end
    end

    return diff_result
end

local function set_diff_sign (diff_result, bufnr)
    vim.fn.sign_unplace("GitSigns")

    for _, linenr in ipairs(diff_result.add) do
        vim.fn.sign_place(0, "GitSigns", "GitAdd", bufnr, { lnum = linenr })
    end
    for _, linenr in ipairs(diff_result.del) do
        vim.fn.sign_place(0, "GitSigns", "GitDel", bufnr, { lnum = linenr })
    end
    for _, linenr in ipairs(diff_result.mod) do
        vim.fn.sign_place(0, "GitSigns", "GitMod", bufnr, { lnum = linenr })
    end
end

local function get_buf_content (bufnr)
    return table.concat(
        vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'
    ) .. '\n'
end

local git_content = ""
local function diff_buf ()
    local bufnr = api.nvim_get_current_buf()
    local buf_content = get_buf_content(bufnr)

    local diff_output = vim.diff(git_content, buf_content, {})
    local diff_result = parse_diff_output(diff_output)
    set_diff_sign(diff_result, bufnr)
end

local function get_git_content (callback)
    local rel_file_path = vim.fn.expand("%:p:.")
    
    local handle = io.popen("git rev-parse --show-prefix", 'r')
    local rel_path_from_root = handle:read("*l")
    handle:close()

    -- seems we dont need the async git show?
    local stdout = vim.loop.new_pipe(false)
    handle = vim.loop.spawn("git",
        {
            args = { "show", "HEAD:" .. rel_path_from_root .. rel_file_path },
            stdio = { nil, stdout, nil }
        },
        function(code)
            stdout:read_stop()
            stdout:close()
            handle:close()
        end
    )

    stdout:read_start(
        function(err, data)
            git_content = data ~= nil and data or ""
            vim.schedule_wrap(callback)()
        end
    )
end

api.nvim_create_autocmd("BufWinEnter", {
    callback = function ()
        if M.get_git_branch() == "UNKNOWN" then
            return
        end
        local bufnr = api.nvim_get_current_buf()
        local buf_content = get_buf_content(bufnr)
        get_git_content(function ()
            local diff_output = vim.diff(git_content, buf_content, {})
            local diff_result = parse_diff_output(diff_output)
            set_diff_sign(diff_result, bufnr)
        end)
    end
})

api.nvim_create_autocmd("TextChanged", { callback = diff_buf })

return M
