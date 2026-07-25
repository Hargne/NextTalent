local function list_test_files()
    local handle = assert(io.popen("find . -type f -name '*.test.lua' | sort", "r"))
    local output = handle:read("*a")
    handle:close()

    local files = {}
    for file in output:gmatch("[^\n]+") do
        if file ~= "" and file ~= "." then
            table.insert(files, file)
        end
    end

    return files
end

local function colorize(text, color)
    local codes = {
        red = "\27[31m",
        green = "\27[32m",
        reset = "\27[0m"
    }

    return codes[color] .. text .. codes.reset
end

local function run_test_file(file)
    local command = string.format('lua "%s"', file)
    local success = os.execute(command)

    if success == true or success == 0 then
        print(string.format("%s [PASS] %s", colorize("✔", "green"), file))
    else
        print(string.format("%s [FAIL] %s", colorize("✖", "red"), file))
        error("Test failed: " .. file)
    end
end

local test_files = list_test_files()

if #test_files == 0 then
    print("No test files found")
    return
end

for _, file in ipairs(test_files) do
    run_test_file(file)
end

print("--------------------------------")
print("All test files passed")
