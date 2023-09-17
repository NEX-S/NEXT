local api = vim.api

local function git_diff_stats ()
    local bufname = api.nvim_buf_get_name(0)
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
        end
    end

    -- 计算修改的行数
    while added > 0 and deleted > 0 do
        modified = modified + 1
        added = added - 1
        deleted = deleted - 1
    end

    return string.format("+%d -%d ~%d", added, deleted, modified)
end

local function git_diff()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local diff = vim.fn.system("git diff " .. filename)
  local added, deleted = 0, 0

  for line in diff:gmatch("[^\r\n]+") do
    local start_char = line:sub(1,1)
    if start_char == "+" and line:sub(1,3) ~= "+++" then
      added = added + 1
    elseif start_char == "-" and line:sub(1,3) ~= "---" then
      deleted = deleted + 1
    end
  end

  local changed = math.min(added, deleted) -- assuming a change is counted as a line added and a line deleted
  return "+" .. (added-changed) .. " -" .. (deleted-changed) .. " ~" .. changed
end

print(git_diff())

local L_FT   = "%#StatusLineFT# %Y %#StatusLineFTSep#"
local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit# GIT_STATUS %#StatusLineGitSepR#"
-- local L_PATH = "%#StatusLinePATH# %F %{% &modified ? '%#StatusLineMod#' : '' %}"
local L_PATH  = "%#StatusLinePathSepL#%#StatusLinePATH# %F %{% &modified ? '%#StatusLineMod# ' : '' %}%#StatusLinePathSepR#"

local R_LINE = "%#StatusLineRowSep#%#StatusLineRow# %l / %L "
local R_CHAR = "%#StatusLineCharSepL#%#StatusLineChar# %c   %B %#StatusLineCharSepR#"
local R_FPOS = "%#StatusLineFPOS1#  %#StatusLineFPOS2#%p%% "

api.nvim_set_option_value("laststatus", 3, {})
api.nvim_set_option_value("statusline", L_FT .. L_GIT .. L_PATH .. "%=" .. R_FPOS .. R_CHAR .. R_LINE, {})
