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

local function get_git_buffer_status ()
    local filename = vim.api.nvim_buf_get_name(0)

    local diff_output = vim.fn.systemlist("git diff -U0 -- " .. filename)

    local status = {
        add_row = {},
        del_row = {},
        change_row = {}
    }

    local current_line
    for _, line in ipairs(diff_output) do
        if line:match("^@@") then
            local _, del_start, del_count, add_start, add_count = 
                line:match("@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")

            del_start = tonumber(del_start)
            del_count = tonumber(del_count) or 1
            add_start = tonumber(add_start)
            add_count = tonumber(add_count) or 1

            if del_count > 0 and add_count > 0 then
                table.insert(status.change_row, add_start)
                for i = 1, add_count - 1 do
                    table.insert(status.change_row, add_start + i)
                end
            end

            if del_count > 0 and add_count == 0 then
                table.insert(status.del_row, del_start)
            end

            current_line = add_start
        elseif current_line and line:match("^%+") then
            table.insert(status.add_row, current_line)
            current_line = current_line + 1
        end
    end

    return status
end

api.nvim_command("messages clear")
local status = get_git_buffer_status()
print(vim.inspect(status))

return M
