local api = vim.api

local hl_tbl = {
    Normal       =  { bg = "#222222", fg = "#cccccc" },
    NonText      =  { fg = "#303030" },
    SignColumn   =  { bg = "#202020" },
    LineNr       =  { fg = "#555555" },
    CursorLine   =  { bg = "#262626" },
    CursorLineNr =  { fg = "#aee800" },
    Visual       =  { bg = "#303030" },
    Search       =  { fg = "#ccff36", bold = true },
    IncSearch    =  { fg = "#ccff36" },
    VertSplit    =  { fg = "#303030" },
    Pmenu        =  { bg = "#303030" },
    PmenuSel     =  { bg = "#424242" },
    PmenuSbar    =  { bg = "#383838" },

    -- statusline
    StatusLineFT      = { bg = "#fe9b30", fg = "#101010" },
    StatusLineFTSep   = { bg = "#222222", fg = "#fe9b30" },
    StatusLineGitSepL = { bg = "#222222", fg = "#303030" },
    StatusLineGit     = { bg = "#303030", fg = "#888888" },
    StatusLineGitSepR = { bg = "#222222", fg = "#303030" },

    StatusLinePathSepL = { bg = "#202020", fg = "#262626" },
    StatusLinePATH     = { bg = "#262626", fg = "#404040" },
    StatusLineMod      = { bg = "#262626", fg = "#AFC460" },
    StatusLinePathSepR = { bg = "#202020", fg = "#262626" },

    StatusLineRow     = { bg = "#9d7cd8", fg = "#000000" },
    StatusLineRowSep  = { fg = "#9d7cd8", bg = "#222222" },

    StatusLineCharSepL  = { fg = "#282828", bg = "#222222" },
    StatusLineChar      = { fg = "#9d7cd8", bg = "#282828" },
    StatusLineCharSepR  = { fg = "#282828", bg = "#222222" },

    StatusLineFPOS1  = { fg = "#9d7cd8", bg = "#222222" },
    StatusLineFPOS2  = { fg = "#404040", bg = "#222222" },

    -- tabline
    TabLine           = { fg = "#ffffff", bg = "#060606" },
    TabLinePrefix     = { fg = "#e63663", bg = "#060606" },
    TabLineSuffix     = { fg = "#e63663", bg = "#060606" },
    TabLineTime       = { fg = "#383838", bg = "#060606" },
    TabLineNewtab     = { fg = "#666666", bg = "#060606" },

    InactiveTabSepL   = { bg = "#060606", fg = "#181818" },
    InactiveTabSepR   = { bg = "#060606", fg = "#181818" },
    InactiveTabFtIcon = { fg = "#555555", bg = "#181818" },
    InactiveTabClose  = { fg = "#555555", bg = "#181818" },
    InactiveTabName   = { fg = "#555555", bg = "#181818" },
    InactiveTabMod    = { fg = "#555555", bg = "#181818" },

    ActiveTabSepL     = { bg = "#060606", fg = "#222222" },
    ActiveTabSepR     = { bg = "#060606", fg = "#222222" },
    ActiveTabName     = { fg = "#999999", bg = "#222222" },
    ActiveTabFtIcon   = { fg = "#999999", bg = "#222222" },
    ActiveTabClose    = { fg = "#999999", bg = "#222222" },
    ActiveTabMod      = { fg = "#AFC460", bg = "#222222" },

    CmdLine         = { fg = "#FF9164", bg = "#282828" },
    CmdLineBorder   = { fg = "#9C8FDC" },
}

for key, value in pairs(hl_tbl) do
    api.nvim_set_hl(0, key, value)
end

local ts_tbl = {
    ["@variable"]           = { fg = "#868686" },
    ["@string"]             = { fg = "#585858" },
    ["@keyword"]            = { fg = "#868686" },
    ["@function"]           = { fg = "#9C8FDC" },
    ["@parameter"]          = { fg = "#585858" },
    ["@number"]             = { fg = "#787878" },
    ["@constant"]           = { fg = "#FF43BA" },
    ["@boolean"]            = { fg = "#FF43BA" },
    ["@conditional"]        = { fg = "#9C8FDC" },
    ["@repeat"]             = { fg = "#868686" },
    ["@operator"]           = { fg = "#686868" },
    ["@punctuation"]        = { fg = "#585858" },
    ["@constructor"]        = { fg = "#AFC460" },
    ["@field"]              = { fg = "#585858" },
    ["@method"]             = { fg = "#9C8FDC" },
    ["@comment"]            = { fg = "#484848" },
    ["@type"]               = { fg = "#686868" },
    ["@property"]           = { fg = "#9D7CD8" },
    ["@include"]            = { fg = "#C3E88D" },
    ["@text.todo"]          = { fg = "#C3E88D" },

    ["@constant.builtin"]   = { fg = "#C53B82" },
    ["@function.builtin"]   = { fg = "#A7C080" },
    ["@type.definition"]    = { fg = "#9C8FDC" },
    ["@string.escape"]      = { fg = "#484848" },
    ["@keyword.function"]   = { fg = "#999999" },
    ["@keyword.operator"]   = { fg = "#9C8FDC" },
    ["@keyword.return"]     = { fg = "#9C8FDC", bold = true },
}

for key, value in pairs(ts_tbl) do
    api.nvim_set_hl(0, key, value)
end
