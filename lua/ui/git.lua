local api = vim.api

vim.fn.sign_define("GitAdd", { text = '┃', texthl = "GitAdd" })
vim.fn.sign_define("GitMod", { text = '┃', texthl = "GitMod" })
vim.fn.sign_define("GitDel", { text = '', texthl = "GitDel" })

local M = {}

function M.get_git_branch ()
    local io_handle = io.popen("git branch --show-current 2> /dev/null", 'r')
    local git_branch = io_handle:read()

    io_handle:close()

    return git_branch == nil and "UNKNOWN" or git_branch
end

local function parse_diff_output (diff_output, bufnr)
    local diff_result = {}

    local x1, y1, x2, y2 = 0, 0, 0, 0
    local check_next_prefix = false
    for diff_str in diff_output:gmatch("[^\n]+") do
        local prefix = diff_str:sub(1, 1)

        if check_next_prefix == true then
            if prefix == '+' then
                for i = 1, y2 do
                    table.insert(diff_result, { name = 'GitAdd', buffer = bufnr, lnum = x2 + i - 1 })
                end
            elseif prefix == '-' and y1 == y2 then
                for i = 0, y2 - 1 do
                    table.insert(diff_result, { name = 'GitMod', buffer = bufnr, lnum = x2 + i })
                end
            else
                table.insert(diff_result, { name = 'GitDel', buffer = bufnr, lnum = x2 + 1 })
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
    end

    return diff_result
end


local function get_buf_content (bufnr)
    return table.concat(
        vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'
    ) .. '\n'
end

local git_path_cache = ''
local git_content_cache = ''
local function get_git_content ()

    local file_path = api.nvim_buf_get_name(0)
    local rel_file_path = file_path:sub(#git_path_cache + 1)
    git_content_cache = vim.fn.system("git show HEAD:" .. rel_file_path)

    return git_content_cache

    -- local rel_file_path = vim.fn.expand("%:p:.")
    -- local handle = io.popen("git rev-parse --show-prefix", 'r')
    -- local rel_path_from_root = handle:read("*l")
    -- handle:close()
    -- seems cause crash
    -- handle = io.popen("git show HEAD:./" .. rel_file_path)
    -- local git_content = handle:read("*a")
    -- handle:close()
    -- return git_content
end


-- TODO:
api.nvim_create_autocmd("DirChanged", {
    callback = function ()
        git_path_cache = vim.fn.system("git rev-parse --git-dir"):sub(1, -6)
    end
})

api.nvim_set_keymap('n', ',f', '', {
    callback = function ()
        local git_path = vim.fn.system("git rev-parse --git-dir"):sub(1, -6)
        local file_path = api.nvim_buf_get_name(0)

        print(file_path:sub(#git_path + 1))
    end
})

git_path_cache = vim.fn.system("git rev-parse --git-dir"):sub(1, -6)

api.nvim_create_autocmd("BufWinEnter", {
    callback = function ()
        if M.get_git_branch() == "UNKNOWN" then
            return
        end

        vim.fn.sign_unplace("GitSigns")

        local bufnr = api.nvim_get_current_buf()
        local buf_content = get_buf_content(bufnr)

        local diff_output = vim.diff(get_git_content(), buf_content, {})
        local diff_result = parse_diff_output(diff_output, bufnr)

        vim.fn.sign_placelist(diff_result)
    end
})

api.nvim_create_autocmd("TextChanged", {
    callback = function ()
        vim.fn.sign_unplace("GitSigns")
        local bufnr = api.nvim_get_current_buf()
        local buf_content = get_buf_content(bufnr)

        local diff_output = vim.diff(git_content_cache, buf_content, {})
        local diff_result = parse_diff_output(diff_output, bufnr)

        vim.fn.sign_placelist(diff_result)
    end
})

return M
