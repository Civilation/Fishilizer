-- Simple build script for Fishilizer
-- Concatenates the src/*.lua modules (in a fixed order) into Fishilizer.lua

local order = {
    "Core.lua",
    "Attributes.lua",
    "UI.lua",
    "Serializers.lua",
    "Walker.lua",
    "Main.lua",
}

local parts = {}

for _, name in ipairs(order) do
    local path = "src/" .. name
    local f, err = io.open(path, "r")
    if not f then
        io.stderr:write(("build.lua: warning: %s not found, skipping\n"):format(path))
    else
        local content = f:read("*a")
        f:close()

        table.insert(parts, ("-- BEGIN %s\n"):format(name))
        table.insert(parts, content)
        table.insert(parts, ("\n-- END %s\n\n"):format(name))
    end
end

local outpath = "Fishilizer.lua"
local outf, err = io.open(outpath, "w")
if not outf then
    error(("build.lua: failed to write %s: %s"):format(outpath, tostring(err)))
end
outf:write(table.concat(parts))
outf:close()

print("Successfully built Fishilizer.lua")
