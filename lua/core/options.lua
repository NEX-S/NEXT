local api = vim.api

local options = {
	smartcase = true,
	ignorecase = true,
	wildignorecase = true,

	hidden = true,

	magic = false,

	smarttab = true,
	expandtab = true,

	smartindent = true,

	startofline = false,
	
	writeany = true,
	undofile = true,

	autochdir = true,
	wrapscan = false,

	confirm = true,

	backup = true,
	writebackup = false,

    backupdir = "/tmp",

	swapfile = false,

    -- false ?
    autoread = true,

    -- warn = false,
    
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,

    history = 100,

    shell = "/bin/sh",

    mouse = 'a',

    formatoptions  = "rj",
}

for key, value in pairs(options) do
	-- api.nvim_set_option_value(key, value, { scope = "global" })
	api.nvim_set_option_value(key, value, {})
end	
