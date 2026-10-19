
<div align="center">

<img src="https://files.catbox.moe/5uumgz.png" alt="Fishilizer Logo" width="150" />

# Fishilizer

**A lightweight Roblox place serializer written in Lua.**

Save your place, preserve the details, and bring it into Roblox Studio.

[![Documentation](https://img.shields.io/badge/Documentation-Read%20the%20Docs-blue?style=flat-square)](https://fishilizer.github.io/#api)
[![Options](https://img.shields.io/badge/Configuration-Options-orange?style=flat-square)](https://fishilizer.github.io/#options)
[![Version](https://img.shields.io/badge/Version-10.8.1-brightgreen?style=flat-square)](https://fishilizer.github.io/)
[![Discord](https://img.shields.io/badge/Discord-Community-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/GZDXBMjndT)

</div>

---

## Overview

Saving a Roblox place isn't always as simple as copying a few instances. Some properties contain data that ordinary serializers struggle with, and things like terrain, CSG, attributes, and runtime tools can be tricky to preserve.

That's where Fishilizer comes in.

Fishilizer reads the DataModel of a running Roblox instance and serializes it into an `.rbxlx` file that can be opened in Roblox Studio. When supported by the environment, it uses `getproperties()` to discover available properties instead of relying entirely on a predefined list.

The idea is to make serialization as complete as possible while keeping the tool lightweight and straightforward to use.

> [!NOTE]
> Fishilizer is actively developed, so compatibility and results may vary between environments and Roblox updates.

## Preview

![Fishilizer Preview](https://files.catbox.moe/7si6e9.PNG)

## Features

- **Property discovery** — Uses `getproperties()` when available, with fallback property maps for environments that don't support it.
- **Attributes and tags** — Serializes instance attributes and CollectionService tags into native binary payloads.
- **Terrain and CSG** — Handles data such as `SmoothGrid`, `ChildData`, and `PhysicsData` where accessible.
- **Tool preservation** — Can temporarily move runtime tools into `StarterPack` during serialization to help preserve hotbar icons and avoid duplicates.
- **Script extraction** — Uses available decompilation functions to retrieve script source when possible, with a fallback for bytecode.
- **Property map updates** — Can optionally download API information to help account for newer classes and properties.
- **Reflection support** — Uses live engine reflection when supported instead of depending exclusively on external API dumps.

> [!TIP]
> If you're troubleshooting a failed save, try serializing a smaller model first. It's an easy way to narrow down whether a particular instance or property is causing trouble.

## Getting started

Fishilizer can run automatically or be loaded as a module when you want more control over the save process.

### Automatic execution

```lua
loadstring(game:HttpGetAsync("https://fishilizer.github.io/Fishilizer.lua"))()
```

### Manual control

To control what gets saved, disable automatic execution before loading Fishilizer and call the functions you need.

```lua
getgenv().FISHILIZER_NO_AUTORUN = true

local Fish = loadstring(
    game:HttpGetAsync("https://fishilizer.github.io/Fishilizer.lua")
)()

Fish.Init()

-- Save the entire place
Fish.SavePlace("MyPlace")

-- Save scripts
Fish.SaveScripts(game, "ScriptsOnly")

-- Save models and parts
Fish.SaveModels(game, "ModelsOnly")

-- Save a specific instance
Fish.Save(workspace.MyModel, "SingleModel")
```

## Configuration

Fishilizer's behavior can be customized through `FISHILIZER_CONFIG`. Set your options before loading the script.

For example, to disable decompilation and remove player characters from the export:

```lua
getgenv().FISHILIZER_CONFIG = {
    Decompile = false,
    RemovePlayerCharacters = true,
    Mode = "full"
}

loadstring(game:HttpGetAsync("https://fishilizer.github.io/Fishilizer.lua"))()
```

For the complete list of configuration options and their descriptions, check the [Options documentation](https://fishilizer.github.io/#options).

## Documentation

Need more details about how something works? The documentation covers the available API and configuration options.

- [API Reference](https://fishilizer.github.io/#api) — Functions and their usage.
- [Configuration Options](https://fishilizer.github.io/#options) — Available settings and customization.
- [Project Website](https://fishilizer.github.io/) — Main documentation page.

## Troubleshooting

> [!TIP]
> When reporting a bug, include what you were trying to save, what happened, and any error messages you received. Reproducible examples make issues much easier to investigate.

**The save doesn't finish**

Large places or inaccessible properties can cause problems. Try a smaller section first to narrow things down.

**Some properties are missing**

Not every environment exposes every engine property. Results depend on what Fishilizer can access while it runs.

**Script source wasn't recovered**

Source extraction depends on the decompiler available in the environment. Some scripts may not be recoverable, particularly when their source is unavailable or heavily obfuscated.

**Something else went wrong**

Check the documentation for relevant settings and function details. If the problem persists, share the issue with the community.

## Disclaimer

Fishilizer is an independent project created for serialization, reverse-engineering research, and studying Roblox game development. It is not an official Roblox product.

Decompiler functionality depends on external tools and the execution environment. Successful decompilation and perfect reconstruction of every instance are not guaranteed.

Always keep backups of important files when working with serialized places.

---

<div align="center">

**Made with ❤️ by Garfield Cat Presents**

*Thanks for checking out Fishilizer!*

</div>
