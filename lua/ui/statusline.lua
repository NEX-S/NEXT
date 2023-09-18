local api = vim.api

local git = require "ui.git-status"

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
local cached_git_branch = ""
_G.STATUSLINE_GIT = function ()
    local current_cwd = vim.fn.getcwd()

    if current_cwd == cached_cwd then
        return cached_git_branch
    end

    cached_cwd = current_cwd
    cached_git_branch = git.get_git_branch()

    return cached_git_branch
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
