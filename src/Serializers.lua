-- Serializers.lua
-- Core property and value serialization helpers.

local function serString(name, v)
    if type(v) ~= "string" then return nil end
    return '<string name="' .. Fish.clean(name) .. '">' .. Fish.clean(v) .. '</string>'
end

local function serProtectedString(name, v)
    if type(v) ~= "string" then v = "" end
    return '<ProtectedString name="' .. Fish.clean(name) .. '">' .. Fish.clean(v) .. '</ProtectedString>'
end

local function serBool(name, v)
    if type(v) ~= "boolean" then v = v and true or false end
    return '<bool name="' .. Fish.clean(name) .. '">' .. (v and "true" or "false") .. '</bool>'
end

local function serInt(name, v)
    return '<int name="' .. Fish.clean(name) .. '">' .. string.format("%d", v) .. '</int>'
end

local function serInt64(name, v)
    return '<int64 name="' .. Fish.clean(name) .. '">' .. string.format("%d", v) .. '</int64>'
end

local function serFloat(name, v)
    return '<float name="' .. Fish.clean(name) .. '">' .. Fish.nm(v) .. '</float>'
end

local function serDouble(name, v)
    return '<double name="' .. Fish.clean(name) .. '">' .. Fish.nm(v) .. '</double>'
end

local function serNumber(name, v)
    if v == math.floor(v) and v >= -2147483648 and v <= 2147483647 then return serInt(name, v) end
    if v == math.floor(v) and math.abs(v) < 9007199254740992 then return serInt64(name, v) end
    return serDouble(name, v)
end

local function serVector2(name, v)
    return '<Vector2 name="' .. Fish.clean(name) .. '"><X>' .. Fish.nm(v.X) .. '</X><Y>' .. Fish.nm(v.Y) .. '</Y></Vector2>'
end

local function serVector3(name, v)
    return '<Vector3 name="' .. Fish.clean(name) .. '"><X>' .. Fish.nm(v.X) .. '</X><Y>' .. Fish.nm(v.Y) .. '</Y><Z>' .. Fish.nm(v.Z) .. '</Z></Vector3>'
end

local function serCFrame(name, v)
    local ok, r = pcall(function() return { v:GetComponents() } end)
    if not ok or not r then return nil end
    local s = '<CoordinateFrame name="' .. Fish.clean(name) .. '"><X>' .. Fish.nm(r[1]) .. '</X><Y>' .. Fish.nm(r[2]) .. '</Y><Z>' .. Fish.nm(r[3]) .. '</Z>'
    for i = 0, 2 do
        for j = 0, 2 do
            s = s .. '<R' .. i .. j .. '>' .. Fish.nm(r[i * 3 + j + 4]) .. '</R' .. i .. j .. '>'
        end
    end
    return s .. '</CoordinateFrame>'
end

local function serColor3(name, v)
    return '<Color3 name="' .. Fish.clean(name) .. '"><R>' .. Fish.nm(v.R) .. '</R><G>' .. Fish.nm(v.G) .. '</G><B>' .. Fish.nm(v.B) .. '</B></Color3>'
end

local function serBrickColor(name, v)
    return '<BrickColor name="' .. Fish.clean(name) .. '">' .. tostring(v.Number) .. '</BrickColor>'
end

local function serUDim(name, v)
    return '<UDim name="' .. Fish.clean(name) .. '"><S>' .. Fish.nm(v.Scale) .. '</S><O>' .. tostring(v.Offset) .. '</O></UDim>'
end

local function serUDim2(name, v)
    return '<UDim2 name="' .. Fish.clean(name) .. '"><XS>' .. Fish.nm(v.X.Scale) .. '</XS><XO>' .. tostring(v.X.Offset) .. '</XO><YS>' .. Fish.nm(v.Y.Scale) .. '</YS><YO>' .. tostring(v.Y.Offset) .. '</YO></UDim2>'
end

local function serRect(name, v)
    return '<Rect name="' .. Fish.clean(name) .. '"><min><X>' .. Fish.nm(v.Min.X) .. '</X><Y>' .. Fish.nm(v.Min.Y) .. '</Y></min><max><X>' .. Fish.nm(v.Max.X) .. '</X><Y>' .. Fish.nm(v.Max.Y) .. '</Y></max></Rect>'
end

local function serNumberRange(name, v)
    return '<NumberRange name="' .. Fish.clean(name) .. '"><Min>' .. Fish.nm(v.Min) .. '</Min><Max>' .. Fish.nm(v.Max) .. '</Max></NumberRange>'
end

local function serNumberSequence(name, v)
    local s = '<NumberSequence name="' .. Fish.clean(name) .. '">'
    for _, k in ipairs(v.Keypoints) do
        s = s .. '<Keypoint><Time>' .. Fish.nm(k.Time) .. '</Time><Value>' .. Fish.nm(k.Value) .. '</Value><Envelope>' .. Fish.nm(k.Envelope) .. '</Envelope></Keypoint>'
    end
    return s .. '</NumberSequence>'
end

local function serColorSequence(name, v)
    local s = '<ColorSequence name="' .. Fish.clean(name) .. '">'
    for _, k in ipairs(v.Keypoints) do
        s = s .. '<Keypoint><Time>' .. Fish.nm(k.Time) .. '</Time><Color><R>' .. Fish.nm(k.Value.R) .. '</R><G>' .. Fish.nm(k.Value.G) .. '</G><B>' .. Fish.nm(k.Value.B) .. '</B></Color></Keypoint>'
    end
    return s .. '</ColorSequence>'
