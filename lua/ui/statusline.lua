local api = vim.api

_G.STATUSLINE_GIT_STATUS = function ()
    local filename = api.nvim_buf_get_name(0)
    local lines = api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")

    local tmpfile = os.tmpname()
    local file = io.open(tmpfile, 'w')
    file:write(content)
    file:close()

    local diff = vim.fn.system("git diff -- " .. filename .. " " .. tmpfile)

    local added, changed, deleted = 0, 0, 0

    for line in diff:gmatch("[^\r\n]+") do
        local start_char = line:sub(1,1)
        if start_char == "+" and line:sub(1,3) ~= "+++" then
            added = added + 1
        elseif start_char == "-" and line:sub(1,3) ~= "---" then
            deleted = deleted + 1
        end
    end

    changed = math.min(added, deleted)
    added = added - changed
    deleted = deleted - changed

    return "%#StatusLineGitAdd# + " .. added .. "%#StatusLineGitChange# ~ " .. changed .. "%#StatusLineGitRemove# - " .. deleted 
end

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

local L_FT   = "%#StatusLineFT# %Y %#StatusLineFTSep#"
local L_GIT  = "%#StatusLineGitSepL#%#StatusLineGit#%{% v:lua.STATUSLINE_GIT_STATUS() %} %#StatusLineGitSepR#"
local L_PATH  = "%#StatusLinePathSepL#%#StatusLinePATH#%F %{% &modified ? '%#StatusLineMod# ' : '' %}%#StatusLinePathSepR#"

local R_LINE = "%#StatusLineRowSep#%#StatusLineRow# %l / %L "
local R_CHAR = "%#StatusLineCharSepL#%#StatusLineChar# %c   %B %#StatusLineCharSepR#"
local R_FPOS = "%#StatusLineFPOS1#  %#StatusLineFPOS2#%p%% "

api.nvim_set_option_value("laststatus", 3, {})
api.nvim_set_option_value("statusline", L_FT .. L_GIT .. L_PATH .. "%=" .. R_FPOS .. R_CHAR .. R_LINE, {})
