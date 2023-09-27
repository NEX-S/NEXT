--     __  ___   _________  __ ____  ____________________________   --
--    / / / / | / / ____/ |/ // __ \/ ____/ ____/_  __/ ____/ __ \  --
--   / / / /  |/ / __/  |   // /_/ / __/ / /     / / / __/ / / / /  --
--  / /_/ / /|  / /___ /   |/ ____/ /___/ /___  / / / /___/ /_/ /   --
--  \____/_/ |_/_____//_/|_/_/   /_____/\____/ /_/ /_____/_____/    --
--                                                                  --

local api = vim.api

vim.loader.enable()

vim.o.undofile = false

require "ft"  -- ~/.config/nvim/lua/ft/init.lua
require "ui"  -- ~/.config/nvim/lua/ui/init.lua

require "plugins"       -- ~/.config/nvim/lua/plugins/init.lua
require "core.autocmd"  -- ~/.config/nvim/lua/core/autocmd.lua

api.nvim_create_autocmd("BufEnter", {
    once = true,
    callback = function ()
        require "core.options"  -- ~/.config/nvim/lua/core/options.lua
        require "core.keymaps"  -- ~/.config/nvim/lua/core/keymaps.lua
        require "modules"       -- ~/.config/nvim/lua/modules/init.lua
    end
})
