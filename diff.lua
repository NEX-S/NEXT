local test_str_1 = [[
    this is line 1
    this is line 2
    this is line 3
    this is line 4
    this is line 5
    this is line 6
    this is line 7
    this is line 8
    this is line 9
]]

local test_str_2 = [[
    this is line 1
    this is line 2
    this is line 2
    this is line 3
    this is line 4
    this is line 5
    this is line 6
    this is line 7
    this is line 8
    this is line 8
    this is line 8
    this is line 9
]]

-- print(vim.diff(test_str_1, test_str_2, {}))

function parse_diff_output(diff_output)
    local result = {}
    local line_number = 0
    local lines = vim.split(diff_output, '\n')
    for _, line in ipairs(lines) do
        if line:sub(1, 2) == "@@" then
            local parts = vim.split(line, ' ')
            local old_range = parts[2]
            local old_parts = vim.split(old_range, ',')
            local old_start = tonumber(old_parts[1]:sub(2))
            line_number = old_start
        elseif line:sub(1, 1) == '+' then
            table.insert(result, line_number + 1)
            line_number = line_number + 1
        end
    end
    return result
end

local str = [[
写一个 lua 函数，解析 neovim 函数 vim.diff 的输出并返回一个表：

假设 vim.diff 返回
@@ -2,0 +3,3 @@
+    this is line 2
+    this is line 2
+    this is line 2
@@ -7,0 +11,3 @@
+    this is line 7
+    this is line 7
+    this is line 7

这个函数返回 { 3, 4, 5, 8, 9, 10 }
    
假设 vim.diff 返回
@@ -1,0 +2,2 @@
+    this is line 1
+    this is line 1
这个函数返回 { 2, 3 }

假设 vim.diff 返回
@@ -4,0 +5 @@
+    this is line 4
这个函数返回 { 5 }

假设 vim.diff 返回
@@ -2,0 +3 @@
+    this is line 2
@@ -8,0 +10,2 @@
+    this is line 8
+    this is line 8
这个函数返回 { 3, 9, 10 }
]]

