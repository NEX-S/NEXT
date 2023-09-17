local api = vim.api

_G.NVIM_TABLINE_NEWTAB = function() api.nvim_command("tabnew") end
_G.NVIM_TABLINE_NEXTAB = function() api.nvim_command("tabnext") end
_G.NVIM_TABLINE_EXITAB = function(tabnr)
    tabnr = tabnr == 0 and '' or tabnr
    nvcmd = vim.fn.tabpagenr('$') == 1 and "quitall!" or "tabclose " .. tabnr
    api.nvim_command(nvcmd)
end

local function get_tab_icon (ft)
    local ft_icon = {
        lua  = "  ",
        vim  = "  ",
        html = "  ",
        c    = "  ",
        php  = " ▼ ",
        markdown = "   ",
    }

    return "%#InactiveTabFtIcon# " .. (ft_icon[ft] or ' ')
end

local function get_mod_icon (tabnr, buflist)
    for _, bufnr in ipairs(buflist) do
        if api.nvim_buf_get_option(bufnr, "mod") == true then
            return "%#InactiveTabMod#  "
        end
    end

    tabnr = tabnr == 0 and 1 or tabnr

    return "%#InactiveTabClose#%" .. tabnr .. "@v:lua.NVIM_TABLINE_EXITAB@  "
end

local function get_tab_page (tabnr, is_active)
    local buflist = vim.fn.tabpagebuflist(tabnr)

    local modicon = get_mod_icon(tabnr, buflist)
    local tabicon = get_tab_icon(api.nvim_buf_get_option(buflist[1], "filetype"))

    local tabname = api.nvim_buf_get_name(buflist[1])

    tabname = "%#InactiveTabName#" .. (tabname ~= '' and tabname:gsub(".*/", '') or "UNKNOWN")

    local tabpage = "%" .. tabnr .. "T" .. "%#InactiveTabSepL#" .. tabicon .. tabname .. modicon .. "%#InactiveTabSepR#"

    return not is_active and tabpage or tabpage:gsub("Inactive", "Active"):gsub("", "", 1)
end

_G.NVIM_TABLINE = function ()
    local tabline_prefix = "%#TabLinePrefix#%@v:lua.NVIM_TABLINE_NEXTAB@  "
    local tabline_suffix = "%#TabLineSuffix#%@v:lua.NVIM_TABLINE_EXITAB@  "
    local tabline_newtab = "%#TabLineNewtab#%@v:lua.NVIM_TABLINE_NEWTAB@ + "

    local tabline_time = "%#TabLineTime#%{ strftime('%H:%M') }"

    local tabline_page = ''
    for tabnr = 1, vim.fn.tabpagenr('$') do
        if tabnr == api.nvim_tabpage_get_number(0) then
            tabline_page = tabline_page .. get_tab_page(tabnr, true)
        else
            tabline_page = tabline_page .. get_tab_page(tabnr, false)
        end
    end

    return tabline_prefix .. tabline_page .. tabline_newtab ..  "%=" .. tabline_time .. tabline_suffix
end

api.nvim_set_option_value("showtabline", 2, {})
api.nvim_set_option_value("tabline", "%!v:lua.NVIM_TABLINE()", {})
