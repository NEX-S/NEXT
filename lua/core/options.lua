local api = vim.api

local options = {
    smartcase      = true,
    ignorecase     = true,
    wildignorecase = true,
    hidden         = true,
    smarttab       = true,
    expandtab      = true,
    smartindent    = true,
    writeany       = true,
    autochdir      = true,
    confirm        = true,
    autoread       = true,
    backup         = true,
    undofile       = true,
    magic          = false,
    startofline    = false,
    wrapscan       = false,
    swapfile       = false,
    writebackup    = false,
    -- warn        = false,
    tabstop        = 4,
    regexpengine    = 2,
    softtabstop    = 4,
    shiftwidth     = 4,
    history        = 100,
    mouse          = 'a',
    formatoptions  = "rj",
    backupdir      = "/tmp",
    shell          = "/bin/bash",
}

for key, value in pairs(options) do
    api.nvim_set_option_value(key, value, {})
end
