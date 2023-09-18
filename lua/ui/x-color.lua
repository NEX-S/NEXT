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
    StatusLineFT        = { bg = "#fe9b30", fg = "#101010" },
    StatusLineFTSep     = { bg = "#222222", fg = "#fe9b30" },

    StatusLineGitSepL   = { bg = "#222222", fg = "#303030" },
    StatusLineGit       = { bg = "#303030", fg = "#9D7CD8" },
    StatusLineGitAdd    = { bg = "#303030", fg = "#AFC460" },
    StatusLineGitRemove = { bg = "#303030", fg = "#C53B82" },
    StatusLineGitChange = { bg = "#303030", fg = "#fe9b30" },
    StatusLineGitSepR   = { bg = "#222222", fg = "#303030" },

    StatusLinePathSepL = { bg = "#202020", fg = "#202020" },
    StatusLinePATH     = { bg = "#202020", fg = "#383838" },
    StatusLineMod      = { bg = "#202020", fg = "#AFC460" },
    StatusLinePathSepR = { bg = "#202020", fg = "#202020" },

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
    ActiveTabName     = { fg = "#666666", bg = "#222222" },
    ActiveTabFtIcon   = { fg = "#9D7CD8", bg = "#222222" },
    ActiveTabClose    = { fg = "#585858", bg = "#222222" },
    ActiveTabMod      = { fg = "#AFC460", bg = "#222222" },

    CmdLine         = { fg = "#FF9164", bg = "#282828" },
    CmdLineBorder   = { fg = "#9C8FDC" },
}

for key, value in pairs(hl_tbl) do
    api.nvim_set_hl(0, key, value)
end

-- @text.literal      Comment
-- @text.reference    Identifier
-- @text.title        Title
-- @text.uri          Underlined
-- @text.underline    Underlined
-- @text.todo         Todo
-- 
-- @comment           Comment
-- @punctuation       Delimiter
-- 
-- @constant          Constant
-- @constant.builtin  Special
-- @constant.macro    Define
-- @define            Define
-- @macro             Macro
-- @string            String
-- @string.escape     SpecialChar
-- @string.special    SpecialChar
-- @character         Character
-- @character.special SpecialChar
-- @number            Number
-- @boolean           Boolean
-- @float             Float
-- 
-- @function          Function
-- @function.builtin  Special
-- @function.macro    Macro
-- @parameter         Identifier
-- @method            Function
-- @field             Identifier
-- @property          Identifier
-- @constructor       Special
-- 
-- @conditional       Conditional
-- @repeat            Repeat
-- @label             Label
-- @operator          Operator
-- @keyword           Keyword
-- @exception         Exception
-- 
-- @variable          Identifier
-- @type              Type
-- @type.definition   Typedef
-- @storageclass      StorageClass
-- @structure         Structure
-- @namespace         Identifier
-- @include           Include
-- @preproc           PreProc
-- @debug             Debug
-- @tag               Tag

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
    ["@property"]           = { fg = "#fe9b30" },
    ["@include"]            = { fg = "#C3E88D" },

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
