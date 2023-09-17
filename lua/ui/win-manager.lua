-- expirimental
local api = vim.api
local fn = vim.fn

local namespace_id = api.nvim_create_namespace("ResizeMode")

local function set_virtual_text()
    api.nvim_buf_set_extmark(0, namespace_id, fn.line("w0"), 0, {
        id = 1,
        virt_text_pos = "right_align",
        hl_mode = "combine",
        virt_text = {
            { "[ RESIZE MODE ] ", "ResizeMode" }
        }
    })
end

local reset_keymap = {
    ["h"] = "h",
    ["l"] = "l",
    ["j"] = "gj",
    ["k"] = "gk",
    ["H"] = "^",
    ["J"] = "8gj",
    ["K"] = "8gk",
    ["L"] = "$",
    ["o"] = "o",
    ["s"] = "s",
    ["v"] = "v",
    ["t"] = "t",
    ["<LEFT>"]  = "gT",
    ["<RIGHT>"] = "gt",
    ["<UP>"]    = "<C-o>",
    ["<DOWN>"]  = "<C-i>",
    ["<ESC>"] = ",",
}

local function determine_window_action(direction, count, action_less, action_more)
    local total_windows = fn.winnr('$')
    local current_window_position = fn.winnr(direction)

    local only_two_vert_splits = total_windows == 2 and fn.winnr('l') ~= fn.winnr('h')

    if only_two_vert_splits and (direction == 'j' or direction == 'k') then
        return ''
    end

    if total_windows ~= 1 and current_window_position == total_windows then
        return count .. action_less
    end
    return count .. action_more
end

local win_manager_key = {
    ["h"]       = function() return determine_window_action('h', '', '<C-w><', '<C-w>>') end,
    ["l"]       = function() return determine_window_action('l', '', '<C-w><', '<C-w>>') end,
    ["j"]       = function() return determine_window_action('j', '', '<C-w>-', '<C-w>+') end,
    ["k"]       = function() return determine_window_action('k', '', '<C-w>-', '<C-w>+') end,
    ["H"]       = function() return determine_window_action('h', '4', '<C-w><', '<C-w>>') end,
    ["L"]       = function() return determine_window_action('l', '4', '<C-w><', '<C-w>>') end,
    ["J"]       = function() return determine_window_action('j', '4', '<C-w>-', '<C-w>+') end,
    ["K"]       = function() return determine_window_action('k', '4', '<C-w>-', '<C-w>+') end,
    ["o"]       = function() return "<C-w>x" end,
    ["<LEFT>"]  = function() return "<C-w>H" end,
    ["<DOWN>"]  = function() return "<C-w>J" end,
    ["<UP>"]    = function() return "<C-w>K" end,
    ["<RIGHT>"] = function() return "<C-w>L" end,
    ["s"]       = function() return "<CMD>split<CR>" end,
    ["v"]       = function() return "<CMD>vsplit<CR>" end,

    ["<ESC>"] = function() 
        api.nvim_buf_del_extmark(0, namespace_id, 1)
        for key, value in pairs(reset_keymap) do
            api.nvim_set_keymap('n', key, value, { noremap = true })
        end
    end,
}

local function enter_win_manager_mode()
    set_virtual_text()
    for key, value in pairs(win_manager_key) do
        api.nvim_set_keymap('n', key, '', { callback = value, expr = true, replace_keycodes = true, noremap = true })
    end
end

api.nvim_set_keymap('n', '<C-r>', '', { callback = enter_win_manager_mode })
