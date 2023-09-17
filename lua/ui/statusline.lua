local api = vim.api

-- test line 1
-- test line 2
-- test line 3
-- test line 4
-- test line 5
-- test line 6
-- test line 7

local function git_diff_stats()

    local bufname = vim.api.nvim_buf_get_name(0)
    local abs_bufname = vim.fn.fnamemodify(bufname, ':p')  -- 获取绝对路径

    local diff_output = vim.fn.systemlist('git diff --numstat ' .. abs_bufname)

    -- 获取Git仓库的顶级目录
    local git_toplevel = vim.fn.system('git rev-parse --show-toplevel'):gsub('\n', '')

    local added, deleted, modified = 0, 0, 0

    for _, line in ipairs(diff_output) do
        local a, d, f = line:match('(%d+)[\t%s]+(%d+)[\t%s]+(.+)')
        local abs_f = vim.fn.fnamemodify(git_toplevel .. '/' .. f, ':p')
        if abs_f == abs_bufname then
            added = added + tonumber(a)
            deleted = deleted + tonumber(d)
            modified = added + deleted
        end
    end

    return string.format("+%d -%d ~%d", added, deleted, modified)
end

print(git_diff_stats())

local L_FT   = "%#StatusLineFT# %Y %#StatusLineFTSep#"
local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit# GIT_STATUS %#StatusLineGitSepR#"
-- local L_PATH = "%#StatusLinePATH# %F %{% &modified ? '%#StatusLineMod#' : '' %}"
local L_PATH  = "%#StatusLinePathSepL#%#StatusLinePATH# %F %{% &modified ? '%#StatusLineMod# ' : '' %}%#StatusLinePathSepR#"

local R_LINE = "%#StatusLineRowSep#%#StatusLineRow# %l / %L "
local R_CHAR = "%#StatusLineCharSepL#%#StatusLineChar# %c   %B %#StatusLineCharSepR#"
local R_FPOS = "%#StatusLineFPOS1#  %#StatusLineFPOS2#%p%% "

api.nvim_set_option_value("laststatus", 3, {})
api.nvim_set_option_value("statusline", L_FT .. L_GIT .. L_PATH .. "%=" .. R_FPOS .. R_CHAR .. R_LINE, {})
