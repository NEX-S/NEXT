local api = vim.api

local function git_diff_stats()
    local abs_bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p')

    local diff_output = vim.fn.systemlist('git diff --numstat ' .. abs_bufname)

    local added, deleted, modified = 0, 0, 0

    -- git_toplevel 是你的 Git 仓库的根目录路径
    local git_toplevel = vim.fn.system('git rev-parse --show-toplevel'):gsub('\n', '')

    for _, line in ipairs(diff_output) do
        local a, d, f = line:match('(%d+)[\t%s]+(%d+)[\t%s]+(.+)')
        local abs_f = vim.fn.fnamemodify(git_toplevel .. '/' .. f, ':p')
        if abs_f == abs_bufname then
            added = added + tonumber(a)
            deleted = deleted + tonumber(d)
        end
    end

    -- 使用math.min来计算修改的行数
    modified = math.min(added, deleted)
    added = added - modified
    deleted = deleted - modified

    return string.format("+%d -%d ~%d", added, deleted, modified)
end

print(git_diff_stats())

-- local function git_diff ()
--     local filename = api.nvim_buf_get_name(0)
--     local diff = vim.fn.system("git diff " .. filename)
--     local added, deleted = 0, 0
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
--     local changed = math.min(added, deleted)
-- 
--     return "+" .. (added-changed) .. " -" .. (deleted-changed) .. " ~" .. changed
-- end

local L_FT   = "%#StatusLineFT# %Y %#StatusLineFTSep#"
local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit# GIT_STATUS %#StatusLineGitSepR#"
-- local L_PATH = "%#StatusLinePATH# %F %{% &modified ? '%#StatusLineMod#' : '' %}"
local L_PATH  = "%#StatusLinePathSepL#%#StatusLinePATH# %F %{% &modified ? '%#StatusLineMod# ' : '' %}%#StatusLinePathSepR#"

local R_LINE = "%#StatusLineRowSep#%#StatusLineRow# %l / %L "
local R_CHAR = "%#StatusLineCharSepL#%#StatusLineChar# %c   %B %#StatusLineCharSepR#"
local R_FPOS = "%#StatusLineFPOS1#  %#StatusLineFPOS2#%p%% "

api.nvim_set_option_value("laststatus", 3, {})
api.nvim_set_option_value("statusline", L_FT .. L_GIT .. L_PATH .. "%=" .. R_FPOS .. R_CHAR .. R_LINE, {})
