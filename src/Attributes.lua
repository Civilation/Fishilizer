-- Attributes.lua
-- Attribute and tag serialization utilities.

local function u32(n) return string.pack("<I4", n) end
local function f32(n) return string.pack("<f", n) end
local function f64(n) return string.pack("<d", n) end
local function i32(n) return string.pack("<i4", n) end
local function wstr(s) return u32(#s) .. s end

local ATTR_TYPE_IDS = {
    string = 0x02,
    boolean = 0x03,
    number = 0x04,
    UDim = 0x0D,
    UDim2 = 0x10,
    Vector2 = 0x12,
    Vector3 = 0x13,
    CFrame = 0x10,
    Color3 = 0x1A,
    BrickColor = 0x1E,
    NumberRange = 0x1F,
    NumberSequence = 0x20,
    ColorSequence = 0x21,
}

local function attrWriteValue(t, v)
    if t == "string" then return wstr(v) end
    if t == "boolean" then return string.char(v and 1 or 0) end
    if t == "number" then return f64(v) end
    if t == "Vector2" then return f32(v.X) .. f32(v.Y) end
    if t == "Vector3" then return f32(v.X) .. f32(v.Y) .. f32(v.Z) end
    if t == "UDim" then return f32(v.Scale) .. i32(v.Offset) end
    if t == "UDim2" then return f32(v.X.Scale) .. i32(v.X.Offset) .. f32(v.Y.Scale) .. i32(v.Y.Offset) end
    if t == "Color3" then return f32(v.R) .. f32(v.G) .. f32(v.B) end
    if t == "BrickColor" then return u32(v.Number) end
    if t == "CFrame" then
        local c = { v:GetComponents() }
        local out = ""
        for i = 1, 12 do out = out .. f32(c[i]) end
        return out
    end
    if t == "NumberRange" then return f32(v.Min) .. f32(v.Max) end
    if t == "Rect" then return f32(v.Min.X) .. f32(v.Min.Y) .. f32(v.Max.X) .. f32(v.Max.Y) end
    if t == "NumberSequence" then
        local out = u32(#v.Keypoints)
        for _, k in ipairs(v.Keypoints) do
            out = out .. f32(k.Time) .. f32(k.Value) .. f32(k.Envelope)
        end
        return out
    end
    if t == "ColorSequence" then
        local out = u32(#v.Keypoints)
        for _, k in ipairs(v.Keypoints) do
            out = out .. f32(k.Time) .. f32(k.Value.R) .. f32(k.Value.G) .. f32(k.Value.B)
        end
        return out
    end
    return nil
end

local function encodeAttributes(inst)
    local ok, attrs = pcall(function() return inst:GetAttributes() end)
    if not ok or not attrs then return nil end
    local names = {}
    for k in pairs(attrs) do table.insert(names, k) end
    if #names == 0 then return nil end
    table.sort(names)

    local out = u32(#names)
    for _, name in ipairs(names) do
        local v = attrs[name]
        local t = typeof(v)
        local typeId = ATTR_TYPE_IDS[t]
        if typeId then
            out = out .. wstr(name) .. string.char(typeId)
            local body = attrWriteValue(t, v)
            if body then out = out .. body else out = out .. string.char(0) end
        end
    end
    return out
end

local function encodeTags(inst)
    local ok, tags = pcall(function() return CollectionService:GetTags(inst) end)
    if not ok or not tags or #tags == 0 then return nil end
    local out = u32(#tags)
    for _, tag in ipairs(tags) do out = out .. wstr(tag) end
    return out
end

Fish.encodeAttributes = encodeAttributes
Fish.encodeTags = encodeTags
Fish.ATTR_TYPE_IDS = ATTR_TYPE_IDS

return Fish
