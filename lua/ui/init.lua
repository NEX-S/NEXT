local api = vim.api

local ui_options = {
    number         = true,
    cursorline     = true,
    title          = true,
    hlsearch       = true,
    incsearch      = true,
    list           = true,
    lazyredraw     = true,
    splitbelow     = true,
    splitright     = true,
    termguicolors  = true,
    wildmenu       = true,
    breakindent    = true,
    wrap           = false,
    modeline       = false,
    showmode       = false,
    ruler          = false,
    showcmd        = false,

    cmdheight     = 0,
    numberwidth  = 1,
    pumwidth      = 5,
    scrolloff     = 6,
    sidescrolloff = 10,
    -- updatetime    = 30,
    updatetime    = 50,
    pumheight     = 18,
    pumblend      = 25,
    winwidth      = 30,
    winblend      = 25,
    synmaxcol     = 140,
    redrawtime    = 100,

    mousemodel = "extend",
    virtualedit   = "all",
    viewoptions = "cursor,folds",
    splitkeep    = "screen", -- topline?
    shortmess    = "filmnrwxaoOstTWAIcCqFS",
    titlestring  = "[   UNEXPECTED NVIM   ]",
    signcolumn   = "yes:1",
    -- statuscolumn = "%s%=%#LineNr#%{ v:virtnum == v:false ? printf('%X', v:lnum) : '↳' } %*%{% foldlevel(v:lnum) ? '%C' : '' %} ",
    statuscolumn = "%s%=%#LineNr#%{ v:virtnum == v:false ? printf('%X', v:lnum) : '↳' }%*  ",
    -- fillchars = "eob:,fold: ,foldsep:,foldopen:,foldclose:",
    -- fillchars = "eob:,fold: ,foldsep:,foldopen:,foldclose:",
    fillchars = "eob:",
    listchars = "eol:⸥,space:·,trail:-,tab:--,nbsp:n,extends:e,precedes:+",
}

for key, value in pairs(ui_options) do
    api.nvim_set_option_value(key, value, {})
end

require "ui.x-color"
require "ui.fold"
require "ui.tabline"
require "ui.statusline"
require "ui.indentline"
-- require "ui.win-manager"
require "ui.cmdline"
require "ui.git"
