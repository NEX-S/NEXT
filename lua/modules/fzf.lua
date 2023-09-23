local api = vim.api

local git_path_cache = nil
local function get_git_path ()
    local handle = io.popen("git rev-parse --show-toplevel 2> /dev/null")
    git_path_cache = handle:read()
end

local function open_float_win (bufnr)
    local width  = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    local win_width  = math.ceil(width  * 0.7)
    local win_height = math.ceil(height * 0.7)

    local col = math.ceil((width  - win_width)  * 0.5)
    local row = math.ceil((height - win_height) * 0.4)

    local win_config = {
        row       = row,
        col       = col,
        width     = win_width,
        height    = win_height,
        relative  = "editor",
        style     = "minimal",
        noautocmd = true,
        focusable = true,
        border    = "single",
    }

    local winid = api.nvim_open_win(bufnr, true, win_config)

    api.nvim_win_set_option(winid, "winhl", "Normal:FloatTerm")
    api.nvim_win_set_option(winid, "winblend", 15)

    return winid
end

local fzf_option  = " --tac --no-sort -m --scroll-off=2"
local fzf_layout  = " --layout=reverse --border=none --info=inline-right --prompt=' ' --pointer='' --marker=''"
local fzf_hl      = " --color='fg:#666666,bg+:#222222,fg+:#AFC460,query:#686868,info:#343434,prompt:#585858,pointer:#AFC460,border:#202020'"
local fzf_preview = " --preview='head -1000 {}' --preview-window='border-left,nowrap'"
local fzf_keybind = " --bind=right:accept-non-empty,left:backward-kill-word,tab:preview-half-page-down"

local fzf_cmd = "fzf" .. fzf_option .. fzf_layout .. fzf_hl .. fzf_preview .. fzf_keybind

local function open_fzf ()
    local esc_exit  = false
    local fzf_bufnr = api.nvim_create_buf(false, true)
    local fzf_winid = open_float_win(fzf_bufnr)

    local fzf_cmd = git_path_cache == nil
        and fzf_cmd or "find " .. git_path_cache .. " -type d -name .git -prune -o -type f -print |" .. fzf_cmd

    vim.fn.termopen(fzf_cmd, {
        on_exit = function ()
            if not esc_exit then
                local file = api.nvim_buf_get_lines(fzf_bufnr, 0, 1, false)[1]
                if file ~= '' then
                    -- ADD MORE ACTION?
                    api.nvim_command("tabnew " .. file)
                end
                api.nvim_win_close(fzf_winid, { force = true })
            end
        end
    })

    vim.bo.ft = "TERMINAL"

    api.nvim_buf_set_keymap(fzf_bufnr, 't', '<ESC>', '', {
        callback = function ()
            esc_exit = true
            api.nvim_win_close(fzf_winid, { force = true })
            api.nvim_buf_delete(fzf_bufnr, { force = true })
        end
    })
end

api.nvim_set_keymap('n', ',f', '', { callback = open_fzf })

api.nvim_create_autocmd("DirChanged", { callback = get_git_path })
