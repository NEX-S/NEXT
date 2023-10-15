local api = vim.api

local base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64_encode (data)
    return (data:gsub('.', function (x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do
            r = r..(b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function (x)
            if #x < 6 then
                return ''
            end
            local c = 0
            for i = 1, 6 do
                c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
            end
            return base64_chars:sub(c + 1, c + 1)
        end)..({ '', '==', '=' })[#data % 3 + 1]
end

local function base64_decode (data)
    data = string.gsub(data, '[^' .. base64_chars .. '=]', '')
    return data:gsub('.', function(x)
        if x == '=' then
            return ''
        end
        local r, f = '', (base64_chars:find(x) - 1)
        for i = 6, 1, -1 do
            r = r..(f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function (x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
        end
        return string.char(c)
    end)
end

local function url_encode (str)
    str = string.gsub(str, "(.)", function (c)
        return string.format("%%%02X", string.byte(c))
    end)
    return str
end

local function url_decode (str)
    str = string.gsub(str, "%%(%x%x)", function (h)
        return string.char(tonumber(h, 16))
    end)
    return str
end

local function rot13_encode (str)
    return str:gsub(".", function(c)
        local b = c:byte()
        if b >= 65 and b <= 90 then
            return string.char(((b - 65 + 13) % 26) + 65)
        elseif b >= 97 and b <= 122 then
            return string.char(((b - 97 + 13) % 26) + 97)
        end
        return c
    end)
end

local function uni_encode (str)
    local result = {}
    for i = 1, #str do
        local c = str:byte(i)
        table.insert(result, string.format("\\u%04x", c))
    end
    return table.concat(result)
end

local function uni_decode (str)
    local result = {}
    for unicode in str:gmatch("\\u(%x%x%x%x)") do
        table.insert(result, string.char(tonumber(unicode, 16)))
    end
    return table.concat(result)
end

local function get_select_content ()
    local s_pos = vim.fn.getpos('v')
    local e_pos = vim.fn.getpos('.')

    if s_pos[2] > e_pos[2] then
        e_pos[2], s_pos[2] = s_pos[2], e_pos[2]
    end

    if s_pos[3] > e_pos[3] then
        e_pos[3], s_pos[3] = s_pos[3], e_pos[3]
    end

    local select_tbl = api.nvim_get_mode().mode == 'V' and
        api.nvim_buf_get_lines(0, s_pos[2] - 1, e_pos[2] - 1, false) or
        api.nvim_buf_get_text(0, s_pos[2] - 1, s_pos[3] - 1, e_pos[2] - 1, e_pos[3], {})

    return table.concat(select_tbl, '\n')
end

api.nvim_set_keymap('x', ',,', '', {
    callback = function ()
        local s_pos = vim.fn.getpos('v')
        local e_pos = vim.fn.getpos('.')

        if s_pos[2] > e_pos[2] then
            e_pos[2], s_pos[2] = s_pos[2], e_pos[2]
        end

        if s_pos[3] > e_pos[3] then
            e_pos[3], s_pos[3] = s_pos[3], e_pos[3]
        end

        local mode = api.nvim_get_mode().mode
        local select_tbl = mode == 'V' and
        api.nvim_buf_get_lines(0, s_pos[2] - 1, e_pos[2], false) or
        api.nvim_buf_get_text(0, s_pos[2] - 1, s_pos[3] - 1, e_pos[2] - 1, e_pos[3], {})

        local select_content = table.concat(select_tbl, '\n')

        local encode_content = url_encode(select_content)

        api.nvim_input('v')

        if mode == 'V' then
            api.nvim_buf_set_lines(0, s_pos[2] - 1, e_pos[2], false, { encode_content })
            vim.fn.setpos("'<", { 0, s_pos[2], 1, 0 })
            vim.fn.setpos("'>", { 0, s_pos[2], #encode_content, 0 })
        else
            -- TODO: '> pos is correct but gv dont respect it ???
            api.nvim_buf_set_text(0, s_pos[2] - 1, s_pos[3] - 1, e_pos[2] - 1, e_pos[3], { encode_content })
            vim.fn.setpos("'<", { 0, s_pos[2], s_pos[3], 0 })
            vim.fn.setpos("'>", { 0, s_pos[2], s_pos[3] + #encode_content, 0 })
        end

        api.nvim_input('gv')
    end
})
