local files = {
    "src/Core.lua",
    "src/Attributes.lua",
    "src/UI.lua",
    "src/Serializers.lua",
    "src/Walker.lua",
    "src/Main.lua",
}

local output = ""
for _, file in ipairs(files) do
    local f = io.open(file, "r")
    if f then
        output = output .. f:read("*a") .. "\n\n"
        f:close()
    else
        print("Warning: Could not find " .. file)
    end
end

local outFile = io.open("Fishilizer.lua", "w")
outFile:write(output)
outFile:close()
print("Successfully built Fishilizer.lua")
