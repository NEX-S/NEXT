local api = vim.api

vim.o.rtp = "/usr/local/share/nvim/runtime/"
api.nvim_command("syntax off")

vim.o.ft = "c"

-- OPTIONS
vim.o.number = true
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.splitright = true
vim.o.undofile = true
vim.o.splitbelow = true
vim.o.expandtab = true
vim.o.autochdir = true
vim.o.virtualedit = "all"
vim.o.scrolloff = 6
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.cindent = true
vim.o.cmdheight = 0
vim.o.history = 1000
vim.o.sidescrolloff = 8
vim.o.statuscolumn = " %=%{ v:virtnum == v:false ? printf('%X', v:lnum) : '↳' }  "
vim.o.signcolumn = "yes:1"
vim.o.formatoptions = "rj"
vim.o.list = true
vim.o.listchars = "eol:⸥,space:·,trail:-,tab:--,nbsp:n,extends:e,precedes:+"

vim.o.foldenable = true
vim.o.foldmethod = "indent"
vim.o.fillchars = "eob:,fold: ,foldsep:╎,foldopen:~,foldclose:~"
-- vim.o.foldtext = "getline(v:foldstart)"
vim.o.foldtext = "v:lua.FOLD_TEXT()"
_G.FOLD_TEXT = function ()
    local f_row = vim.v.foldstart
    local f_str = api.nvim_buf_get_lines(0, f_row - 1, f_row, false)[1]:gsub('\t', string.rep(' ', vim.o.tabstop))
    local indent = f_str:find("%S") - 1
    return string.rep(' ', indent - 2) .. '+ ' .. f_str:sub(indent + 1) .. " ..."
end


-- KEYMAPS
api.nvim_set_keymap("n", "d", "x", { noremap = true })
api.nvim_set_keymap("n", "m", "%", { noremap = true })
api.nvim_set_keymap("n", " ", "za", { noremap = true })
api.nvim_set_keymap("n", "z", "m`", { noremap = true })
api.nvim_set_keymap("n", "gd", "<C-]>", { noremap = true })
api.nvim_set_keymap("n", "gs", "gg", { noremap = true })
api.nvim_set_keymap("n", "ge", "G", { noremap = true })
api.nvim_set_keymap("x", "gs", "gg", { noremap = true })
api.nvim_set_keymap("x", "ge", "G", { noremap = true })
api.nvim_set_keymap("n", ">", ">>", { noremap = true })
api.nvim_set_keymap("n", "<", "<<", { noremap = true })
api.nvim_set_keymap("x", ">", ">>", { noremap = true })
api.nvim_set_keymap("x", "<", "<<", { noremap = true })
api.nvim_set_keymap("n", "gf", "<CMD>tabnew <cfile><CR>", { noremap = true })
api.nvim_set_keymap("n", "U", "<C-r>", { noremap = true })
api.nvim_set_keymap("n", "<C-d>", "dd", { noremap = true })
api.nvim_set_keymap("n", "<C-w>", "<CMD>write ++p<CR>", { noremap = true })
api.nvim_set_keymap("n", "<C-q>", "<CMD>quit!<CR>", { noremap = true })
api.nvim_set_keymap("n", "<UP>", "<C-o>", { noremap = true })
api.nvim_set_keymap("n", "<DOWN>", "<C-i>", { noremap = true })
api.nvim_set_keymap("n", "<LEFT>", "gt", { noremap = true })
api.nvim_set_keymap("n", "<RIGHT>", "gT", { noremap = true })
api.nvim_set_keymap("n", "<TAB>", "<C-w><C-w>", { noremap = true })
api.nvim_set_keymap("n", "<C-f>", "/", { noremap = true })
api.nvim_set_keymap("n", "`", "<CMD>tabnew term://bash | startinsert!<CR>", { noremap = true })
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

api.nvim_set_keymap("n", '"', 'vi"', { noremap = true })
api.nvim_set_keymap("n", "'", "vi'", { noremap = true })
api.nvim_set_keymap("n", '(', 'vi(', { noremap = true })
api.nvim_set_keymap("n", '[', 'vi[', { noremap = true })
api.nvim_set_keymap("n", '{', 'vi{', { noremap = true })

-- HIGHLIGHT
api.nvim_set_hl(0, "LineNr", { fg = "#424242" })
api.nvim_set_hl(0, "Normal", { fg = "#646464", bg = "#202020" })
api.nvim_set_hl(0, "NonText", { fg = "#282828" })
api.nvim_set_hl(0, "Visual", { bg = "#282828" })
api.nvim_set_hl(0, "CursorLine", { bg = "#222222" })
api.nvim_set_hl(0, "CursorLineNr", { bg = "#222222" })
api.nvim_set_hl(0, "Folded", { fg = "#353535" })

