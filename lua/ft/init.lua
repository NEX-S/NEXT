local api = vim.api

local extension_tbl = {
    ["lua"] = "lua",
    ["c"] = "c",
    ["py"] = "python",
    ["html"] = "html",
    ["s"] = "asm",
    ["asm"] = "asm",
    ["txt"] = "text",
    ["php"] = "php",
}

local function ft_detect ()
    local file_ext = vim.fn.expand("%:e")
    local filetype = extension_tbl[file_ext] or "text"

    vim.bo.ft = filetype

    vim.defer_fn(function ()
        pcall(api.nvim_command, "luafile ~/.config/nvim/lua/ft/" .. filetype .. "/init.lua")
    end, 100)
end

ft_detect()

api.nvim_create_autocmd("BufReadPost", {
    callback = ft_detect
})
