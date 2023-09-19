local api = vim.api

local messages = require "ui.messages"

local M = {}

function M.get_git_branch ()
    local dir = vim.fn.expand("%:h")

    local git_branch = vim.fn.system("git branch --show-current 2> /dev/null"):gsub("\n", '')

    return git_branch == '' and "UNKNOWN" or git_branch
end


-- TODO: only render window?
local function parse_diff_output (diff_output)
    local diff_result = {
        add = {},
        mod = {},
        del = {},
    }

    -- for hunk in diff_output:gmatch("@@%s-([^\n]+)") do
    --     -- print(hunk)
    --     local add_s_row, add_count = hunk:match(" -%d+,0 %+(%d+),?(.*) @@$")
    --     add_count = add_count == '' and 1 or tonumber(add_count)
    --     add_s_row = tonumber(add_s_row)
    -- 
    --     for i = 1, add_count do
    --         table.insert(diff_result.add, add_s_row + i - 1)
    --     end
    -- end
    
    for hunk in diff_output:gmatch("@@%s-([^\n]+)") do
        local del_row = hunk:match(" -%d+.* %+(.*),0")
        table.insert(diff_result.del, tonumber(del_row) + 1)
    end

    return diff_result
end

vim.fn.sign_define("GitAdd",     { text = '┃', texthl = "GitAdd" })
vim.fn.sign_define("GitChange",  { text = '┃', texthl = "GitChange" })
vim.fn.sign_define("GitDelete",  { text = '', texthl = "GitDelete" })
vim.fn.sign_define("GitUnstage", { text = '┃', texthl = "GitUnstage" })

local function set_diff_sign (diff_result)
    local bufnr = api.nvim_get_current_buf()
    for _, linenr in ipairs(diff_result.add) do
        vim.fn.sign_place(0, "GitSigns", "GitAdd", bufnr, { lnum = linenr })
    end
    for _, linenr in ipairs(diff_result.del) do
        vim.fn.sign_place(0, "GitSigns", "GitAdd", bufnr, { lnum = linenr })
    end
end

local function func ()
    api.nvim_command("messages clear")

    local buf_id = api.nvim_get_current_buf()
    local buf_content = table.concat(
        api.nvim_buf_get_lines(buf_id, 0, -1, false), '\n'
    )

    local git_content = vim.fn.system("git show HEAD:./" .. vim.fn.expand("%:t") .. " 2> /dev/null")

    local diff_output = vim.diff(git_content, buf_content .. '\n', {})

    -- print(diff_output)

    local diff_result = parse_diff_output(diff_output)
    -- print(vim.inspect(diff_result))
    set_diff_sign(diff_result)
end

api.nvim_set_keymap('n', ',g', '', { callback = func })

-- api.nvim_create_autocmd({ "CursorMoved" }, {
--     callback = func
-- })

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
