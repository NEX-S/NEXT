local api = vim.api

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

vim.fn.sign_define("GitAdd", { text = '┃', texthl = "GitAdd" })
vim.fn.sign_define("GitMod", { text = '┃', texthl = "GitMod" })
vim.fn.sign_define("GitDel", { text = '', texthl = "GitDel" })

-- TODO: only render window?
local function parse_diff_output (diff_output)
    local diff_result = {
        add = {},
        mod = {},
        del = {},
    }

    diff_output = str_to_tbl(diff_output)

    local check_line = false
    local x1, y1, x2, y2 = 0, 0, 0, 0
    for _, diff_str in ipairs(diff_output) do
        if diff_str:match("^@@ .* @@$") then
            x1, y1, x2, y2 = diff_str:match("@@ %-([%d]+),?([%d]*) %+([%d]+),?([%d]*) @@")
            x1 = tonumber(x1)
            x2 = tonumber(x2)

            y1 = y1 == '' and 0 or tonumber(y1)
            y2 = y2 == '' and 0 or tonumber(y2)
            check_line = true
        end

        if check_line then
            if diff_str:match("^%+") then
                for i = 1, y2 do
                    table.insert(diff_result.add, x2 + i - 1)
                end
                check_line = false
            elseif diff_str:match("^-") and y1 == y2 then
                for i = 0, y2 - 1 do
                    table.insert(diff_result.mod, x2 + i)
                end
                check_line = false
            elseif diff_str:match("^-") then
                table.insert(diff_result.del, x2)
                check_line = false
            end
        end

    end

    return diff_result
end

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
    local buf_id = api.nvim_get_current_buf()
    local buf_content = table.concat(
        api.nvim_buf_get_lines(buf_id, 0, -1, false), '\n'
    )

    local git_content = vim.fn.system("git show HEAD:./" .. vim.fn.expand("%:t") .. " 2> /dev/null")

    local diff_output = vim.diff(git_content, buf_content .. '\n', {})

    local diff_result = parse_diff_output(diff_output)

    set_diff_sign(diff_result)
end

api.nvim_create_autocmd({ "TextChanged", "BufWinEnter" }, {
    callback = diff_buf
})

return M
