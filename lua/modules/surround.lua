local api = vim.api

local function add_surround (left_char, rght_char)

    local mode = api.nvim_get_mode().mode

    local s_pos = vim.fn.getpos("v")
    local e_pos = vim.fn.getpos(".")

    if s_pos[2] ~= e_pos[2] then
        return
    end

    -- if left_char == ']' or left_char == '}' or left_char == ')' then
    --     left_char, rght_char = rght_char, left_char
    -- end

    if mode == 'v' then
        if e_pos[3] < s_pos[3] then
            s_pos, e_pos = e_pos, s_pos
        end
    elseif mode == 'V' then
        local line_str = api.nvim_get_current_line()
        s_pos[3] = line_str:find("%S")
        e_pos[3] = #line_str
    elseif mode == "\v16" then
        -- ... 
    end

    api.nvim_buf_set_text(0, s_pos[2] - 1, s_pos[3] - 1, s_pos[2] - 1, s_pos[3] - 1, { left_char })
    api.nvim_buf_set_text(0, e_pos[2] - 1, e_pos[3] + 1, e_pos[2] - 1, e_pos[3] + 1, { rght_char })
end

local surround_map = {
    ['"'] = '"',
    ["'"] = "'",
    ["`"] = "`",
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    -- [")"] = "(",
    -- ["]"] = "[",
    -- ["}"] = "{",
}

for key, value in pairs(surround_map) do
    api.nvim_set_keymap('x', 's'.. key, '', {
        callback = function ()
            add_surround(key, value)
        end
    })
end
