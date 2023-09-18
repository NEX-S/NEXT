local api = vim.api

-- GIT_STATUS
--------------------------------------------------------------
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

-- FT_ICON
------------------------------------------
-- local ft_icon = {
--     lua  = "",
--     vim  = "",
--     html = "",
--     c    = "",
--     php  = "▼",
--     markdown = " ",
-- }
-- 
-- _G.STATUSLINE_FT_ICON = function ()
--     return ft_icon[vim.bo.ft] or ''
-- end

local cached_cwd = ""
local cached_git_branch = "UNKNOWN"
local function get_git_branch ()
    local dir = vim.fn.fnamemodify(api.nvim_buf_get_name(0), ":h")

    local is_inside_git_repo = vim.fn.system("git -C " .. vim.fn.escape(dir, ' ') .. " rev-parse --is-inside-work-tree"):gsub("\n", "")
    
    if is_inside_git_repo ~= "true" then
        cached_git_branch = "UNKNOWN"
    else
        cached_git_branch = vim.fn.system("git -C " .. vim.fn.escape(dir, ' ') .. " rev-parse --abbrev-ref HEAD"):gsub("\n", "")
    end

    return cached_git_branch
end

_G.STATUSLINE_GIT = function ()
    local current_cwd = vim.fn.getcwd()

    if current_cwd == cached_cwd then
        return cached_git_branch
    end

    cached_cwd = current_cwd

    return get_git_branch()
end


local L_FT   = "%#StatusLineFT# %Y %#StatusLineFTSep#"
local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit#  %{% v:lua.STATUSLINE_GIT() %} %#StatusLineGitSepR#"
-- local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit# GIT %#StatusLineGitSepR#"
local L_PATH  = "%#StatusLinePathSepL#%#StatusLinePATH#%F %{% &modified ? '%#StatusLineMod# ' : '' %}%#StatusLinePathSepR#"

local R_LINE = "%#StatusLineRowSep#%#StatusLineRow# %l / %L "
local R_CHAR = "%#StatusLineCharSepL#%#StatusLineChar# %c   %B %#StatusLineCharSepR#"
local R_FPOS = "%#StatusLineFPOS1#  %#StatusLineFPOS2#%p%% "

api.nvim_set_option_value("laststatus", 3, {})
api.nvim_set_option_value("statusline", L_FT .. L_GIT .. L_PATH .. "%=" .. R_FPOS .. R_CHAR .. R_LINE, {})
