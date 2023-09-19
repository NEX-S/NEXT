local api = vim.api

local messages = require "ui.messages"

local M = {}

function M.get_git_branch ()
    local dir = vim.fn.expand("%:h")

    local git_branch = vim.fn.system("git branch --show-current 2> /dev/null"):gsub("\n", '')

    return git_branch == '' and "UNKNOWN" or git_branch
end

local function str_to_tbl (str)
    local res = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(res, line)
    end
    return res
end

-- vim.fn.sign_define("GitAdd", { text = '┃', texthl = "GitAdd" })
-- vim.fn.sign_define("GitMod", { text = '┃', texthl = "GitChange" })
-- vim.fn.sign_define("GitDel", { text = '', texthl = "GitDelete" })

vim.fn.sign_define("GitUnstage", { text = '┃', texthl = "GitUnstage" })


-- TODO: only render window?
local function parse_diff_output (diff_output)
    local diff_result = {
        add = {},
        mod = {},
        del = {},
    }

    -- for x1, y1, x2, y2 in diff_output:gmatch("@@ %-([%d]+),?([%d]*) %+([%d]+),?([%d]*) @@")
    -- do
    --     x1 = tonumber(x1)
    --     x2 = tonumber(x2)
    -- 
    --     y1 = y1 == '' and 1 or tonumber(y1)
    --     y2 = y2 == '' and 1 or tonumber(y2)
    -- 
    --     if y1 == y2 then
    --         for i = 0, y2 - 1 do
    --             table.insert(diff_result.mod, x2 + i)
    --         end
    --     -- 这里不能这么判断。。。。
    --     elseif x2 >= x1 then
    --         for i = 1, y2 do
    --             table.insert(diff_result.add, x2 + i - 1)
    --         end
    --     elseif x2 < x1 then
    --         table.insert(diff_result.del, x2 + 1)
    --     end
    -- end

    return diff_result
end

vim.fn.sign_define("GitAdd", { text = '+', texthl = "GitAdd" })
vim.fn.sign_define("GitMod", { text = '~', texthl = "GitChange" })
vim.fn.sign_define("GitDel", { text = '', texthl = "GitDelete" })

local function set_diff_sign (diff_result)
    vim.fn.sign_unplace("GitSigns")

    local bufnr = api.nvim_get_current_buf()
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

local function diff_buf ()
    api.nvim_command("messages clear")

    local buf_id = api.nvim_get_current_buf()
    local buf_content = table.concat(
        api.nvim_buf_get_lines(buf_id, 0, -1, false), '\n'
    )

    local git_content = vim.fn.system("git show HEAD:./" .. vim.fn.expand("%:t") .. " 2> /dev/null")

    local diff_output = vim.diff(git_content, buf_content .. '\n', {})

    print(diff_output)

    local diff_result = parse_diff_output(diff_output)

    print(vim.inspect(diff_result))

    set_diff_sign(diff_result)
end

api.nvim_set_keymap('n', ',f', '', { callback = diff_buf })

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
