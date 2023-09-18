function processVimDiff(vimDiffOutput)
    local diff_result = {add = {}, mod = {}, del = {}}
    
    for line in vimDiffOutput:gmatch("@@%s-([^\n]+)") do
        local _, _, delStart, delCount, addStart, addCount = line:find("-(%d+)(,?%d-)%s+%+(%d+)(,?%d-)")
        
        if delStart and addStart then
            delStart, addStart = tonumber(delStart), tonumber(addStart)
            -- Strip comma from delCount and addCount, and convert to number
            delCount = tonumber(delCount:match(",?(%d+)") or "1")
            addCount = tonumber(addCount:match(",?(%d+)") or "1")
            
            for i = 1, delCount do
                table.insert(diff_result.del, delStart + i - 1)
            end
            
            for i = 1, addCount do
                table.insert(diff_result.add, addStart + i - 1)
            end
        end
    end
    
    return diff_result
end

-- 测试用例
local testCases = {
    "@@ -4,0 +5 @@\n+    this is line 4",
    "@@ -9,0 +10,3 @@\n+    this is line 9\n+    this is line 9\n+    this is line 9",
    "@@ -9,0 +10,3 @@\n+    this is line 9\n+    this is line 9\n+    this is line 9\n@@ -20,0 +24,3 @@\n+    this is line 20\n+    this is line 20\n+    this is line 20",
    "@@ -10,0 +11,3 @@\n+    this is line 10\n+    this is line 10\n+    this is line 10\n@@ -20,0 +24,3 @@\n+    this is line 20\n+    this is line 20\n+    this is line 20\n@@ -30,0 +37,3 @@\n+    this is line 30\n+    this is line 30\n+    this is line 30\n@@ -54,0 +64,3 @@\n+    this is line 54\n+    this is line 54\n+    this is line 54\n@@ -99,0 +112 @@\n+    this is line 99",
    "@@ -9 +9 @@\n-    this is line 9\n+    this is line 9a",
    "@@ -9 +9 @@\n-    this is line 9\n+    this is line 9a\n@@ -17,9 +17,9 @@\n-    this is line 17\n-    this is line 18\n-    this is line 19\n-    this is line 20\n-    this is line 21\n-    this is line 22\n-    this is line 23\n-    this is line 24\n-    this is line 25\n+    this is line 17a\n+    this is line 18a\n+    this is line 19a\n+    this is line 20a\n+    this is line 21a\n+    this is line 22a\n+    this is line 23a\n+    this is line 24a\n+    this is line 25a",
    "@@ -9 +9 @@\n-    this is line 9\n+    this is line 9a\n@@ -17,9 +17,9 @@\n-    this is line 17\n-    this is line 18\n-    this is line 19\n-    this is line 20\n-    this is line 21\n-    this is line 22\n-    this is line 23\n-    this is line 24\n-    this is line 25\n+    this is line 17a\n+    this is line 18a\n+    this is line 19a\n+    this is line 20a\n+    this is line 21a\n+    this is line 22a\n+    this is line 23a\n+    this is line 24a\n+    this is line 25a",
    "@@ -9 +9 @@\n-    this is line 9\n+    this is line 9a\n@@ -17,9 +17,9 @@\n-    this is line 17\n-    this is line 18\n-    this is line 19\n-    this is line 20\n-    this is line 21\n-    this is line 22\n-    this is line 23\n-    this is line 24\n-    this is line 25\n+    this is line 17a\n+    this is line 18a\n+    this is line 19a\n+    this is line 20a\n+    this is line 21a\n+    this is line 22a\n+    this is line 23a\n+    this is line 24a\n+    this is line 25a",
    "@@ -3 +2,0 @@\n-    this is line 3",
    "@@ -10,9 +9,0 @@\n-    this is line 10\n-    this is line 11\n-    this is line 12\n-    this is line 13\n-    this is line 14\n-    this is line 15\n-    this is line 16\n-    this is line 17\n-    this is line 18",
    "@@ -3 +2,0 @@\n-    this is line 3\n@@ -20,9 +18,0 @@\n-    this is line 20\n-    this is line 21\n-    this is line 22\n-    this is line 23\n-    this is line 24\n-    this is line 25\n-    this is line 26\n-    this is line 27\n-    this is line 28",
    "@@ -3 +2,0 @@\n-    this is line 3\n@@ -20,9 +18,0 @@\n-    this is line 20\n-    this is line 21\n-    this is line 22\n-    this is line 23\n-    this is line 24\n-    this is line 25\n-    this is line 26\n-    this is line 27\n-    this is line 28\n@@ -69,25 +58,0 @@\n-    this is line 69\n-    this is line 70\n-    this is line 71\n-    this is line 72\n-    this is line 73\n-    this is line 74\n-    this is line 75\n-    this is line 76\n-    this is line 77\n-    this is line 78\n-    this is line 79\n-    this is line 80\n-    this is line 81\n-    this is line 82\n-    this is line 83\n-    this is line 84\n-    this is line 85\n-    this is line 86\n-    this is line 87\n-    this is line 88\n-    this is line 89\n-    this is line 90\n-    this is line 91\n-    this is line 92\n-    this is line 93",
}

for _, testCase in ipairs(testCases) do
    local result = processVimDiff(testCase)
    print("diff_result = { add = {" .. table.concat(result.add, ", ") .. "}, del = {" .. table.concat(result.del, ", ") .. "}, mod = {" .. table.concat(result.mod, ", ") .. "} }")
end

