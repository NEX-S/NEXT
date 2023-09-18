local api = vim.api

-- local function get_git_status ()
--     local filename = api.nvim_buf_get_name(0)
--     local lines = api.nvim_buf_get_lines(0, 0, -1, false)
--     local content = table.concat(lines, "\n")
-- 
--     local tmpfile = os.tmpname()
--     local file = io.open(tmpfile, 'w')
--     file:write(content)
--     file:close()
-- 
--     local diff = vim.fn.system("git diff -- " .. filename .. " " .. tmpfile)
-- 
--     local added, changed, deleted = 0, 0, 0
-- 
--     for line in diff:gmatch("[^\r\n]+") do
--         local start_char = line:sub(1,1)
--         if start_char == "+" and line:sub(1,3) ~= "+++" then
--             added = added + 1
--         elseif start_char == "-" and line:sub(1,3) ~= "---" then
--             deleted = deleted + 1
--         end
--     end
-- 
--     changed = math.min(added, deleted)
--     added = added - changed
--     deleted = deleted - changed
-- 
--     return "%#StatusLineGitAdd# + " .. added .. "%#StatusLineGitChange# ~ " .. changed .. "%#StatusLineGitRemove# - " .. deleted 
-- end
-- 
-- local last_changedtick = 0
-- local git_status_str = ''
-- _G.STATUSLINE_GIT_STATUS = function ()
--     local buffer_changedtick = api.nvim_buf_get_changedtick(0)
--     if buffer_changedtick == last_changedtick then
--         return git_status_str
--     end
-- 
--     last_changedtick = buffer_changedtick
--     git_status_str = get_git_status()
-- 
--     return git_status_str
-- end

local M = {}

function M.get_git_branch ()
    local dir = vim.fn.expand("%:h")

    local git_branch = "UNKNOWN"

    local is_inside_git_repo = vim.fn.system("git -C " .. vim.fn.escape(dir, ' ') .. " rev-parse --is-inside-work-tree"):gsub("\n", "")
    
    if is_inside_git_repo == "true" then
        git_branch = vim.fn.system("git -C " .. vim.fn.escape(dir, ' ') .. " rev-parse --abbrev-ref HEAD"):gsub("\n", "")
    end

    return git_branch
end

-- local function get_git_buffer_status ()
--     local filename = vim.api.nvim_buf_get_name(0)
--     local diff_output = vim.fn.systemlist("git diff -U0 -- " .. filename)
-- 
--     local status = {
--         add_row = {},
--         del_row = {},
--         change_row = {}
--     }
-- 
--     local del_start, del_count, add_start, add_count
--     for _, line in ipairs(diff_output) do
--         if line:match("^@@") then
--             del_start, del_count, add_start, add_count = 
--                 line:match("@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
--             del_start = tonumber(del_start)
--             del_count = tonumber(del_count) or 1
--             add_start = tonumber(add_start)
--             add_count = tonumber(add_count) or 1
-- 
--             -- If both lines are deleted and added, it's a change
--             if del_count > 0 and add_count > 0 then
--                 local change_count = math.min(del_count, add_count)
--                 for i = 0, change_count - 1 do
--                     table.insert(status.change_row, add_start + i)
--                 end
--                 if add_count > change_count then
--                     for i = change_count, add_count - 1 do
--                         table.insert(status.add_row, add_start + i)
--                     end
--                 end
--                 if del_count > change_count then
--                     table.insert(status.del_row, del_start)
--                 end
--             elseif del_count > 0 then
--                 table.insert(status.del_row, del_start)
--             elseif add_count > 0 then
--                 for i = 0, add_count - 1 do
--                     table.insert(status.add_row, add_start + i)
--                 end
--             end
--         end
--     end
-- 
--     return status
-- end
-- 
-- api.nvim_set_keymap('n', ',f', '', {
--     callback = function ()
--         api.nvim_command("messages clear")
--         local status = get_git_buffer_status()
--         print(vim.inspect(status))
--     end
-- })

local function str_to_tbl (str)
    local res = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(res, line)
    end
    return res
end

local function parse_diff_str(diff_str)
    local diff_res = {
        del = {},
        add = {},
        chg = {}
    }

    local diff_tbl = str_to_tbl(diff_str)
    local current_line, next_line, is_change, change_counter = nil, nil, false, 0
    for _, line in ipairs(diff_tbl) do
    end

    return diff_res
end

local function get_git_diff_status()
    local buf_file = api.nvim_buf_get_name(0)
    local buf_path = vim.fn.system("git rev-parse --show-prefix"):gsub("\n", '') .. vim.fn.expand("%:t")
    local lines = api.nvim_buf_get_lines(0, 0, -1, false)
    local buf_content = table.concat(lines, '\n') .. '\n'
    local git_content = vim.fn.system("git show HEAD:" .. buf_path)

    local diff_str = vim.diff(buf_content, git_content, {})
    print(diff_str)

    return parse_diff_str(diff_str)
end

api.nvim_set_keymap('n', ',f', '', {
    callback = function ()
        api.nvim_command("messages clear")
        print(vim.inspect(get_git_diff_status()))
    end
})

return M
