
<div align="center">

<img src="https://files.catbox.moe/5uumgz.png" alt="Fishilizer Logo" width="150" />

# Fishilizer

**An accurate, lightweight Roblox place serializer written in pure Lua.**

[![Documentation](https://img.shields.io/badge/Docs-GitHub_Pages-blue?style=flat-square)](https://fishilizer.github.io/)
[![Discord](https://img.shields.io/discord/YOUR_SERVER_ID?color=5865F2&label=Garfield%20Cat%20Presents&logo=discord&logoColor=white&style=flat-square)](https://discord.gg/GZDXBMjndT)
[![Version](https://img.shields.io/badge/Version-10.8.1-brightgreen?style=flat-square)]()

</div>

---

## Overview

Fishilizer extracts the entire DataModel from a running Roblox instance and writes it out to a Studio-loadable `.rbxlx` format. It is built to handle content that standard serializers fail to save, specifically terrain, CSG, native binary blobs, and runtime tool properties.

Unlike basic dumpers, Fishilizer reads the engine directly through reflection (`getproperties`) when available, falling back to an extensive hardcoded property map for older environments. It serializes attributes and tags as native `rbx-dom` binary payloads, ensuring a byte-identical reconstruction when the file is opened in Roblox Studio.

> ⚠️ **Note:** Fishilizer is still in active development. While it handles most games perfectly, you may run into issues with massive games or those with aggressive client-side anti-cheats. If a game fails to save, please report it in the Discord!

## Preview

![Fishilizer decompiled game open in Studio](https://files.catbox.moe/7si6e9.PNG)

## Features

- **Total Property Coverage:** Calls `getproperties()` to enumerate everything the engine exposes.
- **Native Attributes & Tags:** Encodes `:GetAttributes()` and `CollectionService:GetTags()` into real binary blobs.
- **CSG & Terrain:** Preserves `ChildData`, `PhysicsData`, and `SmoothGrid` as native BinaryString fields.
- **Backpack Preservation:** Temporarily moves runtime tools into `StarterPack` during the save process, keeping hotbar icons intact and preventing duplicates.
- **Decompilation Support:** Extracts script source via environment-provided decompilers or falls back to base64 bytecode.
- **Live Class Maps:** Optional API dump download to automatically generate property maps for newly released instances.
- **ReflectionService Integration:** Uses the live engine to query property lists instead of relying solely on external JSON dumps.

## Usage

Fishilizer is designed to be used as a module. By default, it will auto-run and save the game upon loading, but you can disable this to control the flow programmatically.

### Automatic Execution

```lua
loadstring(game:HttpGetAsync("https://fishilizer.github.io/Fishilizer.lua"))()
```

### Manual Control

If you want to save specific things (like only scripts or only models), you can disable the auto-run and call the functions directly:

```lua
getgenv().FISHILIZER_NO_AUTORUN = true
local Fish = loadstring(game:HttpGetAsync("https://fishilizer.github.io/Fishilizer.lua"))()
Fish.Init()

-- Save the whole game
Fish.SavePlace("MyPlace")

-- Save only LocalScripts and ModuleScripts
Fish.SaveScripts(game, "ScriptsOnly")

-- Save only models and parts
Fish.SaveModels(game, "ModelsOnly")

-- Save a specific instance
Fish.Save(workspace.MyModel, "SingleModel")
```

## Options

You can override the default options globally before loading the script. For example, to disable decompilation and skip player characters:

```lua
getgenv().FISHILIZER_CONFIG = {
    Decompile = false,
    RemovePlayerCharacters = true,
    Mode = "full"
}
loadstring(game:HttpGetAsync("https://fishilizer.github.io/Fishilizer.lua"))()
```

## Disclaimer

**Decompiler:** Fishilizer uses external environments or LunaUX for decompilation. We are not responsible if the decompiler fails or breaks on heavily obfuscated scripts.

**Data Loss:** Always keep backups of your own games. Do not use this to overwrite existing important files.

**Usage:** This tool is intended for educational purposes, reverse engineering, and studying game development.

<p align="center">Made with ❤️ by Garfield Cat Presents</p>
