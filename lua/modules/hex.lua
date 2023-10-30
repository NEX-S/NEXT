-- local api = vim.api
-- 
-- local hex_layout = {
--     offset = { bufnr = nil, winid = nil },
--     hexval = { bufnr = nil, winid = nil },
--     ascii = { bufnr = nil, winid = nil },
-- }
-- 
-- local function open_hex_editor ()
--     local content = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), '\n')
-- 
--     hex_layout.offset.bufnr = api.nvim_create_buf(false, true)
--     hex_layout.hexval.bufnr = api.nvim_create_buf(false, true)
--     hex_layout.ascii.bufnr = api.nvim_create_buf(false, true)
-- 
--     api.nvim_command("tabnew")
--     api.nvim_command("vsp")
--     api.nvim_command("vsp")
-- 
--     api.nvim_win_set_buf(0, hex_layout.ascii.bufnr)
-- 
--     api.nvim_command("wincmd H")
--     api.nvim_win_set_buf(0, hex_layout.hexval.bufnr)
-- 
--     api.nvim_command("wincmd H")
--     api.nvim_win_set_buf(0, hex_layout.offset.bufnr)
-- end
-- 
-- 
-- api.nvim_create_user_command("Hex", open_hex_editor, {})

local api = vim.api

local hex_layout = {
    offset = { bufnr = nil, winid = nil },
    hexval = { bufnr = nil, winid = nil },
    ascii = { bufnr = nil, winid = nil },
}

local function generate_hex_view(content)
    local offset_lines = {}
    local hex_lines = {}
    local ascii_lines = {}

    local content_len = #content
    local hex, ascii = {}, {}
    for i = 1, content_len do
        if i % 16 == 1 then
            table.insert(offset_lines, string.format("%08x", i-1))
        end

        local byte = string.byte(content, i)
        table.insert(hex, string.format("%02x", byte))
        
        if byte >= 32 and byte <= 126 then
            table.insert(ascii, string.char(byte))
        else
            table.insert(ascii, ".")
        end

        if i % 16 == 0 or i == content_len then
            table.insert(hex_lines, table.concat(hex, " "))
            table.insert(ascii_lines, table.concat(ascii))
            hex, ascii = {}, {}
        end
    end

    return offset_lines, hex_lines, ascii_lines
end

local function open_hex_editor()
    local content = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), '\n')

    hex_layout.offset.bufnr = api.nvim_create_buf(false, true)
    hex_layout.hexval.bufnr = api.nvim_create_buf(false, true)
    hex_layout.ascii.bufnr = api.nvim_create_buf(false, true)

    local offset_lines, hex_lines, ascii_lines = generate_hex_view(content)

    print(vim.inspect(offset_lines))
    print(vim.inspect(hex_lines))
    print(vim.inspect(ascii_lines))

    api.nvim_buf_set_option(hex_layout.offset.bufnr, 'buftype', 'nofile')
    api.nvim_buf_set_option(hex_layout.hexval.bufnr, 'buftype', 'nofile')
    api.nvim_buf_set_option(hex_layout.ascii.bufnr, 'buftype', 'nofile')

    api.nvim_buf_set_lines(hex_layout.offset.bufnr, 0, -1, false, offset_lines)
    api.nvim_buf_set_lines(hex_layout.hexval.bufnr, 0, -1, false, hex_lines)
    api.nvim_buf_set_lines(hex_layout.ascii.bufnr, 0, -1, false, ascii_lines)

    api.nvim_command("tabnew")
    api.nvim_command("vsp")
    api.nvim_command("vsp")

    api.nvim_win_set_buf(0, hex_layout.ascii.bufnr)
    api.nvim_command("wincmd H")
    api.nvim_win_set_buf(0, hex_layout.hexval.bufnr)
    api.nvim_command("wincmd H")
    api.nvim_win_set_buf(0, hex_layout.offset.bufnr)
end

api.nvim_create_user_command("Hex", open_hex_editor, {})

