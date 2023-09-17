
require "ft"
require "ui"

require "plugins"

vim.defer_fn(function ()
    require "core.options"
    require "core.keymaps"
    require "core.autocmd"

    require "modules"
end, 20)
