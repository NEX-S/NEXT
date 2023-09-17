local api = vim.api
local uv  = vim.loop

local namespace_id = api.nvim_create_namespace("gcc_check")

local function get_buffer_content ()
    local line_tbl = api.nvim_buf_get_lines(0, 0, -1, true)
    return table.concat(line_tbl, '\n')
end

local function get_gcc_output (content, callback)
    local output = ""

    local handle = nil

    local stdin  = uv.new_pipe()
    local stderr = uv.new_pipe()

    handle = uv.spawn("gcc", {
        args = { "-fsyntax-only", "-Wall", "-Wextra", "-pedantic", "-Wconversion", "-x", "c", "-" },
        stdio = { stdin, nil, stderr },
    },
        function ()
            stderr:read_stop()
            stderr:close()
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

    uv.read_start(stderr, function (_, data)
        if data ~= nil and data ~= '' then
            output = output .. data
        end
    end)
end

local diagnostic_type_info = {
    ["error"]   = { prefix = " 廓", prefix_hl = "GccError" },
    ["warning"] = { prefix = "  ", prefix_hl = "GccWarn" },
    ["note"]    = { prefix = "  ", prefix_hl = "GccNote" },
}

for _, type_tbl in pairs(diagnostic_type_info) do
    vim.fn.sign_define(type_tbl.prefix_hl, { text = '', numhl = type_tbl.prefix_hl })
end

local line_diagnostic_tbl = {}
local function set_diagnostic (gcc_output)
    vim.fn.sign_unplace("GccCheck")

    local bufnr = api.nvim_get_current_buf()

    line_diagnostic_tbl = {}
    local qf_list = {}

    for line in gcc_output:gmatch("%C+:%d+:%d+:%C+") do
        local lnum, cnum, type, info = line:match("%C+:(%d+):(%d+): (%a+): (%C+)")

        lnum = tonumber(lnum)
        cnum = tonumber(cnum)

        local diagnostic_type_tbl = diagnostic_type_info[type]

        vim.fn.sign_place(0, "GccCheck", diagnostic_type_tbl.prefix_hl, bufnr, { lnum = lnum })

        line_diagnostic_tbl[lnum] = { "[ " .. info .. " ]  ", diagnostic_type_tbl.prefix_hl }

        table.insert(qf_list, {
            bufnr = bufnr,
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

    local linenr = api.nvim_win_get_cursor(0)[1]

    local virt_info = line_diagnostic_tbl[linenr]

    if virt_info ~= nil then
        local wtop = api.nvim_call_function("getpos", { "w0" })[2]

        api.nvim_buf_set_extmark(0, namespace_id, wtop, 0, {
            id = 1,
            virt_text = { virt_info },
            virt_text_pos = "right_align",
        })
    end
end

local function gcc_check ()
    local content = get_buffer_content()
    get_gcc_output(content, set_diagnostic)
end

local prev_ct = 0
api.nvim_create_autocmd(
    { "InsertLeave", "BufWritePost" }, {
        pattern = "*.c",
        callback = function ()
            local ct = api.nvim_buf_get_changedtick(0)
            if ct ~= prev_ct then
                prev_ct = ct
                gcc_check()
            end
        end
    }
)

api.nvim_create_autocmd(
    { "BufWinEnter", "TextChanged" }, {
        pattern = "*.c",
        callback = gcc_check
    }
)

api.nvim_create_autocmd("CursorHold", {
    pattern = "*.c",
    callback = get_cursor_diagnostic
})