-- AUTOCMD
api.nvim_create_autocmd("BufWinLeave", { command = "mkview" })
api.nvim_create_autocmd({ "UIEnter", "BufWinEnter", }, { command = "silent!loadview" })

-- api.nvim_create_autocmd("VimEnter",    { command = "echomsg 'VimEnter'"})
-- api.nvim_create_autocmd("UIEnter",     { command = "echomsg 'UIEnter'"})
-- api.nvim_create_autocmd("BufRead",     { command = "echomsg 'BufRead'"})
-- api.nvim_create_autocmd("BufReadPost", { command = "echomsg 'BufReadPost'"})
-- api.nvim_create_autocmd("BufWinEnter", { command = "echomsg 'BufWinEnter'"})
-- api.nvim_create_autocmd("WinEnter",    { command = "echomsg 'WinEnter'"})

-- DAP --
---------------------------------------------------------------------------------------------------
vim.opt.rtp:append("~/.local/share/nvim/lazy/nvim-treesitter/")
vim.opt.rtp:append("~/.local/share/nvim/lazy/nvim-dap/")
vim.opt.rtp:append("~/.local/share/nvim/lazy/nvim-dap-virtual-text/")

local dap = require "dap"

vim.fn.sign_define('DapBreakpoint', {text='X', texthl='', linehl='', numhl=''})

-- dap.defaults.fallback.external_terminal = {
--     command = '/usr/bin/gnome-terminal';
--     args = {
--         "--"
--     };
-- }

dap.defaults.fallback.terminal_win_cmd = "50 vsplit new | set statuscolumn="

dap.defaults.fallback.force_external_terminal = true

dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        command = 'codelldb',
        args = {
            "--port",
            "${port}"
        },
    }
}

dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" }
}

dap.configurations.c = {
    -- {
    --     type = "gdb",
    --     request = "launch",
    --     program = function()
    --         -- return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --         return "/home/nex/GitHub/php-8.2.12/sapi/cli/php"
    --     end,
    --     cwd = "${workspaceFolder}",
    -- },
    {
        type = "codelldb",
        request = "launch",
        program = function()
            -- return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            return "/home/nex/GitHub/php-8.2.12/sapi/cli/php"
        end,
        -- cwd = '${workspaceFolder}',
        args = {
            "/var/www/nginx/include.php",
        },
        stopOnEntry = false,
    },
}

api.nvim_set_keymap("n", ",,", '', { callback = dap.toggle_breakpoint })
api.nvim_set_keymap("n", "<CR>", '', { callback = dap.continue })

dap.listeners.after.event_initialized['dap-keys'] = function ()
    api.nvim_set_keymap("n", "c", '', { callback = dap.continue })
    api.nvim_set_keymap("n", "i", '', { callback = dap.step_into })
    api.nvim_set_keymap("n", "o", '', { callback = dap.step_out })
    api.nvim_set_keymap("n", "j", '', { callback = dap.step_over })
    api.nvim_set_keymap("n", "k", '', { callback = dap.step_back })
    api.nvim_set_keymap("n", "r", '', { callback = dap.restart })
    api.nvim_set_keymap("n", "s", '', { callback = dap.terminate })
    api.nvim_set_keymap("n", "p", '', { callback = function() dap.ui.widgets.preview() end })
    api.nvim_set_keymap("n", "h", '', { callback = function() dap.ui.widgets.hover() end })
end
local reset_keys = function ()
    api.nvim_set_keymap("n", "c", "s", { noremap = true })
    api.nvim_set_keymap("n", "i", 'i', { noremap = true })
    api.nvim_set_keymap("n", "o", 'o', { noremap = true })
    api.nvim_set_keymap("n", "j", 'j', { noremap = true })
    api.nvim_set_keymap("n", "k", 'k', { noremap = true })
    api.nvim_set_keymap("n", "r", 'r', { noremap = true })
    api.nvim_set_keymap("n", "s", 'viw', { noremap = true })
    api.nvim_set_keymap("n", "p", 'p', { noremap = true })
    api.nvim_set_keymap("n", "h", 'h', { noremap = true })
end
dap.listeners.after.event_terminated['dap-keys'] = reset_keys
dap.listeners.after.disconnected['dap-keys'] = reset_keys

require "nvim-dap-virtual-text".setup {
    enabled = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = true,
    show_stop_reason = true,
    commented = false,
    only_first_definition = false,
    all_references = false,
    clear_on_continue = false,
    display_callback = function (variable, buf, stackframe, node, options)
        if options.virt_text_pos == 'inline' then
            return ' : ' .. variable.value
        else
            return "\t" .. variable.name .. ' : ' .. variable.value
        end
    end,
    virt_text_pos = 'eol', -- "eol"
    all_frames = true,
    virt_lines = false,
}
