-- Core.lua
-- Top-level core state and helpers for Fishilizer (developer-friendly modular source).

local Fish = {}
Fish.VERSION = "10.1.1"
Fish.NAME = "Fishilizer"

Fish.Options = {
    Decompile = false,
    DecompileTimeout = 10,
    MaxThreads = 3,
    DecompileIgnore = { "Chat", "CoreGui", "CorePackages" },
    SaveBytecode = false,
    SaveScriptCache = false,
    SaveScriptCachePath = "FishilizerCache",
    NilInstances = false,
    RemovePlayerCharacters = true,
    SavePlayers = false,
    IsolateStarterPlayer = true,
    IsolateLocalPlayer = false,
    SavePlayerCharacters = false,
    IncludeBackpack = true,
    IgnoreDefaultProps = true,
    IgnoreNotArchivable = true,
    Binary = false,
    ShowStatus = true,
    ReadMe = true,
    Mode = "full",
    FilePath = false,
    Callback = false,
    Clipboard = false,
    AvoidFileOverwrite = true,
    SafeMode = false,
    BoostFPS = false,
    KillAllScripts = false,
    AntiIdle = false,
    Anonymous = false,
    OUT = "Fishilizer",
    Depth = 1000,
    Terrain = true,
    CSG = true,
    Notify = true,
    StripCharacters = true,
    StripCoreScripts = true,
    EmitTags = true,
    EmitAttributes = true,
    UseGetProperties = true,
    FetchDocs = false,
    APIDumpURL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json",
}

local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local function resolveIO(name)
    local g = (getgenv and getgenv()) or _G
    if g and type(g[name]) == "function" then
        return g[name]
    end
    if type(rawget(_G, name)) == "function" then
        return rawget(_G, name)
    end
    if g then
        for _, v in pairs(g) do
            if type(v) == "table" and type(v[name]) == "function" then
                return v[name]
            end
        end
    end
    return nil
end

local IO = {
    writefile = resolveIO("writefile"),
    readfile = resolveIO("readfile"),
    makefolder = resolveIO("makefolder"),
    isfolder = resolveIO("isfolder"),
    isfile = resolveIO("isfile"),
    delfile = resolveIO("delfile"),
    setclipboard = resolveIO("setclipboard"),
    getproperties = resolveIO("getproperties"),
}

local function log(msg)
    pcall(function() print("[Fishilizer] " .. tostring(msg)) end)
    pcall(function() warn("[Fishilizer] " .. tostring(msg)) end)
end

local function clean(s)
    s = tostring(s)
    s = s:gsub("[%z\1-\8\11\12\14-\31]", "")
    s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    s = s:gsub('"', "&quot;"):gsub("'", "&apos;")
    return s
end

local function nm(x)
    if type(x) ~= "number" then return "0" end
    if x ~= x then return "0" end
    if x == math.huge then return "1e308" end
    if x == -math.huge then return "-1e308" end
    if x == math.floor(x) and math.abs(x) < 1e15 then return string.format("%d", x) end
    return string.format("%.10g", x)
end

local function b64(s)
    return HttpService:Base64Encode(s)
end

local function notify(title, text, dur)
    if not Fish.Options.Notify then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur or 6,
        })
    end)
end

local function extractUri(v)
    if v == nil then return nil end
    local tv = type(v)
    if tv == "string" then
        if v == "" then return nil end
        local id = v:match("rbxassetid://(%d+)")
        if id then return "rbxassetid://" .. id end
        local num = v:match("^(%d+)$")
        if num and #num >= 5 then return "rbxassetid://" .. num end
        if v:match("^rbxasset://") or v:match("^rbxgameasset://") or v:match("^rbxthumb://") or v:match("^https?://") or v:match("^rbxfile://") then return v end
        local tail = v:match("(%d+)%s*$")
        if tail and #tail >= 5 then return "rbxassetid://" .. tail end
        return nil
    end
    if tv == "number" then return "rbxassetid://" .. tostring(v) end

    local accessors = { "Source", "Uri", "Url", "URL", "Value", "Text", "String", "AssetId", "AssetID", "Id", "ID", "Content", "source", "uri", "url", "value" }
    for _, key in ipairs(accessors) do
        local ok, s = pcall(function() return v[key] end)
        if ok and type(s) == "string" and s ~= "" then
            local inner = extractUri(s)
            if inner then return inner end
        end
        if ok and type(s) == "number" then return "rbxassetid://" .. tostring(s) end
    end

    local methods = { "ToString", "GetSource", "GetUri", "GetUrl" }
    for _, m in ipairs(methods) do
        local ok, f = pcall(function() return v[m] end)
        if ok and type(f) == "function" then
            local ok2, s = pcall(f, v)
            if ok2 and type(s) == "string" and s ~= "" then
                local inner = extractUri(s)
                if inner then return inner end
            end
        end
    end

    if tv == "table" then
        for _, val in pairs(v) do
            if type(val) == "string" and val ~= "" then
                local inner = extractUri(val)
                if inner then return inner end
            end
        end
    end

    local ok, s = pcall(tostring, v)
    if ok and type(s) == "string" and s ~= "" then
        local id = s:match("rbxassetid://(%d+)")
        if id then return "rbxassetid://" .. id end
        local asset = s:match("rbxasset://([^%s%)%,]+)")
        if asset then return "rbxasset://" .. asset end
        local ga = s:match("rbxgameasset://(%d+)")
        if ga then return "rbxgameasset://" .. ga end
        local thumb = s:match("rbxthumb://[^%s%)]+")
        if thumb then return thumb end
        local http = s:match("(https?://[^%s%)%,]+)")
        if http then return http end
        local inner = s:match("Content%((.-)%)")
        if inner and inner ~= "" and inner ~= s then return extractUri(inner) end
    end
    return nil
end

-- expose
Fish.IO = IO
Fish.log = log
Fish.clean = clean
Fish.nm = nm
Fish.b64 = b64
Fish.notify = notify
Fish.extractUri = extractUri

return Fish
