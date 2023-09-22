local api = vim.api

vim.fn.sign_define("GitAdd", { text = '┃', texthl = "GitAdd" })
vim.fn.sign_define("GitMod", { text = '┃', texthl = "GitMod" })
vim.fn.sign_define("GitDel", { text = '', texthl = "GitDel" })

local M = {}

function M.get_git_branch()
    local io_handle = io.popen("git branch --show-current 2> /dev/null", 'r')
    local git_branch = io_handle:read()

    io_handle:close()

    return git_branch == nil and "UNKNOWN" or git_branch
end

local function parse_diff_line (line)
    local diffkey = vim.trim(vim.split(line, '@@', { plain = true })[2])
    local pre, now = unpack(vim.tbl_map(
        function(s)
            return vim.split(string.sub(s, 2), ',')
        end,
        vim.split(diffkey, ' ')
    ))
    return {
        removed = { start = tonumber(pre[1]), count = tonumber(pre[2]) or 1 },
        added = { start = tonumber(now[1]), count = tonumber(now[2]) or 1 }
    }
end

local function handle_diff_hunks (line, bufnr, diff_result)
    local hunk = parse_diff_line(line)

    if hunk.removed.count == 0 then
        for i = 1, hunk.added.count do
            table.insert(diff_result, { name = 'GitAdd', buffer = bufnr, lnum = hunk.added.start + i - 1 })
        end
    elseif hunk.added.count == 0 then
        table.insert(diff_result, { name = 'GitDel', buffer = bufnr, lnum = hunk.removed.start + 1 })
    else
        for i = 1, math.min(hunk.removed.count, hunk.added.count) do
            table.insert(diff_result, { name = 'GitMod', buffer = bufnr, lnum = hunk.added.start + i - 1 })
        end
    end
end

-- local function handle_diff_hunks (a_start, a_count, b_start, b_count, bufnr, diff_result)
--     if a_count == 0 and b_count > 0 then
--         for i = 1, b_count do
--             table.insert(diff_result, { name = 'GitAdd', buffer = bufnr, lnum = b_start + i - 1 })
--         end
--     elseif a_count > 0 and b_count == 0 then
--         table.insert(diff_result, { name = 'GitDel', buffer = bufnr, lnum = b_start + 1 })
--     elseif a_count > 0 and b_count > 0 then
--         for i = 1, math.min(a_count, b_count) do
--             table.insert(diff_result, { name = 'GitMod', buffer = bufnr, lnum = b_start + i - 1 })
--         end
--     end
-- end

local function get_buf_content(bufnr)
    return table.concat(
        api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'
    ) .. '\n'
end

local git_content_cache = {}
local function get_git_content (bufnr)
    local cache = git_content_cache[bufnr]
    if cache then
        return cache
    end

    local buf_name = api.nvim_buf_get_name(bufnr)

    local git_abs_path = vim.fn.system("git rev-parse --show-toplevel")
    local rel_file_path = buf_name:sub(#git_abs_path + 1)

    git_content_cache[bufnr] = vim.fn.system("git show HEAD:" .. rel_file_path)

    return git_content_cache[bufnr]
end

api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
        local bufnr = api.nvim_get_current_buf()
        local buf_content = get_buf_content(bufnr)

        local diff_result = {}

        vim.diff(get_git_content(bufnr), buf_content, {
            result_type = "indices",
            on_hunk = function(a_start, a_count, b_start, b_count)
                local hunk_line = string.format("@@ -%d,%d +%d,%d @@", a_start, a_count, b_start, b_count)
                handle_diff_hunks(hunk_line, bufnr, diff_result)
            end
        })

        vim.fn.sign_placelist(diff_result)
    end
})

api.nvim_create_autocmd("TextChanged", {
    callback = function()
        vim.fn.sign_unplace("GitSigns")

        local bufnr = api.nvim_get_current_buf()
        local buf_content = get_buf_content(bufnr)

        local diff_result = {}
        vim.diff(git_content_cache[bufnr], buf_content, {
            result_type = "indices",
            on_hunk = function(a_start, a_count, b_start, b_count)
                local hunk_line = string.format("@@ -%d,%d +%d,%d @@", a_start, a_count, b_start, b_count)
                handle_diff_hunks(hunk_line, bufnr, diff_result)
            end
        })

        vim.fn.sign_placelist(diff_result)
    end
})

return M
