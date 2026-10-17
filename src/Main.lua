-- Main.lua
-- Public API entrypoints and orchestration.

local function init()
    -- Minimal Init placeholder. The full implementation lives in the single-file runtime.
    return Fish
end

local function saveGame(name, opts)
    if Fish.Save then return Fish.Save(game, name, opts) end
    error("Fish.Save is not implemented in modular source yet")
end

local function saveScripts(inst, name, opts)
    local config = opts or {}
    config.Mode = "scripts"
    config.Decompile = true
    if Fish.Save then return Fish.Save(inst or game, name, config) end
    error("Fish.Save is not implemented in modular source yet")
end

local function saveModels(inst, name, opts)
    local config = opts or {}
    config.Mode = "models"
    config.Decompile = false
    if Fish.Save then return Fish.Save(inst or game, name, config) end
    error("Fish.Save is not implemented in modular source yet")
end

Fish.Init = init
Fish.SaveGame = saveGame
Fish.SaveScripts = saveScripts
Fish.SaveModels = saveModels

return Fish
