-- local api = vim.api
-- 
-- vim.fn.sign_define("GitAdd", { text = '┃', texthl = "GitAdd" })
-- vim.fn.sign_define("GitMod", { text = '┃', texthl = "GitMod" })
-- vim.fn.sign_define("GitDel", { text = '', texthl = "GitDel" })
-- 
-- local M = {}
-- 
-- function M.get_git_branch ()
--     local io_handle = io.popen("git branch --show-current 2> /dev/null", 'r')
--     local git_branch = io_handle:read()
-- 
--     io_handle:close()
-- 
--     return git_branch == nil and "UNKNOWN" or git_branch
-- end
-- 
-- -- local function parse_diff_output (diff_output, bufnr)
-- --     local diff_result = {}
-- -- 
-- --     local x1, y1, x2, y2 = 0, 0, 0, 0
-- --     local check_next_prefix = false
-- --     for diff_str in diff_output:gmatch("[^\n]+") do
-- --         local prefix = diff_str:sub(1, 1)
-- -- 
-- --         if check_next_prefix == true then
-- --             if prefix == '+' then
-- --                 for i = 1, y2 do
-- --                     table.insert(diff_result, { name = 'GitAdd', buffer = bufnr, lnum = x2 + i - 1 })
-- --                 end
-- --             elseif prefix == '-' and y1 == y2 then
-- --                 for i = 0, y2 - 1 do
-- --                     table.insert(diff_result, { name = 'GitMod', buffer = bufnr, lnum = x2 + i })
-- --                 end
-- --             else
-- --                 table.insert(diff_result, { name = 'GitDel', buffer = bufnr, lnum = x2 + 1 })
-- --             end
-- --             check_next_prefix = false
-- --         end
-- -- 
-- --         if prefix == '@' then
-- --             x1, y1, x2, y2 = diff_str:match("@@ %-([%d]+),?([%d]*) %+([%d]+),?([%d]*) @@")
-- --             x1 = tonumber(x1)
-- --             x2 = tonumber(x2)
-- -- 
-- --             y1 = y1 == '' and 1 or tonumber(y1)
-- --             y2 = y2 == '' and 1 or tonumber(y2)
-- --             check_next_prefix = true
-- --         end
-- --     end
-- -- 
-- --     return diff_result
-- -- end
-- 
-- -- GPT-4 generate this, dont know if it's right ;)
-- local function parse_diff_output(diff_output, bufnr)
--     local diff_result = {}
-- 
--     local x1, y1, x2, y2 = 0, 0, 0, 0
--     local in_hunk = false
--     local added, deleted = 0, 0
-- 
--     for diff_str in diff_output:gmatch("[^\n]+") do
--         local prefix = diff_str:sub(1, 1)
-- 
--         if prefix == '@' then
--             -- If we are entering a new hunk, process the previous one
--             if in_hunk then
--                 if added > 0 and deleted == 0 then
--                     for i = 1, added do
--                         table.insert(diff_result, { name = 'GitAdd', buffer = bufnr, lnum = x2 + i - 1 })
--                     end
--                 elseif added == 0 and deleted > 0 then
--                     table.insert(diff_result, { name = 'GitDel', buffer = bufnr, lnum = x2 + 1 })
--                 elseif added > 0 and deleted > 0 then
--                     for i = 1, math.min(added, deleted) do
--                         table.insert(diff_result, { name = 'GitMod', buffer = bufnr, lnum = x2 + i - 1 })
--                     end
--                 end
--                 added, deleted = 0, 0
--             end
-- 
--             -- Parse the hunk header
--             x1, y1, x2, y2 = diff_str:match("@@ %-([%d]+),?([%d]*) %+([%d]+),?([%d]*) @@")
--             x1, x2 = tonumber(x1), tonumber(x2)
--             y1, y2 = y1 == '' and 1 or tonumber(y1), y2 == '' and 1 or tonumber(y2)
--             in_hunk = true
--         elseif in_hunk then
--             if prefix == '+' then
--                 added = added + 1
--             elseif prefix == '-' then
--                 deleted = deleted + 1
--             end
--         end
--     end
-- 
--     -- Handle the last hunk
--     if added > 0 and deleted == 0 then
--         for i = 1, added do
--             table.insert(diff_result, { name = 'GitAdd', buffer = bufnr, lnum = x2 + i - 1 })
--         end
--     elseif added == 0 and deleted > 0 then
--         table.insert(diff_result, { name = 'GitDel', buffer = bufnr, lnum = x2 + 1 })
--     elseif added > 0 and deleted > 0 then
--         for i = 1, math.min(added, deleted) do
--             table.insert(diff_result, { name = 'GitMod', buffer = bufnr, lnum = x2 + i - 1 })
--         end
--     end
-- 
--     return diff_result
-- end
-- 
-- local function get_buf_content (bufnr)
--     return table.concat(
--         api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'
--     ) .. '\n'
-- end
-- 
-- local git_content_cache = {}
-- local function get_git_content (bufnr)
--     local cache = git_content_cache[bufnr]
--     if cache then
--         return cache
--     end
-- 
--     local buf_name = api.nvim_buf_get_name(bufnr)
-- 
--     local git_abs_path = vim.fn.system("git rev-parse --show-toplevel")
--     local rel_file_path = buf_name:sub(#git_abs_path + 1)
-- 
--     git_content_cache[bufnr] = vim.fn.system("git show HEAD:" .. rel_file_path)
-- 
--     return git_content_cache[bufnr]
-- end
-- 
-- api.nvim_create_autocmd("BufWinEnter", {
--     callback = function ()
--         -- vim.fn.sign_unplace("GitSigns")
-- 
--         local bufnr = api.nvim_get_current_buf()
--         local buf_content = get_buf_content(bufnr)
--         local diff_output = vim.diff(get_git_content(bufnr), buf_content, {})
--         local diff_result = parse_diff_output(diff_output, bufnr)
-- 
--         vim.fn.sign_placelist(diff_result)
--     end
-- })
-- 
-- api.nvim_create_autocmd("TextChanged", {
--     callback = function ()
--         vim.fn.sign_unplace("GitSigns")
-- 
--         local bufnr = api.nvim_get_current_buf()
--         local buf_content = get_buf_content(bufnr)
--         local diff_output = vim.diff(git_content_cache[bufnr], buf_content, {})
--         local diff_result = parse_diff_output(diff_output, bufnr)
-- 
--         vim.fn.sign_placelist(diff_result)
--     end
-- })
-- 
-- return M

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

local function handle_diff_hunks(a_start, a_count, b_start, b_count, bufnr, diff_result)
    if a_count == 0 and b_count > 0 then
        for i = 1, b_count do
            table.insert(diff_result, { name = 'GitAdd', buffer = bufnr, lnum = b_start + i - 1 })
        end
    elseif a_count > 0 and b_count == 0 then
        table.insert(diff_result, { name = 'GitDel', buffer = bufnr, lnum = b_start + 1 })
    elseif a_count > 0 and b_count > 0 then
        for i = 1, math.min(a_count, b_count) do
            table.insert(diff_result, { name = 'GitMod', buffer = bufnr, lnum = b_start + i - 1 })
        end
    end
end

local function get_buf_content(bufnr)
    return table.concat(
        api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'
    ) .. '\n'
end

local git_content_cache = {}
local function get_git_content(bufnr)
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
            result_type = 'indices',
            on_hunk = function(a_start, a_count, b_start, b_count)
                handle_diff_hunks(a_start, a_count, b_start, b_count, bufnr, diff_result)
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
            result_type = 'indices',
            on_hunk = function(a_start, a_count, b_start, b_count)
                handle_diff_hunks(a_start, a_count, b_start, b_count, bufnr, diff_result)
            end
        })

        print(vim.inspect(diff_result))

        vim.fn.sign_placelist(diff_result)
    end
})

return M
