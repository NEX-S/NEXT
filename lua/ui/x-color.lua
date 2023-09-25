local api = vim.api

local hl_tbl = {
    Normal       =        { bg = "#222222", fg = "#cccccc" },
    NonText      =        { fg = "#303030" },
    SignColumn   =        { bg = "#202020" },
    LineNr       =        { fg = "#555555" },
    CursorLine   =        { bg = "#262626" },
    -- CursorLineNr =        { fg = "#8cb811" },
    CursorLineNr =        { fg = "#aee800" },
    Visual       =        { bg = "#303030" },
    Search       =        { fg = "#ccff36", bold = true },
    IncSearch    =        { fg = "#ccff36" },
    VertSplit    =        { fg = "#303030" },
    Pmenu        =        { bg = "#303030" },
    PmenuSel     =        { bg = "#424242" },
    PmenuSbar    =        { bg = "#383838" },

    Folded       =        { fg = "#404040", bg = "#222222" },
    FoldColumn   =        { fg = "#484848" },

    MatchParen   =        { fg = "#aee800" },

    GitAdd       =        { fg = "#AFC460" },
    GitMod       =        { fg = "#fe9b30" },
    GitDel       =        { fg = "#C53B82" },

    StatusLineFT        = { bg = "#9d7cd8", fg = "#101010" },
    StatusLineFTSep     = { bg = "#222222", fg = "#9D7CD8" },
    StatusLineGitSepL   = { bg = "#222222", fg = "#292929" },
    StatusLineGit       = { bg = "#292929", fg = "#9D7CD8" },
    StatusLineGitAdd    = { bg = "#303030", fg = "#AFC460" },
    StatusLineGitRemove = { bg = "#303030", fg = "#C53B82" },
    StatusLineGitChange = { bg = "#303030", fg = "#fe9b30" },
    StatusLineGitSepR   = { bg = "#222222", fg = "#292929" },
    StatusLinePathSepL  = { bg = "#202020", fg = "#202020" },
    StatusLinePATH      = { bg = "#202020", fg = "#383838" },
    StatusLineMod       = { bg = "#202020", fg = "#AFC460" },
    StatusLinePathSepR  = { bg = "#202020", fg = "#202020" },
    StatusLineRow       = { bg = "#9d7cd8", fg = "#000000" },
    StatusLineRowSep    = { fg = "#9d7cd8", bg = "#222222" },
    StatusLineCharSepL  = { fg = "#292929", bg = "#222222" },
    StatusLineChar      = { fg = "#9d7cd8", bg = "#292929" },
    StatusLineCharSepR  = { fg = "#292929", bg = "#222222" },
    StatusLineFPOS1     = { fg = "#9d7cd8", bg = "#222222" },
    StatusLineFPOS2     = { fg = "#404040", bg = "#222222" },

    TabLine           =   { fg = "#ffffff", bg = "#060606" },
    -- TabLinePrefix     =   { fg = "#e63663", bg = "#060606" },
    TabLinePrefix     =   { fg = "#9C8FDC", bg = "#060606" },
    -- TabLineSuffix     =   { fg = "#e63663", bg = "#060606" },
    TabLineSuffix     =   { fg = "#9C8FDC", bg = "#060606" },
    TabLineTime       =   { fg = "#383838", bg = "#060606" },
    TabLineNewtab     =   { fg = "#666666", bg = "#060606" },
    InactiveTabSepL   =   { bg = "#060606", fg = "#181818" },
    InactiveTabSepR   =   { bg = "#060606", fg = "#181818" },
    InactiveTabFtIcon =   { fg = "#424242", bg = "#181818" },
    InactiveTabClose  =   { fg = "#505050", bg = "#181818" },
    InactiveTabName   =   { fg = "#424242", bg = "#181818" },
    InactiveTabMod    =   { fg = "#424242", bg = "#181818" },
    ActiveTabSepL     =   { bg = "#060606", fg = "#222222" },
    ActiveTabSepR     =   { bg = "#060606", fg = "#222222" },
    ActiveTabName     =   { fg = "#666666", bg = "#222222" },
    ActiveTabFtIcon   =   { fg = "#9D7CD8", bg = "#222222" },
    -- ActiveTabClose    =   { fg = "#585858", bg = "#222222" },
    ActiveTabClose    =   { fg = "#9C8FDC", bg = "#222222" },
    ActiveTabMod      =   { fg = "#AFC460", bg = "#222222" },

    CmdLine           =   { fg = "#FF9164", bg = "#282828" },
    CmdLineBorder     =   { fg = "#9C8FDC" },
    FloatTerm         =   { fg = "#9C8FDC" },
    FloatTitle        =   { fg = "#464646" },

    DiagnosticError       = { fg = "#FF43BA" },
    DiagnosticWarn        = { fg = "#555555" },
    DiagnosticInfo        = { fg = "#444444" },
    DiagnosticHint        = { fg = "#383838" },
    DiagnosticLineNrError = { fg = "#FF43BA" },
    DiagnosticLineNrWarn  = { fg = "#FFA500" },
    DiagnosticLineNrInfo  = { fg = "#EEEEEE" },
    DiagnosticLineNrHint  = { fg = "#aee800" },

    -- lsp will affect this, dont know why
    Identifier  = {},
    Comment  = {},
    -- LspInlayHint = { fg = "#444444", bg = "#262626" },
    LspInlayHint = { fg = "#383838" },

    -- ["@lsp.type.class"]         = { fg = "#ffffff" },
    -- ["@lsp.type.decorator"]     = { fg = "#ffffff" },
    -- ["@lsp.type.enum"]          = { fg = "#ffffff" },
    -- ["@lsp.type.enumMember"]    = { fg = "#ffffff" },
    -- ["@lsp.type.function"]      = { fg = "#ffffff" },
    -- ["@lsp.type.interface"]     = { fg = "#ffffff" },
    -- ["@lsp.type.macro"]         = { fg = "#ffffff" },
    -- ["@lsp.type.method"]        = { fg = "#ffffff" },
    -- ["@lsp.type.namespace"]     = { fg = "#ffffff" },
    -- ["@lsp.type.parameter"]     = { fg = "#ffffff" },
    -- ["@lsp.type.property"]      = { fg = "#ffffff" },
    -- ["@lsp.type.struct"]        = { fg = "#ffffff" },
    -- ["@lsp.type.type"]          = { fg = "#ffffff" },
    -- ["@lsp.type.typeParameter"] = { fg = "#ffffff" },
    -- ["@lsp.type.variable"]      = { fg = "#ffffff" },

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
    ["@constructor"]        = { fg = "#9C8FDC" },
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
