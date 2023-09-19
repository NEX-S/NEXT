local function str_to_tbl (str)
    local res = {}
    for line in str:gmatch("[^\n]+") do
        table.insert(res, line)
    end
    return res
end

local function parse_diff_output (diff_output)
    local diff_result = {
        add = {},
        mod = {},
        del = {},
    }

    for x1, y1, x2, y2 in diff_output:gmatch("@@ %-([%d]+),?([%d]*) %+([%d]+),?([%d]*) @@")
    do
        x1 = tonumber(x1)
        x2 = tonumber(x2)

        y1 = y1 == '' and 1 or tonumber(y1)
        y2 = y2 == '' and 1 or tonumber(y2)

        if x2 > x1 then
            for i = 1, y2 do
                table.insert(diff_result.add, x2 + i - 1)
            end
        elseif x2 < x1 then
            table.insert(diff_result.del, x2 + 1 + y2)
        elseif x1 == x2 and y1 == y2 then
            for i = 0, y2 - 1 do
                table.insert(diff_result.mod, x2 + i)
            end
        end
    end

    return diff_result
end

local test = [[
@@ -78,3 +77,0 @@
-    this is line 78
-    this is line 79
-    this is line 80
@@ -85,3 +82,3 @@
-    this is line 85
-    this is line 86
-    this is line 87
+    this is line 85a
+    this is line 86a
+    this is line 87a
@@ -91,0 +89,2 @@
+    this is line 91
+    this is line 91
]]

print(vim.inspect(parse_diff_output(test)))
