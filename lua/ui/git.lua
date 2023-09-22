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

local function parse_diff_output(bufnr)
    local buf_name = api.nvim_buf_get_name(bufnr)
    return vim.fn.system(string.format("git diff --no-color HEAD -- %s", buf_name))
end
local function parse_diff_line(line)
    local _, _, removed_start, removed_count, added_start, added_count = 
        line:find("@@ %-(%d+),?(%d*) +%+(%d+),?(%d*) @@")
    
    removed_start = tonumber(removed_start)
    added_start = tonumber(added_start)
    removed_count = tonumber(removed_count) or 1
    added_count = tonumber(added_count) or 1

    return {
        removed = { start = removed_start, count = removed_count },
        added = { start = added_start, count = added_count }
    }
end

local function handle_diff_output(diff_output, bufnr)
    local diff_result = {}
    for line in diff_output:gmatch("[^\r\n]+") do
        if line:sub(1,2) == "@@" then
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
    end
    return diff_result
end

local function get_buf_content(bufnr)
    return table.concat(
        api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'
    ) .. '\n'
end

api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
        local bufnr = api.nvim_get_current_buf()
        local diff_output = parse_diff_output(bufnr)
        local signs = handle_diff_output(diff_output, bufnr)
        vim.fn.sign_placelist(signs)
    end
})

api.nvim_create_autocmd("TextChanged", {
    callback = function()
        vim.fn.sign_unplace("GitSigns")

        local bufnr = api.nvim_get_current_buf()
        local diff_output = parse_diff_output(bufnr)
        local signs = handle_diff_output(diff_output, bufnr)

        vim.fn.sign_placelist(signs)
    end
})

return M

