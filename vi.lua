local api = vim.api

api.nvim_command("syntax off")

-- OPTIONS
vim.o.rtp = ""
vim.o.number = true
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.expandtab = true
vim.o.autochdir = true
vim.o.virtualedit = "all"
vim.o.scrolloff = 6
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.cmdheight = 0
vim.o.sidescrolloff = 8
vim.o.statuscolumn = " %=%{ v:virtnum == v:false ? printf('%X', v:lnum) : '↳' }  "
vim.o.formatoptions = "rj"

-- KEYMAPS
api.nvim_set_keymap("n", "d", "x", { noremap = true })
api.nvim_set_keymap("n", "m", "%", { noremap = true })
api.nvim_set_keymap("n", "U", "<C-r>", { noremap = true })
api.nvim_set_keymap("n", "<C-d>", "dd", { noremap = true })
api.nvim_set_keymap("n", "<C-w>", "<CMD>write ++p<CR>", { noremap = true })
api.nvim_set_keymap("n", "<C-q>", "<CMD>quit!<CR>", { noremap = true })
api.nvim_set_keymap("n", "<UP>", "<C-o>", { noremap = true })
api.nvim_set_keymap("n", "<DOWN>", "<C-i>", { noremap = true })
api.nvim_set_keymap("n", "s", "viw", { noremap = true })
api.nvim_set_keymap("n", "c", "s", { noremap = true })
api.nvim_set_keymap("n", "x", "<C-v>", { noremap = true })
api.nvim_set_keymap("n", "J", "8gj", { noremap = true })
api.nvim_set_keymap("n", "K", "8gk", { noremap = true })
api.nvim_set_keymap("n", "H", "_", { noremap = true })
api.nvim_set_keymap("n", "L", "$", { noremap = true })
api.nvim_set_keymap("x", "J", "8gj", { noremap = true })
api.nvim_set_keymap("x", "K", "8gk", { noremap = true })
api.nvim_set_keymap("x", "H", "_", { noremap = true })
api.nvim_set_keymap("x", "L", "$", { noremap = true })

-- HIGHLIGHT
api.nvim_set_hl(0, "LineNr", { fg = "#484848" })
api.nvim_set_hl(0, "Normal", { fg = "#686868", bg = "#191919" })
api.nvim_set_hl(0, "CursorLine", { bg = "#202020" })
api.nvim_set_hl(0, "CursorLineNr", { bg = "#202020" })

