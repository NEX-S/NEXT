local api = vim.api

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

_G.STATUSLINE_FILE_PATH = function ()
    local file_path = api.nvim_buf_get_name(0)
    return file_path:match("^/") and file_path or ""
end

local L_FT   = "%#StatusLineFT# %Y %#StatusLineFTSep#"
-- local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit#  %{% v:lua.STATUSLINE_GIT() %} %#StatusLineGitSepR#"
local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit#  %{ luaeval('_G.GIT_BRANCH') } %#StatusLineGitSepR#"
-- local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit# GIT %#StatusLineGitSepR#"
-- local L_PATH  = "%#StatusLinePathSepL#%#StatusLinePATH#%F %{% &modified ? '%#StatusLineMod# ' : '' %}%#StatusLinePathSepR#"
local L_PATH  = "%#StatusLinePathSepL#%#StatusLinePATH#%{ v:lua.STATUSLINE_FILE_PATH() } %{% &modified ? '%#StatusLineMod# ' : '' %}%#StatusLinePathSepR#"

local R_LINE = "%#StatusLineRowSep#%#StatusLineRow# %l / %L "
local R_CHAR = "%#StatusLineCharSepL#%#StatusLineChar# %c   %B %#StatusLineCharSepR#"
local R_FPOS = "%#StatusLineFPOS1#  %#StatusLineFPOS2#%p%% "

api.nvim_set_option_value("laststatus", 3, {})
api.nvim_set_option_value("statusline", L_FT .. L_GIT .. L_PATH .. "%=" .. R_FPOS .. R_CHAR .. R_LINE, {})
