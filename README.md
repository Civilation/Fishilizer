
<div align="center">

<img src="https://files.catbox.moe/5uumgz.png" alt="Fishilizer Logo" width="150" />

# Fishilizer

**A lightweight Roblox place serializer written in Lua.**

Save your place, preserve the details, and bring it into Roblox Studio.

[![Documentation](https://img.shields.io/badge/Documentation-GitHub_Pages-blue?style=flat-square)](https://fishilizer.github.io/)
[![Version](https://img.shields.io/badge/Version-10.8.1-brightgreen?style=flat-square)](https://fishilizer.github.io/)
[![Discord](https://img.shields.io/badge/Discord-Join%20the%20community-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/GZDXBMjndT)

</div>

---

> [!IMPORTANT]
> **A quick heads-up:** Fishilizer is an independent, community-made project. It is not affiliated with, endorsed by, or officially connected to Roblox Corporation.

## What is Fishilizer?

Saving a Roblox place isn't always as simple as copying a few instances. Some properties contain data that ordinary serializers don't handle properly, and things like terrain, CSG, attributes, and runtime tools can be tricky to preserve.

That's what Fishilizer is built for.

Fishilizer reads the DataModel of a running Roblox instance and serializes it into an `.rbxlx` file that can be opened in Roblox Studio. When the environment supports it, Fishilizer uses `getproperties()` to discover available properties instead of relying entirely on a predefined list.

The goal is simple: **save as much of the original place as the environment allows, without making the process unnecessarily complicated.**

> [!NOTE]
> Fishilizer is still under active development. Results can vary depending on the environment, the size of the place, and which properties are accessible. Always check the exported file in Studio.

## Preview

Here's a look at Fishilizer's output:

![Fishilizer Preview](https://files.catbox.moe/7si6e9.PNG)

## What can it do?

- **Property discovery** — Uses `getproperties()` when available, with fallback property maps for environments that don't support it.
- **Attributes and tags** — Serializes instance attributes and CollectionService tags into native binary payloads.
- **Terrain and CSG** — Handles data such as `SmoothGrid`, `ChildData`, and `PhysicsData` where the environment exposes it.
- **Tool preservation** — Can temporarily move runtime tools into `StarterPack` during serialization to help preserve hotbar icons and avoid duplicate tools.
- **Script extraction** — Uses available decompilation functions to retrieve script source when possible, with a fallback for bytecode when source isn't available.
- **Property map updates** — Can optionally download API information to help account for newer classes and properties.
- **Reflection support** — Uses live engine reflection when supported instead of depending exclusively on external API dumps.

> [!TIP]
> No two Roblox environments are exactly alike. If a property or instance doesn't serialize correctly, try testing a smaller section of the place first. This makes it much easier to narrow down what's causing the issue.

## Getting started

Fishilizer can run automatically or be loaded as a module when you want more control over what gets saved.

### Automatic mode

The default behavior is to initialize Fishilizer and start its configured save process.

```lua
loadstring(game:HttpGetAsync("https://fishilizer.github.io/Fishilizer.lua"))()
```

### Manual mode

Want to save only certain objects instead of the entire place? Disable automatic execution before loading the module, then call the functions you need.

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

-- Save one specific instance
Fish.Save(workspace.MyModel, "SingleModel")
```

> [!TIP]
> If you're just testing things out, start with a single model or a small part of the DataModel. It's a lot easier to verify the output before attempting a full-place export.

## Configuration

You can change Fishilizer's behavior by setting `FISHILIZER_CONFIG` before loading the script.

For example, this configuration disables decompilation and enables player-character removal:

```lua
getgenv().FISHILIZER_CONFIG = {
    Decompile = false,
    RemovePlayerCharacters = true,
    Mode = "full"
}

loadstring(game:HttpGetAsync("https://fishilizer.github.io/Fishilizer.lua"))()
```

The example above uses the configuration options shown here. For additional details about supported options, check the project documentation.

## A few things to keep in mind

> [!WARNING]
> **Keep backups of anything important.** Serialization is not guaranteed to reproduce every instance or property perfectly. Check the exported file before relying on it.

- **Large places:** Saving a large DataModel can take time or run into environment limitations.
- **Restricted properties:** Some engine data may not be accessible to the environment running Fishilizer.
- **Script source:** Decompiled output may be incomplete or unavailable, particularly for obfuscated scripts.
- **Compatibility:** Roblox updates and changes to the execution environment can affect serialization results.

> [!CAUTION]
> Only use Fishilizer on places and content you own or have permission to inspect. Respect the rights of game creators and any applicable platform rules.

## Troubleshooting

**The save doesn't finish**

Try a smaller section of the place first. Large places and inaccessible properties can make serialization more difficult.

**Some objects are missing properties**

Check whether the running environment exposes those properties. Not every engine property is readable or serializable in every environment.

**Script source wasn't recovered**

Source extraction depends on the decompiler available to the environment. Disabling decompilation also means Fishilizer won't attempt to recover source through that process.

**Something else went wrong**

If you've found a reproducible issue, gather the relevant details and report it through the project's community channels.

## Credits and disclaimer

Fishilizer is a community project intended for educational use, serialization research, and learning more about Roblox's instance and property systems.

Decompilation relies on the capabilities of the environment and any external tools it provides. Fishilizer cannot guarantee successful source recovery or perfect reconstruction of every place.

Roblox and Roblox Studio are trademarks of Roblox Corporation. Fishilizer is an independent project and is not an official Roblox product.

---

<div align="center">

**Made with ❤️ by Garfield Cat Presents**

*Thanks for checking out Fishilizer.*

</div>
