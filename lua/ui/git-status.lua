local api = vim.api

local messages = require "ui.messages"

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

local function str_to_tbl (str)
    local res = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(res, line)
    end
    return res
end

local function parse_diff_str (vim_diff_output)
    local result = {
        add = {},
        del = {},
        mod = {},
    }

    local line_number = 0
    local lines = vim.split(vim_diff_output, '\n')
    for _, line in ipairs(lines) do
        if line:sub(1, 2) == "@@" then
            local parts = vim.split(line, ' ')
            local old_range = parts[2]
            local old_parts = vim.split(old_range, ',')
            local old_start = tonumber(old_parts[1]:sub(2))
            line_number = old_start
        elseif line:sub(1, 1) == '+' then
            table.insert(result.add, line_number + 1)
            line_number = line_number + 1
        end
    end

    return result
end

local function get_diff_info ()
    -- local buf_file = api.nvim_buf_get_name(0)

    local buf_path = vim.fn.system("git rev-parse --show-prefix"):gsub("\n", '') .. vim.fn.expand("%:t")
    local buf_content = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), '\n') .. '\n'
    local git_content = vim.fn.system("git show HEAD:" .. buf_path)

    local diff_res = vim.diff(git_content, buf_content, {})

    return parse_diff_str(diff_res)
end

api.nvim_set_keymap('n', ',f', '', {
    callback = function ()
        api.nvim_command("messages clear")
        local add_tbl = get_diff_info().add
        for _, add_row in ipairs(add_tbl) do
            print(add_row)
        end
    end
})

return M
