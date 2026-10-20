--[[

Fishilizer is now open-sourced.

A gift from Garfield Cat Presents

The source is available for anyone who wants to contribute to its development

Fishilizer is still being worked on, and there is more to come.
There are features to improve, and things to fix

Eventually, once Fishilizer reaches its full power, it will no longer
be open-sourced. Until then, enjoy this special gift and make the most of it.

If you find bugs or have suggestions, feel free to share them with the
community. Feedback is always appreciated!!

Please give credit to the original project if you use or modify its code.

Thank you to everyone who has supported Fishilizer so far.

Enjoy this special gift <3

Made by Garfield Cat Presents.

]]



local Fish = {}
Fish.VERSION = "10.8.1"
Fish.NAME = "Fishilizer"
--[[

i added these because i was bored and had nothing else to do before i started this (adhd me xD)

  ]]

Fish.BannerLines = {
    [[                          _.'.__]],
    [[                      _.'      .]],
    [[':'.               .''   __ __  .]],
    [[  '.:._          ./  _ ''     "-'.__]],
    [[.'''-: """-._    | .                "-"._]],
    [[ '.     .    "._.'                       "]],
    [[    '.   "-.___ .        .'          .  :o'.]],
    [[      |   .----  .      .           .'     (]],
    [[       '|  ----. '   ,.._                _-']],
    [[        .' .---  |.""  .-:;.. _____.----']],
    [[        |   .-""""    |      ']],
    [[      .'  _'         .'    _']],
    [[     |_.-'    -cat-   '-.']],
}

Fish.Banner = table.concat(Fish.BannerLines, "\n")

Fish.Bootstrap = {
    scriptURL = "https://fishilizer.github.io/fishilizer.lua",
    versionURL = "https://fishilizer.github.io/fishilizer.lua",
}

local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function resolveIO(name)
    local g = (getgenv and getgenv()) or _G
    if g and type(g[name]) == "function" then return g[name] end
    if type(rawget(_G, name)) == "function" then return rawget(_G, name) end
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
    appendfile = resolveIO("appendfile"),
    setclipboard = resolveIO("setclipboard"),
    getproperties = resolveIO("getproperties"),
}
---lowk if you dont have any of these on ur executor its ggs

local Console = (function()
    local g = (getgenv and getgenv()) or _G or {}
    local c = {}
    c.create = g.rconsolecreate or g.rconsole_create
    c.print = g.rconsoleprint or g.rconsole_print
    c.title = g.rconsolesettitle or g.rconsole_title
    c.clear = g.rconsoleclear or g.rconsole_clear
    c.close = g.rconsoleclose or g.rconsole_close
    if type(c.print) == "function" then return c end
    if type(g.getconsole) == "function" then
        local ok, con = pcall(g.getconsole)
        if ok and con and type(con.Print) == "function" then
            c.print = function(s) pcall(con.Print, con, s) end
            c.title = function(s) pcall(con.SetTitle, con, s) end
            c.clear = function() pcall(con.Clear, con) end
            c.close = function() pcall(con.Close, con) end
            c.create = function() end
            return c
        end
    end
    for _, v in pairs(g) do
        if type(v) == "table" then
            if type(v.rconsoleprint) == "function" then
                c.print = v.rconsoleprint
                c.create = c.create or v.rconsolecreate
                c.title = c.title or v.rconsolesettitle
                c.clear = c.clear or v.rconsoleclear
                c.close = c.close or v.rconsoleclose
                return c
            end
            if type(v.Print) == "function" and type(v.SetTitle) == "function" then
                c.print = function(s) pcall(v.Print, v, s) end
                c.title = function(s) pcall(v.SetTitle, v, s) end
                c.clear = function() pcall(v.Clear, v) end
                c.close = function() pcall(v.Close, v) end
                c.create = function() end
                return c
            end
        end
    end
    return nil
end)()

local _consoleReady = false
local _consoleClosed = false

local function ConWrite(s)
    if _consoleClosed then return end
    if not Console or type(Console.print) ~= "function" then
        pcall(function() print(tostring(s)) end)
        return
    end
    if not _consoleReady then
        _consoleReady = true
        if type(Console.create) == "function" then pcall(Console.create) end
        if type(Console.title) == "function" then pcall(Console.title, "Fishilizer v" .. tostring(Fish.VERSION)) end
    end
    pcall(Console.print, tostring(s) .. "\n")
end

local function ConWriteBanner()
    for _, line in ipairs(Fish.BannerLines) do
        ConWrite(line)
    end
end

local _closeAttempted = false
local _closeTried = {}

local function _tryClose(fn, ...)
    if _closeAttempted or type(fn) ~= "function" or _closeTried[fn] then return false end
    _closeTried[fn] = true
    local ok = pcall(fn, ...)
    _closeAttempted = true
    return ok
end

local function resolveHttp()
    local g = (getgenv and getgenv()) or _G or {}
    local candidates = { g.request, g.http_request }
    if type(g.http) == "table" then table.insert(candidates, g.http.request) end
    if type(g.Http) == "table" then table.insert(candidates, g.Http.request) end
    if type(g.HTTP) == "table" then table.insert(candidates, g.HTTP.request) end
    for _, v in pairs(g) do
        if type(v) == "table" then
            local rf = v.request or v.http_request or v.Request
            if type(rf) == "function" then table.insert(candidates, rf) end
        end
    end
    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            return function(opts)
                local ok, res = pcall(fn, opts)
                if ok and res then return res end
                return nil
            end
        end
    end
    return nil
end

local function closeConsoleWithVulns()
    if _consoleClosed then return end
    local g = (getgenv and getgenv()) or _G or {}

    if Console and type(Console.close) == "function" then
        if _tryClose(Console.close) then _consoleClosed = true return end
    end

    local direct = {
        g.rconsoleclose, g.rconsole_close, g.rconsoleclosewindow,
        g.closeconsole, g.close_console, g.closerconsole,
    }
    for _, fn in ipairs(direct) do
        if _tryClose(fn) then _consoleClosed = true return end
    end

    for _, v in pairs(g) do
        if type(v) == "table" then
            for _, k in ipairs({ "close", "Close", "closeConsole", "CloseConsole", "CloseWindow", "closewindow", "Kill", "kill" }) do
                local fn = v[k]
                if type(fn) == "function" then
                    if _tryClose(fn, v) then _consoleClosed = true return end
                end
            end
        end
    end

    local req = resolveHttp()
    if req then
        local ports = { 49664, 6977, 27060, 12345, 4563 }
        for _, port in ipairs(ports) do
            if _closeAttempted then break end
            pcall(function()
                req({ Url = "http://127.0.0.1:" .. port .. "/close", Method = "GET", Timeout = 1 })
                req({ Url = "http://127.0.0.1:" .. port .. "/kill", Method = "GET", Timeout = 1 })
            end)
        end
        _closeAttempted = true
    end

    if not _consoleClosed then
        pcall(function() ConWrite("\27[2J\27[H\27[0;0H") end)
        _consoleClosed = true
    end
end

Fish.CloseConsole = closeConsoleWithVulns

local function ConInit()
    ConWriteBanner()
    ConWrite("[Fishilizer] v" .. tostring(Fish.VERSION))
end

local _logCache = {}
local _logPath = nil

local function logFilePath()
    if _logPath then return _logPath end
    local out = tostring(Fish.Options.OUT or "Fishilizer")
    local path = out .. "/Fishilizer.log"
    if IO.makefolder and IO.isfolder then
        local okF, exists = pcall(IO.isfolder, out)
        if not okF or not exists then pcall(IO.makefolder, out) end
    end
    _logPath = path
    return path
end

local function flushLog()
    if not Fish.Options.LogToFile then return end
    local path = logFilePath()
    if IO.appendfile then
        local okA = pcall(IO.appendfile, path, "")
        if okA then
            for i = 1, #_logCache do
                pcall(IO.appendfile, path, _logCache[i] .. "\n")
            end
            _logCache = {}
            return
        end
    end
    if IO.writefile then
        local blob = table.concat(_logCache, "\n")
        pcall(IO.writefile, path, blob)
    end
end

local function log(msg)
    local line = "[Fishilizer] " .. tostring(msg)
    pcall(function() print(line) end)
    ConWrite(line)
    if Fish.Options.LogToFile then
        local stamp = os.date("!%H:%M:%S")
        _logCache[#_logCache + 1] = "[" .. stamp .. "] " .. tostring(msg)
        if #_logCache >= 32 then flushLog() end
    end
end

local function resolveBytecode()
    if type(getscriptbytecode) == "function" then return getscriptbytecode end
    local g = (getgenv and getgenv()) or _G
    if g then
        for _, v in pairs(g) do
            if type(v) == "table" and type(v.getscriptbytecode) == "function" then
                return v.getscriptbytecode
            end
        end
    end
    return nil
end

local function resolveDecompile()
    if type(decompile) == "function" then return decompile end
    if type(decompile_script) == "function" then return decompile_script end
    local g = (getgenv and getgenv()) or _G
    if g then
        if type(g.decompile) == "function" then return g.decompile end
        if type(g.decompile_script) == "function" then return g.decompile_script end
        for _, v in pairs(g) do
            if type(v) == "table" then
                if type(v.decompile) == "function" then return v.decompile end
                if type(v.decompile_script) == "function" then return v.decompile_script end
            end
        end
    end
    return nil
end

--- a list of apis
Fish.Options = {
    Decompile = true,
    MaxThreads = 3,
    SaveBytecode = false,
    RemovePlayerCharacters = true,
    IncludeBackpack = true,
    IgnoreDefaultProps = true,
    IgnoreNotArchivable = true,
    UseGetProperties = true,
    FetchDocs = true,
    APIProperties = true,
    UseReflectionService = true,
    Mode = "full",
    FilePath = false,
    Callback = false,
    Clipboard = false,
    AvoidFileOverwrite = true,
    KillAllScripts = false,
    Anonymous = false,
    EmitTags = true,
    EmitAttributes = false,
    StripCharacters = true,
    StripCoreScripts = true,
    TerrainResolution = 8,
    TerrainCellCap = 4194304,
    Depth = 100,
    Notify = true,
    ShowStatus = true,
    ReadMe = true,
    StreamToFile = true,
    StreamChunk = 262144,
    LogToFile = true,
    Console = true,
    CloseConsole = false,
    AutoRun = true,
    OUT = "Fishilizer",
    DataAPIURL = "https://civilation.github.io/Fishilizer/",
    APIDumpURL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json", -- why do i still use this

    LunaUXURL = "https://lunaux-decompiler.dev/api/decompile",
}

local DATA = {
    version = "0.0.0",
    instance_specific = {},
    critical_props = {},
    binary_props = {},
    real_content_props = {},
    content_prop_exact = {},
    core_script_names = {},
    character_classes = {},
    skip_svc = {},
    skip_prop = {},
    attr_type_ids = { string=0x02, boolean=0x03, number=0x04 },
    ser_types = {},
    server_script_placeholder = "-- Serverscripts are almost IMPOSSIBLE to save without additional requirements in every serverscript",
    readme_template = "",
    decompiler = nil,
}

local SKIP_SVC = {}
local SKIP_PROP = {}
local BINARY_PROPS = {}
local CONTENT_PROP_EXACT = {}
local REAL_CONTENT_PROPS = {}
local CORE_SCRIPT_NAMES = {}
local CHARACTER_CLASSES = {}
local CRITICAL_PROPS = {}
local CRITICAL_PROPS_SET = {}
local INSTANCE_SPECIFIC = {}
local ATTR_TYPE_IDS = { string=0x02, boolean=0x03, number=0x04 }
local _dataLoaded = false


---basically just got claude to do this part for me since i dont know how to make fallbacks :pray:
local FALLBACK = {
    meta = { version = "0.0.0" },
    tables = {
        instance_specific = {},
        critical_props = {
            "Name","Archivable","Source","Disabled","RunContext","Texture","TextureId","TextureID",
            "Image","MeshId","SoundId","AnimationId","ShirtTemplate","PantsTemplate","Graphic","Decal",
            "Size","CFrame","Anchored","CanCollide","CanTouch","Transparency","Reflectance","Material",
            "Color","BrickColor","Value","Text","FontFace","BackgroundColor3","BackgroundTransparency",
            "Visible","ZIndex","Ambient","Brightness","ClockTime","Part0","Part1","C0","C1",
            "Attachment0","Attachment1","SmoothGrid","MaterialColors","ChildData","PhysicsData","PhysicalConfigData"
        },
        binary_props = {"SmoothGrid","ChildData","PhysicsData","PhysicalConfigData","MaterialColors"},
        real_content_props = {"Texture","TextureId","TextureID","Image","MeshId","SoundId","AnimationId","Decal","ShirtTemplate","PantsTemplate","Graphic"},
        content_prop_exact = {},
        core_script_names = {},
        character_classes = {"Humanoid","Head","Torso","HumanoidRootPart","UpperTorso","LowerTorso"},
        skip_svc = {"CoreGui","CorePackages","CoreScripts","Chat","LogService"},
        skip_prop = {"Parent","RobloxLocked","HistoryId","ClassName","AttributesSerialize","Tags"},
        attr_type_ids = {string=0x02,boolean=0x03,number=0x04,UDim=0x0D,UDim2=0x10,Vector2=0x12,Vector3=0x13,CFrame=0x10,Color3=0x1A,BrickColor=0x1E,NumberRange=0x1F,NumberSequence=0x20,ColorSequence=0x21,Rect=0x22,Font=0x1C},
        ser_types = {},
    },
    templates = {
        server_script_placeholder = "-- Serverscripts are almost IMPOSSIBLE to save without additional requirements in every serverscript",
        readme = "",
    },
}

local function toSet(arr)
    local s = {}
    if type(arr) == "table" then
        for _, v in ipairs(arr) do
            if type(v) == "string" then s[v] = true end
        end
    end
    return s
end

local function shouldSkipProp(name)
    if SKIP_PROP[name] then return true end
    if CONTENT_PROP_EXACT[name] then return true end
    return false
end

local function applyData(d)
    local t = d.tables or d
    if type(t.instance_specific) == "table" then INSTANCE_SPECIFIC = t.instance_specific end
    if type(t.critical_props) == "table" then
        CRITICAL_PROPS = t.critical_props
        CRITICAL_PROPS_SET = toSet(t.critical_props)
    end
    if type(t.binary_props) == "table" then BINARY_PROPS = toSet(t.binary_props) end
    if type(t.real_content_props) == "table" then REAL_CONTENT_PROPS = toSet(t.real_content_props) end
    if type(t.content_prop_exact) == "table" then CONTENT_PROP_EXACT = toSet(t.content_prop_exact) end
    if type(t.core_script_names) == "table" then CORE_SCRIPT_NAMES = toSet(t.core_script_names) end
    if type(t.character_classes) == "table" then CHARACTER_CLASSES = toSet(t.character_classes) end
    if type(t.skip_svc) == "table" then SKIP_SVC = toSet(t.skip_svc) end
    if type(t.skip_prop) == "table" then SKIP_PROP = toSet(t.skip_prop) end
    if type(t.attr_type_ids) == "table" then ATTR_TYPE_IDS = t.attr_type_ids end
    if type(t.ser_types) == "table" then DATA.ser_types = t.ser_types end

    local tmpl = d.templates or d
    if type(tmpl.server_script_placeholder) == "string" and tmpl.server_script_placeholder ~= "" then
        DATA.server_script_placeholder = tmpl.server_script_placeholder
    end
    if type(tmpl.readme) == "string" and tmpl.readme ~= "" then
        DATA.readme_template = tmpl.readme
    end

    if type(d.decompiler) == "table" then
        DATA.decompiler = d.decompiler
    end

    if type(d.options) == "table" then
        for k, v in pairs(d.options) do
            if Fish.Options[k] == nil then Fish.Options[k] = v end
        end
    end

    if d.meta and type(d.meta.version) == "string" then
        DATA.version = d.meta.version
    end
end

local function loadFromAPI()
    if _dataLoaded then return _dataLoaded end
    local ok, html = pcall(function() return game:HttpGet(Fish.Options.DataAPIURL) end)
    if ok and type(html) == "string" and #html > 0 then
        local blob = html:match('<script[^>]*id="fish%-data"[^>]*>(.-)</script>')
        if blob then
            local okD, decoded = pcall(HttpService.JSONDecode, HttpService, blob)
            if okD and type(decoded) == "table" then
                applyData(decoded)
                _dataLoaded = true
                log("Data API loaded v" .. tostring(DATA.version or "?"))
                return true
            end
        end
    end
    log("Data API unreachable")
    applyData(FALLBACK)
    _dataLoaded = true
    return false
end

local apiClassProps = {}

local function buildApiClassProps(data)
    if type(data) ~= "table" or type(data.Classes) ~= "table" then return end
    local ownProps = {}
    local superclass = {}
    for _, class in ipairs(data.Classes) do
        local cn = class.Name
        if cn then
            superclass[cn] = class.Superclass
            local props = {}
            if type(class.Members) == "table" then
                for _, m in ipairs(class.Members) do
                    if m.MemberType == "Property" and m.Name then
                        props[m.Name] = true
                    end
                end
            end
            ownProps[cn] = props
        end
    end
    local count = 0
    for cn in pairs(ownProps) do
        local combined = {}
        local cur = cn
        local guard = 0
        while cur and guard < 50 do
            local p = ownProps[cur]
            if not p then break end
            for k in pairs(p) do combined[k] = true end
            cur = superclass[cur]
            guard = guard + 1
        end
        apiClassProps[cn] = combined
        count = count + 1
    end
    log("API dump: property cache built for " .. count .. " classes")
end

local function buildReflectionProps()
    if not Fish.Options.UseReflectionService then return end
    local ok, RS = pcall(function() return game:GetService("ReflectionService") end)
    if not ok or not RS then
        log("ReflectionService not available.")
        return
    end
    
    local okClasses, classes = pcall(function() return RS:GetClasses({}) end)
    if not okClasses or not classes then return end
    
    local count = 0
    for _, class in ipairs(classes) do
        local className = class.Name
        if className and not INSTANCE_SPECIFIC[className] then
            local props = {}
            local okProps, reflectedProps = pcall(function() return RS:GetPropertiesOfClass(className, {}) end)
            if okProps and reflectedProps then
                for _, prop in ipairs(reflectedProps) do
                    if prop.Name and not shouldSkipProp(prop.Name) then
                        table.insert(props, prop.Name)
                        if CRITICAL_PROPS_SET[prop.Name] then
                            apiClassProps[className] = apiClassProps[className] or {}
                            apiClassProps[className][prop.Name] = true
                        end
                    end
                end
            end
            if #props > 0 then
                INSTANCE_SPECIFIC[className] = props
                count = count + 1
            end
        end
    end
    log("ReflectionService: built property cache for " .. count .. " classes directly from engine.")
end

local function isPropValid(cls, propName)
    if CRITICAL_PROPS_SET[propName] then return true end
    local apiSet = apiClassProps[cls]
    if not apiSet then return true end
    return apiSet[propName] == true
end

local function httpPost(url, body, headers)
    local g = (getgenv and getgenv()) or _G or {}
    local sent = {}

    local function tryCall(fn)
        if type(fn) ~= "function" or sent[fn] then return nil end
        sent[fn] = true
        local ok, res = pcall(fn, { Url = url, Method = "POST", Body = body, Headers = headers or {} })
        if not ok or res == nil then return nil end
        if type(res) == "string" then return { status = 200, body = res } end
        if type(res) ~= "table" then return nil end
        local st = res.StatusCode or res.status or res.Status
        local bd = res.Body or res.body or res.Response or res.Data
        if type(bd) == "table" then
            local okE, e = pcall(HttpService.JSONEncode, HttpService, bd)
            if okE then bd = e end
        end
        if type(bd) == "string" then return { status = st, body = bd } end
        return nil
    end

    local r = tryCall(g.request) if r then return r end
    if type(g.http) == "table" then r = tryCall(g.http.request) if r then return r end end
    if type(g.Http) == "table" then r = tryCall(g.Http.request) if r then return r end end
    if type(g.HTTP) == "table" then r = tryCall(g.HTTP.request) if r then return r end end
    r = tryCall(g.http_request) if r then return r end

    for _, v in pairs(g) do
        if type(v) == "table" then
            local rf = v.request or v.http_request or v.Request
            r = tryCall(rf)
            if r then return r end
        end
    end

    local ok, res = pcall(HttpService.RequestAsync, HttpService, {
        Url = url,
        Method = "POST",
        Body = body,
        Headers = headers or {}
    })
    if ok and res then
        return { status = res.StatusCode, body = res.Body }
    end

    return nil
end

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function b64(s)
    if type(s) ~= "string" then return "" end
    local res = {}
    local i = 1
    local len = #s
    while i <= len do
        local c1 = s:byte(i)
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local b1 = math.floor(c1 / 4)
        local b2 = (c1 % 4) * 16 + (c2 and math.floor(c2 / 16) or 0)
        local b3 = c2 and ((c2 % 16) * 4 + (c3 and math.floor(c3 / 64) or 0)) or 0
        local b4 = c3 and (c3 % 64) or 0
        table.insert(res, b64chars:sub(b1 + 1, b1 + 1))
        table.insert(res, b64chars:sub(b2 + 1, b2 + 1))
        table.insert(res, c2 and b64chars:sub(b3 + 1, b3 + 1) or "=")
        table.insert(res, c3 and b64chars:sub(b4 + 1, b4 + 1) or "=")
        i = i + 3
    end
    return table.concat(res)
end

local function lunauxDecompile(inst)
    local bytecodeFn = resolveBytecode()
    local execDec = resolveDecompile()
    
    if not bytecodeFn then
        if execDec then
            local ok, res = pcall(execDec, inst)
            if ok and type(res) == "string" and res ~= "" then return res end
        end
        return nil
    end
    
    local ok, bytecode = pcall(bytecodeFn, inst)
    if not ok or type(bytecode) ~= "string" or #bytecode == 0 then
        if execDec then
            local ok2, res2 = pcall(execDec, inst)
            if ok2 and type(res2) == "string" and res2 ~= "" then return res2 end
        end
        return nil
    end


    --16/10/26
    --ok so looks like lunaux didnt work afterall so i guess im just gonna have to scrap this and use lua.expert :(
    local dc = DATA.decompiler or {}
    local url = dc.url or Fish.Options.LunaUXURL
    local headers = dc.headers or { ["Content-Type"] = "application/json" }
    local reqOpts = (dc.body and dc.body.options) or {
        transformCompoundAssignments = true,
        virtualizeContinues = true,
        showFunctionInfo = true,
        upvalueComments = true,
    }
    local responseKeys = dc.responseKeys or { "source", "decompiled", "result", "code", "output" }

    local payload = HttpService:JSONEncode({ script = b64(bytecode), options = reqOpts })
    local res = httpPost(url, payload, headers)
    
    if res and res.body then
        local okD, data = pcall(HttpService.JSONDecode, HttpService, res.body)
        if okD and type(data) == "table" then
            for _, k in ipairs(responseKeys) do
                if type(data[k]) == "string" and #data[k] > 0 then return data[k] end
            end
        elseif res.status and tonumber(res.status) and tonumber(res.status) >= 200 and tonumber(res.status) < 300 then
            if type(res.body) == "string" and #res.body > 0 and res.body:sub(1, 1) ~= "<" then
                return res.body
            end
        end
    end
    
    if execDec then
        local ok3, res3 = pcall(execDec, inst)
        if ok3 and type(res3) == "string" and res3 ~= "" then return res3 end
    end
    
    return nil
end

function Fish.FetchClasses(cacheFile)
    cacheFile = cacheFile or "FishilizerAPIDump.json"
    if IO.isfile and IO.readfile then
        local okI, exists = pcall(IO.isfile, cacheFile)
        if okI and exists then
            local okR, cached = pcall(IO.readfile, cacheFile)
            if okR and cached and #cached > 100 then
                local okD, data = pcall(HttpService.JSONDecode, HttpService, cached)
                if okD and data then
                    Fish.ApplyAPIDump(data)
                    log("Loaded cached API dump")
                    return data
                end
            end
        end
    end
    local okG, raw = pcall(function() return game:HttpGet(Fish.Options.APIDumpURL) end)
    if not okG or not raw then log("Failed to fetch API dump") return nil end
    if IO.writefile then pcall(IO.writefile, cacheFile, raw) end
    local okD, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not okD or not data then log("Failed to parse API dump") return nil end
    Fish.ApplyAPIDump(data)
    return data
end

function Fish.ApplyAPIDump(data)
    if type(data) ~= "table" or type(data.Classes) ~= "table" then return end
    local added = 0
    for _, class in ipairs(data.Classes) do
        local className = class.Name
        if className and not INSTANCE_SPECIFIC[className] then
            local props = {}
            if type(class.Members) == "table" then
                for _, member in ipairs(class.Members) do
                    if member.MemberType == "Property" and member.Name and not shouldSkipProp(member.Name) then
                        table.insert(props, member.Name)
                    end
                end
            end
            if class.Superclass and INSTANCE_SPECIFIC[class.Superclass] then
                for _, p in ipairs(INSTANCE_SPECIFIC[class.Superclass]) do table.insert(props, p) end
            end
            if #props > 0 then
                INSTANCE_SPECIFIC[className] = props
                added = added + 1
            end
        end
    end
    log("API dump: added " .. added .. " classes to INSTANCE_SPECIFIC")
    buildApiClassProps(data)
end

local _statusAccum = 0
local _lastConsolePct = -1

local function setStatusText(text, color)
    if Fish.Options.LogToFile then
        _logCache[#_logCache + 1] = "[" .. os.date("!%H:%M:%S") .. "] " .. tostring(text)
        if #_logCache >= 32 then flushLog() end
    end
end

local function bumpStatus(prefix, current, total)
    _statusAccum = _statusAccum + 1
    local pct = 0
    if total and total > 0 then
        pct = math.floor((current / total) * 100)
        if pct > 100 then pct = 100 end
    end
    if _statusAccum % 25 ~= 0 then return end
    
    setStatusText(prefix .. " " .. current .. "/" .. total .. " (" .. pct .. "%)")
    
    if pct ~= _lastConsolePct then
        _lastConsolePct = pct
        ConWrite("[Fishilizer] " .. prefix .. " " .. current .. "/" .. total .. " (" .. pct .. "%)")
    end
    task.wait()
end

local function u32(n) return string.pack("<I4", n) end
local function f32(n) return string.pack("<f", n) end
local function f64(n) return string.pack("<d", n) end
local function i32(n) return string.pack("<i4", n) end
local function wstr(s) return u32(#s) .. s end

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

local function isRealContent(name) return REAL_CONTENT_PROPS[name] == true end

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
    local accessors = {"Source","Uri","Url","URL","Value","Text","String","AssetId","AssetID","Id","ID","Content","source","uri","url","value"}
    for _, key in ipairs(accessors) do
        local ok, s = pcall(function() return v[key] end)
        if ok and type(s) == "string" and s ~= "" then
            local inner = extractUri(s)
            if inner then return inner end
        end
        if ok and type(s) == "number" then return "rbxassetid://" .. tostring(s) end
    end
    local methods = {"ToString","GetSource","GetUri","GetUrl"}
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

local function notify(title, text, dur)
    if not Fish.Options.Notify then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 6,
        })
    end)
end

local function serContentTag(name, uri) return '<Content name="' .. clean(name) .. '"><url>' .. clean(uri) .. '</url></Content>' end
local function serString(name, v) if type(v) ~= "string" then return nil end return '<string name="' .. clean(name) .. '">' .. clean(v) .. '</string>' end
local function serProtectedString(name, v) if type(v) ~= "string" then v = "" end return '<ProtectedString name="' .. clean(name) .. '">' .. clean(v) .. '</ProtectedString>' end
local function serBool(name, v) if type(v) ~= "boolean" then v = v and true or false end return '<bool name="' .. clean(name) .. '">' .. (v and "true" or "false") .. '</bool>' end
local function serInt(name, v) return '<int name="' .. clean(name) .. '">' .. string.format("%d", v) .. '</int>' end
local function serInt64(name, v) return '<int64 name="' .. clean(name) .. '">' .. string.format("%d", v) .. '</int64>' end
local function serFloat(name, v) return '<float name="' .. clean(name) .. '">' .. nm(v) .. '</float>' end
local function serDouble(name, v) return '<double name="' .. clean(name) .. '">' .. nm(v) .. '</double>' end
local function serNumber(name, v)
    if v == math.floor(v) and v >= -2147483648 and v <= 2147483647 then return serInt(name, v) end
    if v == math.floor(v) and math.abs(v) < 9007199254740992 then return serInt64(name, v) end
    return serDouble(name, v)
end
local function serVector2(name, v) return '<Vector2 name="' .. clean(name) .. '"><X>' .. nm(v.X) .. '</X><Y>' .. nm(v.Y) .. '</Y></Vector2>' end
local function serVector3(name, v) return '<Vector3 name="' .. clean(name) .. '"><X>' .. nm(v.X) .. '</X><Y>' .. nm(v.Y) .. '</Y><Z>' .. nm(v.Z) .. '</Z></Vector3>' end
local function serCFrame(name, v)
    local ok, r = pcall(function() return {v:GetComponents()} end)
    if not ok or not r then return nil end
    local s = '<CoordinateFrame name="' .. clean(name) .. '"><X>' .. nm(r[1]) .. '</X><Y>' .. nm(r[2]) .. '</Y><Z>' .. nm(r[3]) .. '</Z>'
    for i = 0, 2 do for j = 0, 2 do s = s .. '<R' .. i .. j .. '>' .. nm(r[i * 3 + j + 4]) .. '</R' .. i .. j .. '>' end end
    return s .. '</CoordinateFrame>'
end
local function serColor3(name, v) return '<Color3 name="' .. clean(name) .. '"><R>' .. nm(v.R) .. '</R><G>' .. nm(v.G) .. '</G><B>' .. nm(v.B) .. '</B></Color3>' end
local function serBrickColor(name, v) return '<BrickColor name="' .. clean(name) .. '">' .. tostring(v.Number) .. '</BrickColor>' end
local function serUDim(name, v) return '<UDim name="' .. clean(name) .. '"><S>' .. nm(v.Scale) .. '</S><O>' .. tostring(v.Offset) .. '</O></UDim>' end
local function serUDim2(name, v) return '<UDim2 name="' .. clean(name) .. '"><XS>' .. nm(v.X.Scale) .. '</XS><XO>' .. tostring(v.X.Offset) .. '</XO><YS>' .. nm(v.Y.Scale) .. '</YS><YO>' .. tostring(v.Y.Offset) .. '</YO></UDim2>' end
local function serRect(name, v) return '<Rect name="' .. clean(name) .. '"><min><X>' .. nm(v.Min.X) .. '</X><Y>' .. nm(v.Min.Y) .. '</Y></min><max><X>' .. nm(v.Max.X) .. '</X><Y>' .. nm(v.Max.Y) .. '</Y></max></Rect>' end
local function serNumberRange(name, v) return '<NumberRange name="' .. clean(name) .. '"><Min>' .. nm(v.Min) .. '</Min><Max>' .. nm(v.Max) .. '</Max></NumberRange>' end
local function serNumberSequence(name, v)
    local s = '<NumberSequence name="' .. clean(name) .. '">'
    for _, k in ipairs(v.Keypoints) do s = s .. '<Keypoint><Time>' .. nm(k.Time) .. '</Time><Value>' .. nm(k.Value) .. '</Value><Envelope>' .. nm(k.Envelope) .. '</Envelope></Keypoint>' end
    return s .. '</NumberSequence>'
end
local function serColorSequence(name, v)
    local s = '<ColorSequence name="' .. clean(name) .. '">'
    for _, k in ipairs(v.Keypoints) do s = s .. '<Keypoint><Time>' .. nm(k.Time) .. '</Time><Color><R>' .. nm(k.Value.R) .. '</R><G>' .. nm(k.Value.G) .. '</G><B>' .. nm(k.Value.B) .. '</B></Color></Keypoint>' end
    return s .. '</ColorSequence>'
end
local function serEnumItem(name, v)
    local ok, val = pcall(function() return v.Value end)
    if ok and type(val) == "number" then return '<token name="' .. clean(name) .. '">' .. tostring(val) .. '</token>' end
    return nil
end
local function serTokenNumber(name, v)
    if type(v) == "number" then return '<token name="' .. clean(name) .. '">' .. tostring(v) .. '</token>' end
    local ok, val = pcall(function() return v.Value end)
    if ok and type(val) == "number" then return '<token name="' .. clean(name) .. '">' .. tostring(val) .. '</token>' end
    return nil
end
local function serFaces(name, v)
    local f, base = 0, 1
    for _, k in ipairs({"Top","Bottom","Left","Right","Front","Back"}) do if v[k] then f = f + base end base = base * 2 end
    return '<token name="' .. clean(name) .. '">' .. f .. '</token>'
end
local function serAxes(name, v)
    local f, base = 0, 1
    for _, k in ipairs({"X","Y","Z"}) do if v[k] then f = f + base end base = base * 2 end
    return '<token name="' .. clean(name) .. '">' .. f .. '</token>'
end

local Walker = { refs = {}, refCount = 0, totalInst = 0 }

local function serInstance(name, v)
    if Walker.refs[v] then return '<Ref name="' .. clean(name) .. '">' .. Walker.refs[v] .. '</Ref>' end
    return nil
end
local function serPhysicalProps(name, v)
    local ok, body = pcall(function()
        return '<Density>' .. nm(v.Density) .. '</Density><Friction>' .. nm(v.Friction) .. '</Friction><Elasticity>' .. nm(v.Elasticity) .. '</Elasticity><FrictionWeight>' .. nm(v.FrictionWeight) .. '</FrictionWeight><ElasticityWeight>' .. nm(v.ElasticityWeight) .. '</ElasticityWeight>'
    end)
    if not ok or not body then return nil end
    return '<PhysicalProperties name="' .. clean(name) .. '">' .. body .. '</PhysicalProperties>'
end
local function serBinaryString(name, v)
    if type(v) ~= "string" then return nil end
    return '<BinaryString name="' .. clean(name) .. '">' .. b64(v) .. '</BinaryString>'
end
local function serRay(name, v)
    local ok, o, d = pcall(function() return v.Origin, v.Direction end)
    if not ok then return nil end
    return '<Ray name="' .. clean(name) .. '"><Origin><X>' .. nm(o.X) .. '</X><Y>' .. nm(o.Y) .. '</Y><Z>' .. nm(o.Z) .. '</Z></Origin><Direction><X>' .. nm(d.X) .. '</X><Y>' .. nm(d.Y) .. '</Y><Z>' .. nm(d.Z) .. '</Z></Direction></Ray>'
end
local function serFont(name, v)
    local parts = {}
    pcall(function() table.insert(parts, '<Family>' .. clean(v.Family) .. '</Family>') end)
    pcall(function() table.insert(parts, '<Weight>' .. tostring(v.Weight.Value) .. '</Weight>') end)
    pcall(function() table.insert(parts, '<Style>' .. tostring(v.Style.Value) .. '</Style>') end)
    if #parts == 0 then return nil end
    return '<Font name="' .. clean(name) .. '">' .. table.concat(parts) .. '</Font>'
end

local serByType = {
    string = serString, ProtectedString = serProtectedString, SharedString = serString,
    boolean = serBool, bool = serBool, number = serNumber, int = serInt, int64 = serInt64,
    float = serFloat, double = serDouble, Vector2 = serVector2, Vector3 = serVector3,
    CFrame = serCFrame, Color3 = serColor3, BrickColor = serBrickColor, UDim = serUDim,
    UDim2 = serUDim2, Rect = serRect, NumberRange = serNumberRange,
    NumberSequence = serNumberSequence, ColorSequence = serColorSequence,
    EnumItem = serEnumItem, Faces = serFaces, Axes = serAxes, Instance = serInstance,
    PhysicalProperties = serPhysicalProps, BinaryString = serBinaryString,
    Ray = serRay, Font = serFont, FontFace = serFont,
}


--[[

String class incase anything fails, we use this as a backup

]]



local specialPropHandlers = { Shape = serTokenNumber, Face = serTokenNumber, Material = serTokenNumber }

local function serializeProp(name, v)
    if v == nil then return nil end
    if shouldSkipProp(name) then return nil end
    if BINARY_PROPS[name] and type(v) == "string" then
        return '<BinaryString name="' .. clean(name) .. '">' .. b64(v) .. '</BinaryString>'
    end
    if type(v) == "boolean" then return serBool(name, v) end
    local special = specialPropHandlers[name]
    if special then local s = special(name, v) if s then return s end end
    local t = typeof(v)
    if t == "EnumItem" then return serEnumItem(name, v) end
    local fn = serByType[t]
    if not fn and type(v) == "boolean" then fn = serBool end
    if not fn then return nil end
    local ok, s = pcall(fn, name, v)
    if ok and s and s ~= "" then return s end
    return nil
end

local function propsViaGetProperties(inst)
    if not Fish.Options.UseGetProperties or not IO.getproperties then return nil end
    local ok, list = pcall(IO.getproperties, inst)
    if not ok or type(list) ~= "table" then return nil end
    local out = {}
    for _, k in ipairs(list) do
        if type(k) == "string" and not shouldSkipProp(k) and isPropValid(inst.ClassName, k) then
            table.insert(out, k)
        end
    end
    return out
end

local defaultCache = {}
local function getDefault(className)
    if defaultCache[className] ~= nil then return defaultCache[className] end
    local ok, inst = pcall(Instance.new, className)
    if not ok or not inst then defaultCache[className] = false return false end
    defaultCache[className] = inst
    return inst
end

local function valuesEqual(a, b)
    if a == b then return true end
    local ta, tb = typeof(a), typeof(b)
    if ta ~= tb then return false end
    if ta == "number" then return math.abs(a - b) < 1e-6 end
    if ta == "string" or ta == "boolean" then return a == b end
    local ok1, s1 = pcall(tostring, a)
    local ok2, s2 = pcall(tostring, b)
    if ok1 and ok2 then return s1 == s2 end
    return false
end

local function modelIsCharacter(m)
    if not m then return false end
    local ok, player = pcall(function() return Players:GetPlayerFromCharacter(m) end)
    if ok and player then return true end
    local ok2, hum = pcall(function() return m:FindFirstChildOfClass("Humanoid") end)
    if ok2 and hum then
        local ok3, hrp = pcall(function() return m:FindFirstChild("HumanoidRootPart") end)
        if ok3 and hrp then return true end
    end
    return false
end

local function isCharacter(inst, opts, charRefs)
    if not opts.StripCharacters then return false end
    if not inst then return false end
    if charRefs[inst] then return true end
    if not inst:IsA("Model") then
        local okp, charModel = pcall(function() return inst:FindFirstAncestorWhichIsA("Model") end)
        if okp and charModel and charRefs[charModel] then
            charRefs[inst] = true
            return true
        end
        if CHARACTER_CLASSES[inst.ClassName] then
            local okp2, parent = pcall(function() return inst.Parent end)
            if okp2 and parent and parent:IsA("Model") and modelIsCharacter(parent) then
                charRefs[inst] = true
                return true
            end
        end
        return false
    end
    if modelIsCharacter(inst) then
        charRefs[inst] = true
        local okd, desc = pcall(function() return inst:GetDescendants() end)
        if okd and desc then for _, d in ipairs(desc) do charRefs[d] = true end end
        return true
    end
    return false
end

local function nameIsCore(inst, opts, coreRefs)
    if not opts.StripCoreScripts then return false end
    local ok, n = pcall(function() return inst.Name end)
    if not ok or not n then return false end
    if CORE_SCRIPT_NAMES[n] then coreRefs[inst] = true return true end
    return false
end

local function ancestorIsCore(inst, opts, coreRefs)
    if not opts.StripCoreScripts then return false end
    local okA, ancestor = pcall(function()
        return inst:FindFirstAncestorOfClass("PlayerScripts")
            or inst:FindFirstAncestorOfClass("PlayerGui")
            or inst:FindFirstAncestorOfClass("StarterPlayer")
    end)
    if okA and ancestor then return true end
    local cur = inst.Parent
    for _ = 1, 30 do
        if not cur then return false end
        if coreRefs[cur] then return true end
        if cur == Players or cur == game then return false end
        cur = cur.Parent
    end
    return false
end

local function keepInst(inst, opts, charRefs, coreRefs)
    if isCharacter(inst, opts, charRefs) then return false end
    if nameIsCore(inst, opts, coreRefs) then return false end
    if ancestorIsCore(inst, opts, coreRefs) then return false end
    if inst:IsA("Lighting") then return true end
    if opts.IgnoreNotArchivable then
        local ok, ar = pcall(function() return inst.Archivable end)
        if ok and ar == false then return false end
    end
    local parent = inst.Parent
    if parent and charRefs[parent] then return false end
    if parent and coreRefs[parent] then return false end
    if parent == game and SKIP_SVC[inst.ClassName] then return false end
    return true
end

local function walkRef(root, d, opts, refs, charRefs, coreRefs)
    if d > opts.Depth then return end
    if refs[root] then return end
    Walker.refCount = Walker.refCount + 1
    refs[root] = "RBX" .. Walker.refCount
    if Walker.refCount % 500 == 0 then
        setStatusText("Saving game.. scanning " .. Walker.refCount)
        ConWrite("[Fishilizer] scanning " .. Walker.refCount .. " refs")
        task.wait()
    end
    local ok, kids = pcall(function() return root:GetChildren() end)
    if not ok or not kids then return end
    for _, c in ipairs(kids) do
        if keepInst(c, opts, charRefs, coreRefs) then walkRef(c, d + 1, opts, refs, charRefs, coreRefs) end
    end
end

local function readProp(inst, name)
    local ok, v = pcall(function() return inst[name] end)
    if ok and v ~= nil then return v end
    return nil
end


-- Terrain doesn't save if your executor has low UNC but atleast it tries
local function readTerrainVoxels(terrain, res)
    if not terrain then return nil end
    res = res or Fish.Options.TerrainResolution or 8
    local ok_size, size = pcall(function() return terrain.Size end)
    if not ok_size or not size then return nil end
    local cap = Fish.Options.TerrainCellCap or 4194304
    local adjRes = res
    local cellsX, cellsY, cellsZ
    while true do
        cellsX = math.max(1, math.floor(size.X / adjRes + 0.5))
        cellsY = math.max(1, math.floor(size.Y / adjRes + 0.5))
        cellsZ = math.max(1, math.floor(size.Z / adjRes + 0.5))
        if cellsX * cellsY * cellsZ <= cap then break end
        adjRes = adjRes * 2
        if adjRes > 1024 then
            log("Terrain too large to capture even at res 1024, skipping.")
            return nil
        end
    end
    if adjRes ~= res then
        log("Terrain resolution auto-raised from " .. res .. " to " .. adjRes .. " to stay under cell cap.")
        setStatusText("Saving game.. terrain downsampled to res " .. adjRes)
        task.wait()
    end
    local half = size * 0.5
    local CHUNK = 32
    local out = {}
    out[#out+1] = string.pack("<I4", 4)
    out[#out+1] = string.pack("<I4", 0)
    out[#out+1] = string.pack("<I4", cellsX)
    out[#out+1] = string.pack("<I4", cellsY)
    out[#out+1] = string.pack("<I4", cellsZ)
    local matParts = {}
    local occParts = {}
    local chunkIdx = 0
    for cx = 0, cellsX - 1, CHUNK do
        for cy = 0, cellsY - 1, CHUNK do
            for cz = 0, cellsZ - 1, CHUNK do
                local ex = math.min(cx + CHUNK, cellsX)
                local ey = math.min(cy + CHUNK, cellsY)
                local ez = math.min(cz + CHUNK, cellsZ)
                local minV = Vector3.new(-half.X + cx * adjRes, -half.Y + cy * adjRes, -half.Z + cz * adjRes)
                local maxV = Vector3.new(-half.X + ex * adjRes, -half.Y + ey * adjRes, -half.Z + ez * adjRes)
                local region = Region3.new(minV, maxV)
                local ok, m, o = pcall(function()
                    return terrain:ReadVoxels(region, adjRes)
                end)
                if ok and m and o then
                    for x = 1, #m do
                        local mx = m[x]
                        local ox = o[x]
                        local xm = {}
                        local xo = {}
                        for y = 1, #mx do
                            local mxy = mx[y]
                            local oxy = ox[y]
                            for z = 1, #mxy do
                                local mv = mxy[z]
                                local ov = oxy[z]
                                xm[#xm+1] = string.char(mv.Value)
                                xo[#xo+1] = string.char(math.floor(ov * 255 + 0.5))
                            end
                        end
                        matParts[#matParts+1] = table.concat(xm)
                        occParts[#occParts+1] = table.concat(xo)
                    end
                end
                chunkIdx = chunkIdx + 1
                if chunkIdx % 8 == 0 then
                    setStatusText("Saving game.. terrain chunk " .. chunkIdx)
                    ConWrite("[Fishilizer] terrain chunk " .. chunkIdx)
                    task.wait()
                end
            end
        end
    end
    out[#out+1] = table.concat(matParts)
    out[#out+1] = table.concat(occParts)
    return table.concat(out)
end

local function emitContentProp(buf, inst, pad, propName)
    local raw = readProp(inst, propName)
    if raw == nil then return end
    local uri = extractUri(raw)
    if not uri then return end
    table.insert(buf, pad .. '    ' .. serContentTag(propName, uri))
end

local function emitSingleProp(buf, inst, pad, seen, k, opts, defaultInst)
    if seen[k] or shouldSkipProp(k) then return end
    if Fish.Options.APIProperties and not isPropValid(inst.ClassName, k) then return end
    if isRealContent(k) then
        seen[k] = true
        emitContentProp(buf, inst, pad, k)
    else
        local v = readProp(inst, k)
        if v ~= nil then
            seen[k] = true
            local skip = false
            if defaultInst then
                local okd, dv = pcall(function() return defaultInst[k] end)
                if okd and dv ~= nil then
                    local ok1, eq = pcall(valuesEqual, v, dv)
                    if ok1 and eq then skip = true end
                end
            end
            if not skip then
                local s = serializeProp(k, v)
                if s then table.insert(buf, pad .. '    ' .. s) end
            end
        end
    end
end

local function emitPropsFromList(buf, inst, pad, seen, list, opts)
    local cls = inst.ClassName
    local defaultInst = opts.IgnoreDefaultProps and getDefault(cls) or nil
    for _, k in ipairs(list) do
        emitSingleProp(buf, inst, pad, seen, k, opts, defaultInst)
    end
end

local function emitAttributesAndTags(buf, inst, pad, opts)
    if opts.EmitAttributes then
        local ok, attrs = pcall(function() return inst:GetAttributes() end)
        if ok and type(attrs) == "table" and next(attrs) ~= nil then
            local success, encoded = pcall(function()
                return HttpService:JSONEncode(attrs)
            end)
            if success and encoded and #encoded > 0 then
                table.insert(buf, pad .. '    <BinaryString name="AttributesSerialize">' .. b64(encoded) .. '</BinaryString>')
            end
        end
    end
    if opts.EmitTags then
        local ok, encoded = pcall(encodeTags, inst)
        if ok and encoded then
            table.insert(buf, pad .. '    <BinaryString name="Tags">' .. b64(encoded) .. '</BinaryString>')
        end
    end
end

local function shouldEmitInMode(cls, mode)
    if mode == "full" then return true end
    if mode == "scripts" then return cls == "Script" or cls == "LocalScript" or cls == "ModuleScript" end
    if mode == "models" then return cls ~= "Script" and cls ~= "LocalScript" and cls ~= "ModuleScript" end
    return true
end

local function emitInst(buf, inst, d, opts, decompileCache, refs, totalRefs)
    local ref = refs[inst]
    if not ref then return end
    local pad = string.rep("  ", d)
    local cls = inst.ClassName

    if not shouldEmitInMode(cls, opts.Mode) then
        local okc, kids = pcall(function() return inst:GetChildren() end)
        if okc and kids then for _, c in ipairs(kids) do if refs[c] then emitInst(buf, c, d, opts, decompileCache, refs, totalRefs) end end end
        return
    end

    Walker.totalInst = Walker.totalInst + 1
    bumpStatus("Saving", Walker.totalInst, totalRefs)

    table.insert(buf, pad .. '<Item class="' .. clean(cls) .. '" referent="' .. ref .. '">')
    table.insert(buf, pad .. '  <Properties>')

    local seen = {}
    local specific = INSTANCE_SPECIFIC[cls]
    if specific then emitPropsFromList(buf, inst, pad, seen, specific, opts) end

    emitPropsFromList(buf, inst, pad, seen, CRITICAL_PROPS, opts)

    local dynProps = propsViaGetProperties(inst)
    if dynProps then
        for _, k in ipairs(dynProps) do
            emitSingleProp(buf, inst, pad, seen, k, opts, nil)
        end
    end

    if not seen.Name then
        local name = readProp(inst, "Name")
        if name then
            if opts.Anonymous then
                local ok, p = pcall(function() return Players:GetPlayerFromCharacter(inst) end)
                if ok and p then name = "Player_" .. tostring(p.UserId) end
            end
            table.insert(buf, pad .. '    <string name="Name">' .. clean(name) .. '</string>')
        end
    end

    emitAttributesAndTags(buf, inst, pad, opts)

    if cls == "Script" then
        local src = tostring(DATA.server_script_placeholder or "")
        table.insert(buf, pad .. '    <ProtectedString name="Source">' .. clean(src) .. '</ProtectedString>')
    elseif cls == "LocalScript" or cls == "ModuleScript" then
        local src = readProp(inst, "Source")
        if decompileCache and decompileCache[inst] then src = decompileCache[inst] end
        if (not src or src == "") and opts.Decompile and opts._decompileFn then
            local okd, decoded = pcall(opts._decompileFn, inst)
            if okd and type(decoded) == "string" and decoded ~= "" then src = decoded end
        end
        if (not src or src == "") and opts.SaveBytecode and opts._bytecodeFn then
            local okb, bc = pcall(opts._bytecodeFn, inst)
            if okb and type(bc) == "string" and bc ~= "" then src = b64(bc) end
        end
        if not src or src == "" then
            src = "-- [Fishilizer] No source recovered for " .. tostring(cls) .. " \"" .. tostring(inst.Name) .. "\""
        end
        table.insert(buf, pad .. '    <ProtectedString name="Source">' .. clean(src) .. '</ProtectedString>')
    end

    if cls == "UnionOperation" or cls == "IntersectOperation" or cls == "NegateOperation" or cls == "PartOperation" then
        for _, bp in ipairs({"ChildData", "PhysicsData", "PhysicalConfigData"}) do
            if not seen[bp] then
                local raw = readProp(inst, bp)
                if raw and type(raw) == "string" then
                    table.insert(buf, pad .. '    <BinaryString name="' .. bp .. '">' .. b64(raw) .. '</BinaryString>')
                end
            end
        end
    end

    if cls == "Terrain" then
        if not seen.SmoothGrid then
            local sg = readTerrainVoxels(inst, opts.TerrainResolution)
            if sg and #sg > 0 then
                table.insert(buf, pad .. '    <BinaryString name="SmoothGrid">' .. b64(sg) .. '</BinaryString>')
            else
                log("Terrain voxel capture returned nothing.")
            end
        end
        local mc = readProp(inst, "MaterialColors")
        if mc and type(mc) == "string" and #mc > 0 and not seen.MaterialColors then
            table.insert(buf, pad .. '    <BinaryString name="MaterialColors">' .. b64(mc) .. '</BinaryString>')
        end
    end

    table.insert(buf, pad .. '  </Properties>')

    local okc, kids = pcall(function() return inst:GetChildren() end)
    if okc and kids then for _, c in ipairs(kids) do if refs[c] then emitInst(buf, c, d + 1, opts, decompileCache, refs, totalRefs) end end end

    table.insert(buf, pad .. '</Item>')
end

local function placeName()
    local pid = game.PlaceId
    local name
    local ok, n = pcall(function() return game.Name end)
    if ok and n and n ~= "" and n ~= "Game" and n:lower() ~= "ugc" then name = n end
    if not name then
        local okp, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(pid) end)
        if okp and info and info.Name and info.Name ~= "" then name = info.Name end
    end
    if not name or name == "" then name = "Place_" .. tostring(pid) end
    name = name:gsub("[^%w_%-%s]", ""):gsub("%s+", "_"):gsub("_+", "_")
    if #name > 80 then name = name:sub(1, 80) end
    if name == "" then name = "Place_" .. tostring(pid) end
    return name
end

local function buildReadmeSource()
    local tpl = DATA.readme_template
    if type(tpl) ~= "string" or tpl == "" then
        tpl = "-- Fishilizer v" .. Fish.VERSION .. "\nGame saved with Fishilizer\n"
    end
    local subs = {
        VERSION = Fish.VERSION,
        PLACE_NAME = placeName(),
        PLACE_ID = tostring(game.PlaceId),
        JOB_ID = tostring(game.JobId or "N/A"),
        MODE = tostring(Fish.Options.Mode),
        DECOMPILE = tostring(Fish.Options.Decompile),
        TERRAIN_RESOLUTION = tostring(Fish.Options.TerrainResolution),
        DEPTH = tostring(Fish.Options.Depth),
        TIMESTAMP = os.date("!%Y-%m-%d %H:%M:%S"),
    }
    local out = tpl:gsub("{{(%w+)}}", function(k) return subs[k] or "" end)
    if out:sub(1, 11) ~= "--[[\n __ " then
        out = "--[[\n" .. Fish.Banner .. "]]\n\n" .. out
    end
    return out
end

local function buildReadmeXML(depth)
    local pad = string.rep("  ", depth)
    local src = buildReadmeSource()
    return table.concat({
        pad .. '<Item class="Script" referent="RBX_README">',
        pad .. '  <Properties>',
        pad .. '    <string name="Name">README</string>',
        pad .. '    <bool name="Disabled">false</bool>',
        pad .. '    <ProtectedString name="Source">' .. clean(src) .. '</ProtectedString>',
        pad .. '  </Properties>',
        pad .. '</Item>',
    }, "\n")
end

local function mergeOptions(userOpts)
    local merged = {}
    for k, v in pairs(Fish.Options) do merged[k] = v end
    if userOpts then for k, v in pairs(userOpts) do merged[k] = v end end
    merged._decompileFn = Fish._decompileFn
    merged._bytecodeFn = Fish._bytecodeFn
    if merged.ReadMe then
        merged._readmeXMLFn = buildReadmeXML
    else
        merged._readmeXMLFn = nil
    end
    return merged
end

local _pendingRestore = {}

local function moveBackpackToStarter()
    _pendingRestore = {}
    local lp = Players.LocalPlayer
    if not lp then return end
    local bp = lp:FindFirstChildOfClass("Backpack")
    if not bp then return end
    local sp = game:GetService("StarterPack")
    if not sp then return end
    local okL, tools = pcall(function() return bp:GetChildren() end)
    if not okL or not tools then return end
    for _, tool in ipairs(tools) do
        if tool:IsA("Tool") then
            if not sp:FindFirstChild(tool.Name) then
                local origParent = tool.Parent
                local okMove = pcall(function() tool.Parent = sp end)
                if okMove then
                    table.insert(_pendingRestore, {tool = tool, orig = origParent})
                end
            end
        end
    end
end

local function restoreBackpack()
    for i = #_pendingRestore, 1, -1 do
        local entry = _pendingRestore[i]
        pcall(function()
            if entry.tool and entry.tool.Parent == game:GetService("StarterPack") then
                entry.tool.Parent = entry.orig
            end
        end)
    end
    _pendingRestore = {}
end

local function ensureOutFolder()
    local out = tostring(Fish.Options.OUT or "Fishilizer")
    if IO.makefolder and IO.isfolder then
        local okF, exists = pcall(IO.isfolder, out)
        if not okF or not exists then pcall(IO.makefolder, out) end
    end
    return out
end

local Sink = {}
Sink.__index = Sink

function Sink.new(path, chunk)
    local s = setmetatable({}, Sink)
    s.path = path
    s.part = path .. ".part"
    s.chunk = chunk or 262144
    s.buf = {}
    s.size = 0
    s.total = 0
    s.streaming = (IO.appendfile ~= nil and IO.writefile ~= nil)
    return s
end

function Sink:write(str)
    if type(str) ~= "string" or #str == 0 then return end
    self.buf[#self.buf + 1] = str
    self.size = self.size + #str
    self.total = self.total + #str
    if self.streaming and self.size >= self.chunk then
        local blob = table.concat(self.buf)
        pcall(IO.appendfile, self.part, blob)
        self.buf = {}
        self.size = 0
        ConWrite("[Fishilizer] wrote " .. tostring(self.total) .. "b")
    end
end

function Sink:finish(finalPath)
    if #self.buf > 0 then
        local blob = table.concat(self.buf)
        self.buf = {}
        self.size = 0
        if self.streaming then
            pcall(IO.appendfile, self.part, blob)
        else
            self.streaming = false
            self.cached = (self.cached or "") .. blob
        end
    end
    if self.streaming then
        local okR, whole = pcall(IO.readfile, self.part)
        if okR and type(whole) == "string" then
            if IO.writefile then
                local okW = pcall(IO.writefile, finalPath, whole)
                if okW and IO.delfile then pcall(IO.delfile, self.part) end
                if okW then
                    log("Streamed to file: " .. finalPath .. " (" .. #whole .. " bytes)")
                    return true
                end
            end
        end
        log("Stream finish failed, kept .part at " .. self.part)
        return false
    end
    if IO.writefile and self.cached then
        local okW = pcall(IO.writefile, finalPath, self.cached)
        if okW then
            log("Wrote: " .. finalPath .. " (" .. #self.cached .. " bytes)")
            return true
        end
    end
    return false
end

function Fish.Init()
    loadFromAPI()
    Fish._decompileFn = lunauxDecompile
    Fish._bytecodeFn = resolveBytecode()
    if Fish.Options.FetchDocs or Fish.Options.APIProperties then
        local ok, data = pcall(Fish.FetchClasses)
        if not ok then log("API dump fetch failed: " .. tostring(data)) end
    end
    if Fish.Options.UseReflectionService then
        buildReflectionProps()
    end
    return Fish
end

function Fish.Save(instance, name, userOpts)
    if not _dataLoaded then loadFromAPI() end
    local opts = mergeOptions(userOpts)
    IO.writefile = IO.writefile or resolveIO("writefile")
    IO.readfile = IO.readfile or resolveIO("readfile")
    IO.makefolder = IO.makefolder or resolveIO("makefolder")
    IO.isfolder = IO.isfolder or resolveIO("isfolder")
    IO.isfile = IO.isfile or resolveIO("isfile")
    IO.delfile = IO.delfile or resolveIO("delfile")
    IO.appendfile = IO.appendfile or resolveIO("appendfile")
    IO.getproperties = IO.getproperties or resolveIO("getproperties")

    if not opts.Callback and not opts.Clipboard and not IO.writefile then
        log("writefile unavailable")
        notify("Fishilizer: FAILED", "Executor missing writefile", 10)
        return nil
    end

    _statusAccum = 0
    _lastConsolePct = -1
    ensureOutFolder()
    log("Starting save (" .. tostring(opts.Mode) .. ")")
    setStatusText("Saving game..")

    if opts.KillAllScripts then
        pcall(function()
            for _, s in ipairs(game:GetDescendants()) do
                if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then
                    pcall(function() s.Disabled = true end)
                end
            end
        end)
    end

    log("Serializing...")
    task.wait()

    local t0 = tick()
    Walker.refs = {}
    Walker.refCount = 0
    Walker.totalInst = 0

    local charRefs = {}
    local coreRefs = {}
    local refs = {}
    Walker.refs = refs

    if opts.RemovePlayerCharacters then
        local okp, plist = pcall(function() return Players:GetPlayers() end)
        if okp and plist then
            for _, p in ipairs(plist) do
                local okc, char = pcall(function() return p.Character end)
                if okc and char then
                    charRefs[char] = true
                    local okd, desc = pcall(function() return char:GetDescendants() end)
                    if okd and desc then for _, d in ipairs(desc) do charRefs[d] = true end end
                end
            end
        end
    end

    local roots = {}
    if type(instance) == "table" then
        for _, r in ipairs(instance) do if typeof(r) == "Instance" then table.insert(roots, r) end end
    elseif typeof(instance) == "Instance" then
        table.insert(roots, instance)
    end

    if #roots == 0 then
        notify("Fishilizer: FAILED", "No valid root instance", 10)
        return nil
    end

    local didMoveBackpack = false
    if opts.IncludeBackpack then
        local okM = pcall(moveBackpackToStarter)
        didMoveBackpack = okM
    end

    local okSave, result = pcall(function()
        for _, root in ipairs(roots) do
            if root == game then
                local ok0, kids0 = pcall(function() return game:GetChildren() end)
                if ok0 and kids0 then
                    for _, svc in ipairs(kids0) do
                        if keepInst(svc, opts, charRefs, coreRefs) then walkRef(svc, 1, opts, refs, charRefs, coreRefs) end
                    end
                end
            else
                if keepInst(root, opts, charRefs, coreRefs) then walkRef(root, 1, opts, refs, charRefs, coreRefs) end
            end
        end

        log("Walked " .. Walker.refCount .. " instances")
        setStatusText("Saving game.. decompiling")
        ConWrite("[Fishilizer] Decompiling")
        task.wait()

        local buf = {}
        local decompileCache = {}

        if opts.Decompile and Fish._decompileFn then
            local scriptTotal = 0
            for inst in pairs(refs) do
                local cls = inst.ClassName
                if cls == "LocalScript" or cls == "ModuleScript" then
                    local existing = readProp(inst, "Source")
                    if not existing or existing == "" then scriptTotal = scriptTotal + 1 end
                end
            end
            local scriptCount = 0
            local iterCount = 0
            for inst in pairs(refs) do
                iterCount = iterCount + 1
                local cls = inst.ClassName
                if cls == "LocalScript" or cls == "ModuleScript" then
                    local existing = readProp(inst, "Source")
                    if not existing or existing == "" then
                        scriptCount = scriptCount + 1
                        setStatusText("Decompiling " .. scriptCount .. "/" .. scriptTotal)
                        if scriptCount % 5 == 0 or scriptCount == scriptTotal then
                            ConWrite("[Fishilizer] Decompiling " .. scriptCount .. "/" .. scriptTotal)
                        end
                        local ok, res = pcall(Fish._decompileFn, inst)
                        if ok and type(res) == "string" and res ~= "" then decompileCache[inst] = res end
                        task.wait()
                    end
                end
                if iterCount % 100 == 0 then task.wait() end
            end
        end

        setStatusText("Saving game.. writing")
        ConWrite("[Fishilizer] Writing")

        table.insert(buf, '<?xml version="1.0" encoding="utf-8"?>')
        table.insert(buf, '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">')
-- Another list of APIS i personally use alot for XML related stuff
        local finalName = name or placeName()
        local fname = finalName .. ".rbxlx"
        local outFolder = ensureOutFolder()
        local primaryPath = outFolder .. "/" .. fname

        local sink = nil
        if opts.StreamToFile and IO.appendfile and IO.writefile then
            sink = Sink.new(primaryPath, opts.StreamChunk)
            sink:write(table.concat(buf, "\n") .. "\n")
            buf = {}
        end

        local readmeEmitted = false
        for _, root in ipairs(roots) do
            if root == game then
                local ok0, kids0 = pcall(function() return game:GetChildren() end)
                if ok0 and kids0 then
                    for _, svc in ipairs(kids0) do
                        if refs[svc] then
                            emitInst(buf, svc, 1, opts, decompileCache, refs, Walker.refCount)
                            if opts._readmeXMLFn and not readmeEmitted and svc:IsA("Lighting") then
                                local readmeXml = opts._readmeXMLFn(1)
                                if readmeXml then
                                    table.insert(buf, readmeXml)
                                    readmeEmitted = true
                                end
                            end
                            if sink and #buf > 0 then
                                sink:write(table.concat(buf, "\n") .. "\n")
                                buf = {}
                            end
                        end
                    end
                end
            else
                if refs[root] then emitInst(buf, root, 1, opts, decompileCache, refs, Walker.refCount) end
                if sink and #buf > 0 then
                    sink:write(table.concat(buf, "\n") .. "\n")
                    buf = {}
                end
            end
        end

        if opts._readmeXMLFn and not readmeEmitted then
            local readmeXml = opts._readmeXMLFn(1)
            if readmeXml then
                table.insert(buf, readmeXml)
                readmeEmitted = true
            end
        end

        table.insert(buf, '</roblox>')

        local xml
        if sink then
            sink:write(table.concat(buf, "\n"))
            buf = {}
            ConWrite("[Fishilizer] Finishing write")
            local okFinish = sink:finish(primaryPath)
            if okFinish then
                xml = primaryPath
            end
        else
            xml = table.concat(buf, "\n")
        end

        local elapsed = tick() - t0

        if sink and xml == primaryPath then
            log("XML streamed to " .. primaryPath .. " in " .. string.format("%.2fs", elapsed))
        else
            log("XML: " .. #xml .. " bytes, " .. Walker.totalInst .. " items emitted in " .. string.format("%.2fs", elapsed))
        end

        if opts.Callback and type(opts.Callback) == "function" then
            pcall(opts.Callback, xml)
            setStatusText("Saved!")
            ConWrite("[Fishilizer] Saved!")
            return xml
        end

        if opts.Clipboard then
            pcall(function() if IO.setclipboard then IO.setclipboard(xml) end end)
            setStatusText("Saved!")
            ConWrite("[Fishilizer] Saved!")
            return xml
        end

        local paths = {}
        if opts.FilePath then table.insert(paths, opts.FilePath) end
        table.insert(paths, primaryPath)
        table.insert(paths, fname)

        local wrote = (sink ~= nil and xml == primaryPath)
        if not wrote then
            for _, path in ipairs(paths) do
                if IO.isfile and IO.delfile then
                    local okI, exists = pcall(IO.isfile, path)
                    if okI and exists and not opts.AvoidFileOverwrite then pcall(IO.delfile, path) end
                end
                local ok, err = pcall(IO.writefile, path, xml)
                if ok then
                    log("Wrote: " .. path .. " (" .. #xml .. " bytes)")
                    wrote = true
                    break
                else
                    log("Write fail " .. path .. ": " .. tostring(err))
                end
            end
        end

        if not wrote then
            setStatusText("Save failed (writefile)")
            ConWrite("[Fishilizer] Save failed")
            return xml
        end

        setStatusText("Saved!")
        ConWrite("[Fishilizer] Saved!")
        task.wait(0.4)
        return xml
    end)

    if didMoveBackpack then
        restoreBackpack()
    end

    flushLog()

    if not okSave then
        log("Save error: " .. tostring(result))
        setStatusText("Save failed: " .. tostring(result):sub(1, 60))
        ConWrite("[Fishilizer] Save error: " .. tostring(result))
        return nil
    end

    if Fish.Options.CloseConsole then closeConsoleWithVulns() end

    return result
end

function Fish.SavePlace(name, userOpts)
    return Fish.Save(game, name, userOpts)
end

function Fish.SaveInstance(instance, name, userOpts)
    local merged = userOpts or {}
    merged.Mode = merged.Mode or "full"
    return Fish.Save(instance, name, merged)
end

function Fish.SaveScripts(instance, name, userOpts)
    local merged = userOpts or {}
    merged.Mode = "scripts"
    merged.Decompile = true
    return Fish.Save(instance, name, merged)
end

function Fish.SaveModels(instance, name, userOpts)
    local merged = userOpts or {}
    merged.Mode = "models"
    merged.Decompile = false
    return Fish.Save(instance, name, merged)
end

Fish.LoadData = loadFromAPI
Fish.Data = DATA
Fish.ValidPropsForClass = apiClassProps
Fish.EncodeBase64 = b64
Fish.ExtractUri = extractUri
Fish.SerializeProp = serializeProp
Fish.EncodeAttributes = encodeAttributes
Fish.EncodeTags = encodeTags --tags
Fish.DecompileScript = lunauxDecompile --scripts
Fish.HttpPost = httpPost --http (obv)
Fish.ReadTerrainVoxels = readTerrainVoxels --useless shit
Fish.Print = ConWrite
Fish.DeepClone = function(t)
    if type(t) ~= "table" then return t end
    local n = {}
    for k, v in pairs(t) do n[k] = Fish.DeepClone(v) end
    return n
end


-- Let's you use SavePlace() (of course Konstant Uses that 🤬)
-- Let's you use Fishilizer()

local genv = (getgenv and getgenv()) or _G or _ENV
local _fetching = false

local function fetchLatest(kind, a, b)
    if _fetching then
        Fish.Init()
        if kind == "instance" then return Fish.SaveInstance(a, b) end
        return Fish.SavePlace(a, b)
    end
    _fetching = true
    pcall(function()
        local lua = game:HttpGetAsync(Fish.Bootstrap.scriptURL)
        local fn = loadstring(lua)
        if type(fn) == "function" then fn() end
    end)
    _fetching = false
    local g = (getgenv and getgenv()) or _G
    if g and g.Fish and type(g.Fish.SavePlace) == "function" then
        if kind == "instance" then
            return g.Fish.SaveInstance(a, b)
        end
        return g.Fish.SavePlace(a, b)
    end
    Fish.Init()
    if kind == "instance" then return Fish.SaveInstance(a, b) end
    return Fish.SavePlace(a, b)
end

genv.fishilizer = function(name, opts)
    return fetchLatest("place", name, opts)
end

genv.fishilize = function(name, opts)
    return fetchLatest("place", name, opts)
end

genv.saveplace = function(name, opts)
    return fetchLatest("place", name, opts)
end

genv.dumpgame = function(name, opts)
    return fetchLatest("place", name, opts)
end

genv.fishsave = function(name, opts)
    return fetchLatest("place", name, opts)
end

genv.fetchplace = function(name, opts)
    return fetchLatest("place", name, opts)
end

genv.serialize = function(name, opts)
    return fetchLatest("place", name, opts)
end

genv.saveinstance = function(inst, name, opts)
    return fetchLatest("instance", inst, name, opts)
end

genv.Fish = Fish
genv.Fishilizer = Fish

-- Thank you claude for adding useless underscores

if genv and type(genv.FISHILIZER_CONFIG) == "table" then
    for k, v in pairs(genv.FISHILIZER_CONFIG) do
        Fish.Options[k] = v
    end
end

if Fish.Options.Console then
    ConInit()
    if Fish.Options.AutoRun then
        task.spawn(function()
            task.wait(1)
            fetchLatest("place")
        end)
    end
end

return Fish
