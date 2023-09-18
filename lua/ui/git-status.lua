local api = vim.api

local messages = require "ui.messages"

local M = {}

function M.get_git_branch ()
    local dir = vim.fn.expand("%:h")

    local git_branch = vim.fn.system("git branch --show-current 2> /dev/null"):gsub("\n", '')

    return git_branch == '' and "UNKNOWN" or git_branch
end

local function parse_diff_output (diff_output)
    local diff_result = {
        add = {},
        del = {},
        mod = {},
    }

    return diff_result
end

local function func ()
    api.nvim_command("messages clear")

    local buf_id = api.nvim_get_current_buf()
    local buf_content = table.concat(
        api.nvim_buf_get_lines(buf_id, 0, -1, false), '\n'
    )

    local git_content = vim.fn.system("git show HEAD:./" .. vim.fn.expand("%:t") .. " 2> /dev/null")

    local diff_output = vim.diff(git_content, buf_content .. '\n', {})

    print(diff_output)

    local diff_result = parse_diff_output(diff_output)
end

api.nvim_create_autocmd({ "CursorMoved" }, {
    callback = func
})

return M

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
