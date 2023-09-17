local api = vim.api
local uv  = vim.loop

local namespace_id = api.nvim_create_namespace("luacheck")

local function get_buffer_content ()
    local line_tbl = api.nvim_buf_get_lines(0, 0, -1, true)
    return table.concat(line_tbl, '\n')
end

local function get_luacheck_output (content, callback)
    local output = ""

    local handle = nil

    local stdin  = uv.new_pipe()
    local stdout = uv.new_pipe()

    handle = uv.spawn("luacheck", {
        args = { "-", "--formatter=plain", "--no-color", "--codes", "--ignore", "614", "611", "--globals", "vim" },
        stdio = { stdin, stdout, nil },
    },
        function ()
            stdout:read_stop()
            stdout:close()
            handle:close()

            vim.schedule(function ()
                callback(output)
            end)
        end
    )

    uv.write(stdin, content, function ()
        stdin:shutdown()
        stdin:close()
    end)

    uv.read_start(stdout, function (_, data)
        if data ~= nil and data ~= '' then
            output = output .. data
        end
    end)
end

local sign_tbl = {
    ["E0"] = { sign = "廓", sign_hl = "LuaCheckE0" },
    ["W1"] = { sign = " ", sign_hl = "LuaCheckW1" },
    ["W2"] = { sign = " ", sign_hl = "LuaCheckW2" },
    ["W3"] = { sign = " ", sign_hl = "LuaCheckW3" },
    ["W4"] = { sign = " ", sign_hl = "LuaCheckW4" },
    ["W5"] = { sign = " ", sign_hl = "LuaCheckW5" },
    ["W6"] = { sign = " ", sign_hl = "LuaCheckW6" },
}

for _, tbl in pairs(sign_tbl) do
    vim.fn.sign_define(tbl.sign_hl, { text = '', numhl = tbl.sign_hl })
end

local virt_tbl = {}
local function set_diagnostic_sign (luacheck_output)
    vim.fn.sign_unplace("LuaCheck")

    local qf_list = {}

    virt_tbl = {}

    local bufname = api.nvim_get_current_buf()
    for line in luacheck_output:gmatch("%C+") do
        local file, lnum, cnum, type, info = line:match("(%C+):(%d+):(%d+): %((%u%d)%d%d%) (%C+)")

        lnum = tonumber(lnum)
        cnum = tonumber(cnum)

        local sign_info = sign_tbl[type]

        vim.fn.sign_place(0, "LuaCheck", sign_info.sign_hl, bufname, { lnum = lnum })

        virt_tbl[lnum] = { " [ " .. info .. " ] ", sign_info.sign_hl }

        table.insert(qf_list, {
            bufnr = bufname,
            lnum  = lnum,
            col   = cnum,
            text  = info,
            type  = type,
        })
    end

    vim.fn.setqflist(qf_list)
end

local function get_cursor_diagnostic ()
    api.nvim_buf_del_extmark(0, namespace_id, 1)
    local line = api.nvim_win_get_cursor(0)[1]

    local virt_info = virt_tbl[line]

    if virt_info ~= nil then
        local wtop = api.nvim_call_function("getpos", { "w0" })[2]

        api.nvim_buf_set_extmark(0, namespace_id, wtop, 0, {
            id = 1,
            virt_text = { virt_info },
            virt_text_pos = "right_align",
        })
    end
end

local function run_luacheck ()
    local content = get_buffer_content()
    get_luacheck_output(content, set_diagnostic_sign)
end

local prev_ct = 0
api.nvim_create_autocmd(
    { "InsertLeave", "BufWritePost" }, {
        pattern = "*.lua",
        callback = function ()
            local ct = api.nvim_buf_get_changedtick(0)
            if ct ~= prev_ct then
                prev_ct = ct
                run_luacheck()
            end
        end
    }
)

api.nvim_create_autocmd(
    { "BufWinEnter", "TextChanged" }, {
        pattern = "*.lua",
        callback = run_luacheck
    }
)

api.nvim_create_autocmd("CursorHold", {
    pattern = "*.lua",
    callback = get_cursor_diagnostic
})