end

local function serEnumItem(name, v)
    local ok, val = pcall(function() return v.Value end)
    if ok and type(val) == "number" then return '<token name="' .. Fish.clean(name) .. '">' .. tostring(val) .. '</token>' end
    return nil
end

local function serTokenNumber(name, v)
    if type(v) == "number" then return '<token name="' .. Fish.clean(name) .. '">' .. tostring(v) .. '</token>' end
    local ok, val = pcall(function() return v.Value end)
    if ok and type(val) == "number" then return '<token name="' .. Fish.clean(name) .. '">' .. tostring(val) .. '</token>' end
    return nil
end

local function serFaces(name, v)
    local f, base = 0, 1
    for _, k in ipairs({ "Top", "Bottom", "Left", "Right", "Front", "Back" }) do
        if v[k] then f = f + base end
        base = base * 2
    end
    return '<token name="' .. Fish.clean(name) .. '">' .. f .. '</token>'
end

local function serAxes(name, v)
    local f, base = 0, 1
    for _, k in ipairs({ "X", "Y", "Z" }) do
        if v[k] then f = f + base end
        base = base * 2
    end
    return '<token name="' .. Fish.clean(name) .. '">' .. f .. '</token>'
end

local function serPhysicalProps(name, v)
    local ok, body = pcall(function()
        return '<Density>' .. Fish.nm(v.Density) .. '</Density><Friction>' .. Fish.nm(v.Friction) .. '</Friction><Elasticity>' .. Fish.nm(v.Elasticity) .. '</Elasticity><FrictionWeight>' .. Fish.nm(v.FrictionWeight) .. '</FrictionWeight><ElasticityWeight>' .. Fish.nm(v.ElasticityWeight) .. '</ElasticityWeight>'
    end)
    if not ok or not body then return nil end
    return '<PhysicalProperties name="' .. Fish.clean(name) .. '">' .. body .. '</PhysicalProperties>'
end

local function serBinaryString(name, v)
    if type(v) ~= "string" then return nil end
    local ok, s = pcall(Fish.b64, v)
    if ok and s then return '<BinaryString name="' .. Fish.clean(name) .. '">' .. s .. '</BinaryString>' end
    return nil
end

local function serRay(name, v)
    local ok, o, d = pcall(function() return v.Origin, v.Direction end)
    if not ok then return nil end
    return '<Ray name="' .. Fish.clean(name) .. '"><Origin><X>' .. Fish.nm(o.X) .. '</X><Y>' .. Fish.nm(o.Y) .. '</Y><Z>' .. Fish.nm(o.Z) .. '</Z></Origin><Direction><X>' .. Fish.nm(d.X) .. '</X><Y>' .. Fish.nm(d.Y) .. '</Y><Z>' .. Fish.nm(d.Z) .. '</Z></Direction></Ray>'
end

local function serFont(name, v)
    local parts = {}
    pcall(function() table.insert(parts, '<Family>' .. Fish.clean(v.Family) .. '</Family>') end)
    pcall(function() table.insert(parts, '<Weight>' .. tostring(v.Weight.Value) .. '</Weight>') end)
    pcall(function() table.insert(parts, '<Style>' .. tostring(v.Style.Value) .. '</Style>') end)
    if #parts == 0 then return nil end
    return '<Font name="' .. Fish.clean(name) .. '">' .. table.concat(parts) .. '</Font>'
end

local serByType = {
    string = serString,
    ProtectedString = serProtectedString,
    SharedString = serString,
    boolean = serBool,
    bool = serBool,
    number = serNumber,
    int = serInt,
    int64 = serInt64,
    float = serFloat,
    double = serDouble,
    Vector2 = serVector2,
    Vector3 = serVector3,
    CFrame = serCFrame,
    Color3 = serColor3,
    BrickColor = serBrickColor,
    UDim = serUDim,
    UDim2 = serUDim2,
    Rect = serRect,
    NumberRange = serNumberRange,
    NumberSequence = serNumberSequence,
    ColorSequence = serColorSequence,
    EnumItem = serEnumItem,
    Faces = serFaces,
    Axes = serAxes,
    Instance = function(name, v) return nil end,
    PhysicalProperties = serPhysicalProps,
    BinaryString = serBinaryString,
    Ray = serRay,
    Font = serFont,
    FontFace = serFont,
}

local specialPropHandlers = {
    Shape = serTokenNumber,
    Face = serTokenNumber,
    Material = serTokenNumber,
}

local function serializeProp(name, v)
    if v == nil then return nil end
    local t = typeof(v)
    if t == "boolean" then return serBool(name, v) end
    local special = specialPropHandlers[name]
    if special then
        local s = special(name, v)
        if s then return s end
    end
    if t == "EnumItem" then return serEnumItem(name, v) end
    local fn = serByType[t]
    if fn then
        local ok, s = pcall(fn, name, v)
        if ok and s and s ~= "" then return s end
    end
    return nil
end

local function propsViaGetProperties(inst)
    if not Fish.Options.UseGetProperties or not Fish.IO.getproperties then return nil end
    local ok, list = pcall(Fish.IO.getproperties, inst)
    if not ok or type(list) ~= "table" then return nil end
    local out = {}
    for _, k in ipairs(list) do
        if type(k) == "string" then table.insert(out, k) end
    end
    return out
end

Fish.serByType = serByType
Fish.serializeProp = serializeProp
Fish.propsViaGetProperties = propsViaGetProperties

return Fish
