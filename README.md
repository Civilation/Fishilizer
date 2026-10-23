
<div align="center">

<img src="https://files.catbox.moe/5uumgz.png" alt="Fishilizer Logo" width="150" />

# Fishilizer

**A Roblox place serializer written in Lua.**

Fishilizer saves Roblox instances and their properties to `.rbxlx` files that can be opened in Roblox Studio.

[![Repository](https://img.shields.io/badge/GitHub-Repository-181717?style=flat-square&logo=github)](https://github.com/Civilation/Fishilizer)
[![Source](https://img.shields.io/badge/Source-Lua-blue?style=flat-square)](https://github.com/Civilation/Fishilizer/blob/main/Fishilizer.lua)
[![Version](https://img.shields.io/badge/Version-10.8.1-brightgreen?style=flat-square)](https://github.com/Civilation/Fishilizer)
[![Discord](https://img.shields.io/badge/Discord-Community-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/GZDXBMjndT)
[![Cash App](https://img.shields.io/badge/Cash%20App-Support-00C244?style=flat-square&logo=cashapp&logoColor=white)](https://cash.app/$aeroglass)

[GitHub Repository](https://github.com/Civilation/Fishilizer) · [Source Code](https://github.com/Civilation/Fishilizer/blob/main/Fishilizer.lua) · [Raw Lua Source](https://raw.githubusercontent.com/Civilation/Fishilizer/main/Fishilizer.lua)

</div>

## Overview

Fishilizer reads the DataModel of a running Roblox game and saves the instances it can access. It supports property discovery, terrain data, CSG data, attributes, tags, and script extraction when the environment allows it.

You can save an entire place, export scripts separately, save models without scripts, or choose a specific instance to save.

Fishilizer uses Roblox API information, fallback property maps, and engine reflection when available to find properties to save. Some properties need special handling because they contain binary data or values that cannot be written as ordinary XML.

The goal is to save as much of the original place as possible. Some properties and data may not be accessible, so exported files might not be exact copies of the original.

## Preview

![Fishilizer Preview](https://files.catbox.moe/7si6e9.PNG)

## Features

- **Property discovery:** Uses `getproperties()` when available, with fallback property maps for other environments.
- **Roblox API dump:** Retrieves class and property information to help with saving.
- **Reflection support:** Uses engine reflection when available.
- **Terrain:** Attempts to save terrain materials and occupancy data through voxel capture.
- **CSG data:** Supports accessible binary properties such as `ChildData` and `PhysicsData`.
- **Attributes:** Can save instance attributes.
- **CollectionService tags:** Can save tags attached to instances.
- **Script extraction:** Attempts to recover script source when the environment supports it.
- **Bytecode fallback:** Can save bytecode when enabled and available.
- **Export modes:** Supports full-place, script-only, and model-only exports.
- **Instance filtering:** Provides options for excluding player characters, core scripts, and other instances.
- **Tool preservation:** Can temporarily move eligible backpack tools into `StarterPack` while saving.
- **Output options:** Supports file output and other methods available in the environment.
- **Remote data:** Loads serializer data and uses fallback data when needed.
- **Progress display:** Shows save progress when supported.

## Getting started

### Requirements

Fishilizer depends on the functions available in the environment where it runs.

Depending on the features you use, you may need:

- HTTP access to download Fishilizer and its supporting data.
- `loadstring` support.
- File-writing functions such as `writefile`.
- `getproperties()` or other property discovery functions.
- Compatible decompilation or bytecode functions for script recovery.

Not every environment supports all of these functions. Features that depend on unavailable functions may be skipped or produce incomplete results.

### Automatic execution

Load Fishilizer with the following code:

```lua
loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Civilation/Fishilizer/main/Fishilizer.lua"
))()
```

This loads Fishilizer and runs its default save behavior.

### Manual execution

To control what gets saved, disable automatic execution before loading Fishilizer.

```lua
getgenv().FISHILIZER_NO_AUTORUN = true

local Fish = loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Civilation/Fishilizer/main/Fishilizer.lua"
))()

Fish.Init()

-- Save the entire place
Fish.SavePlace("MyPlace")

-- Save scripts
Fish.SaveScripts(game, "ScriptsOnly")

-- Save non-script instances
Fish.SaveModels(game, "ModelsOnly")

-- Save a specific instance
Fish.Save(workspace.MyModel, "SingleModel")
```

Saving to disk requires an environment with the appropriate file-writing functions.

## Export modes

Fishilizer has three main export modes.

| Mode | Description |
| --- | --- |
| `full` | Saves supported instances and properties, including scripts. |
| `scripts` | Saves script instances such as `Script`, `LocalScript`, and `ModuleScript`. |
| `models` | Saves non-script instances. |

The `SaveScripts()` and `SaveModels()` functions select their respective modes automatically.

### Save a specific model

```lua
Fish.Save(workspace.MyModel, "MyModel")
```

### Save scripts from a model

```lua
Fish.SaveScripts(workspace.MyModel, "MyScripts")
```

### Save non-script instances from a folder

```lua
Fish.SaveModels(workspace.MyFolder, "MyModels")
```

### Save the entire place

```lua
Fish.SavePlace("MyPlace")
```

The resulting file depends on the selected options and the functions available in the environment.

## API reference

The main functions available through the `Fish` table include:

| Function | Description |
| --- | --- |
| `Fish.Init()` | Loads supporting data and prepares Fishilizer for use. |
| `Fish.Save(instance, name?, opts?)` | Saves an instance or an array of instances. |
| `Fish.SavePlace(name?, opts?)` | Saves the current place. |
| `Fish.SaveInstance(instance, name?, opts?)` | Saves a specific instance. |
| `Fish.SaveScripts(instance, name?, opts?)` | Saves scripts. |
| `Fish.SaveModels(instance, name?, opts?)` | Saves non-script instances. |
| `Fish.FetchClasses(cacheFile?)` | Fetches or loads cached Roblox API information. |
| `Fish.LoadData()` | Loads supporting serializer data. |
| `Fish.ApplyAPIDump(data)` | Reads API dump information for property discovery. |

Fishilizer also registers convenience aliases in the execution environment:

| Alias | Description |
| --- | --- |
| `fishilizer(name?, opts?)` | Saves the current place. |
| `saveplace(name?, opts?)` | Saves the current place. |
| `dumpgame(name?, opts?)` | Saves the current place. |
| `fishsave(name?, opts?)` | Saves the current place. |
| `fetchplace(name?, opts?)` | Saves the current place. |
| `serialize(name?, opts?)` | Saves the current place. |
| `saveinstance(inst, name?, opts?)` | Saves a specific instance. |

For additional information, see the [Fishilizer GitHub repository](https://github.com/Civilation/Fishilizer).

## Configuration

Configuration can be set through `FISHILIZER_CONFIG` before loading the script.

### Example

```lua
getgenv().FISHILIZER_CONFIG = {
    Mode = "full",

    Decompile = false,
    SaveBytecode = false,

    RemovePlayerCharacters = true,
    StripCharacters = true,
    StripCoreScripts = true,

    IncludeBackpack = true,
    EmitTags = true,
    EmitAttributes = true,

    AvoidFileOverwrite = true,
    Notify = true,
    ShowStatus = true
}

loadstring(game:HttpGetAsync(
    "https://raw.githubusercontent.com/Civilation/Fishilizer/main/Fishilizer.lua"
))()
```

This example turns off decompilation, enables attribute and tag saving, and excludes player characters.

### Per-save options

You can also pass options directly to a save function.

```lua
Fish.SavePlace("MyPlace", {
    Mode = "full",
    Decompile = false,
    EmitAttributes = true,
    EmitTags = true,
    RemovePlayerCharacters = true
})
```

This changes the settings for one export without changing the global configuration.

### Common options

| Option | Default | Description |
| --- | --- | --- |
| `Mode` | `"full"` | Selects the export mode. |
| `Decompile` | `true` | Attempts to recover script source when supported. |
| `SaveBytecode` | `false` | Enables bytecode fallback where available. |
| `UseGetProperties` | `true` | Uses `getproperties()` when available. |
| `APIProperties` | `true` | Uses API property information when saving. |
| `UseReflectionService` | `true` | Uses engine reflection when available. |
| `FetchDocs` | `true` | Enables API dump fetching. |
| `EmitTags` | `true` | Includes supported CollectionService tag data. |
| `EmitAttributes` | `false` | Includes instance attributes. |
| `IncludeBackpack` | `true` | Includes eligible backpack tools in the save process. |
| `RemovePlayerCharacters` | `true` | Excludes player characters. |
| `IgnoreDefaultProps` | `true` | Skips properties matching their defaults. |
| `IgnoreNotArchivable` | `true` | Applies archivable-related filtering. |
| `TerrainResolution` | `8` | Sets terrain voxel resolution. |
| `TerrainCellCap` | `4194304` | Sets the maximum number of terrain cells to capture. |
| `Depth` | `100` | Sets the maximum traversal depth. |
| `OUT` | `"Fishilizer"` | Sets the default output folder name. |
| `AvoidFileOverwrite` | `true` | Avoids intentionally overwriting existing files. |
| `ShowStatus` | `true` | Shows the progress interface when available. |
| `Notify` | `true` | Enables supported notifications. |

These are the main options and their documented defaults. Other options may be available in the current version.

See the [Fishilizer GitHub repository](https://github.com/Civilation/Fishilizer) for project information and source code.

> [!WARNING]
> `KillAllScripts` is an available option that defaults to `false`. Enabling it can disable accessible script instances during saving and affect the running game.

## How it works

Fishilizer goes through the selected instances and builds an XML file from the data it can access.

1. Loads configuration and supporting property data.
2. Gets property information from API dumps, fallback maps, and reflection when available.
3. Goes through the selected instances and applies the configured filters.
4. Collects supported properties, attributes, tags, and content data.
5. Attempts to capture terrain voxels and CSG binary data.
6. Attempts script source recovery when enabled and supported.
7. Builds the `.rbxlx` XML file.
8. Writes the result using the selected output method.

Some properties need special handling because they contain binary data or values that cannot be written as ordinary XML.

Supporting API data includes class maps, property lists, binary properties, and other information used by Fishilizer.

## Limitations

Fishilizer cannot save every Roblox place perfectly. The result depends on which instances and properties the environment can access.

### Script source

Server `Script` instances receive placeholder source in the current implementation. Their original source should not be expected in the exported file.

`LocalScript` and `ModuleScript` source recovery depends on available source access and decompilation functions. Bytecode fallback does not guarantee that the original source can be recovered.

### Terrain

Terrain saving depends on accessible voxel APIs. Large regions may exceed the configured cell limit, and some terrain data may not be available.

Adjust `TerrainResolution` and `TerrainCellCap` when working with large terrain regions.

### Properties

Some properties may be inaccessible, unsupported, or filtered out. Roblox updates can introduce new classes and properties that the current property maps do not cover.

### Runtime state

Not all runtime data can be restored from an exported file. Engine-managed values, unavailable assets, server-only data, and unsupported instance types can prevent an exact copy.

### File output

File-writing and clipboard functions depend on the environment. Successfully creating the XML does not always mean the file was saved correctly.

## Troubleshooting

### The save fails

- Check the execution output for errors.
- Make sure the required functions are available.
- Check that file writing is supported.
- Try saving a smaller model to find out which instances might be causing the problem.

### Properties are missing

- Check whether `getproperties()` is available.
- Check the API property settings.
- Review which properties are filtered by your options.
- Update the supporting API data if it is outdated.

### Terrain is incomplete

- Check whether voxel-reading functions are available.
- Try saving a smaller terrain region.
- Review `TerrainResolution` and `TerrainCellCap`.

### Scripts are missing source

- Check whether `Decompile` is enabled.
- Check whether the environment has compatible decompilation functions.
- Remember that the current implementation does not recover the original source of server scripts.

### The exported file will not open

- Check the output for serialization errors.
- Make sure the file was written completely.
- Try exporting a smaller section.
- Open the file in Roblox Studio to see whether any data is invalid or unsupported.

## TODO

### Completed

- [x] Make the core XML serializer.
- [x] Add full-place, script-only, and model-only export modes.
- [x] Add support for saving individual instances.
- [x] Add property discovery and fallback property maps.
- [x] Add Roblox API dump support.
- [x] Add engine reflection support where available.
- [x] Add instance filtering options.
- [x] Add attribute and CollectionService tag saving.
- [x] Add terrain voxel capture.
- [x] Add support for accessible CSG binary properties.
- [x] Add optional script decompilation and bytecode fallback.
- [x] Add remote configuration data and fallback tables.
- [x] Add progress display and different output methods.
- [x] Publish the source code on GitHub.

### Planned

- [ ] Improve terrain saving, especially for large regions.
- [ ] Add support for more engine-specific properties.
- [ ] Add tests to check whether generated `.rbxlx` files are valid.
- [ ] Test compatibility with Roblox updates.
- [ ] Show which instances and properties were skipped.
- [ ] Make serialization errors easier to understand.
- [ ] Add more examples to the documentation.
- [ ] Add tests for attributes, tags, terrain, and CSG data.

The unchecked items are things that could be worked on in the future. They are not finished features.

## Support Fishilizer

If you'd like to support Fishilizer and its development, you can send a donation through Cash App. It's completely optional, but any support is appreciated. <3

[![Cash App](https://img.shields.io/badge/Cash%20App-Support%20Fishilizer-00C244?style=flat-square&logo=cashapp&logoColor=white)](https://cash.app/$aeroglass)

Cash App: [$aeroglass](https://cash.app/$aeroglass)

## Links

- [GitHub Repository](https://github.com/Civilation/Fishilizer)
- [Source Code](https://github.com/Civilation/Fishilizer/blob/main/Fishilizer.lua)
- [Raw Lua Source](https://raw.githubusercontent.com/Civilation/Fishilizer/main/Fishilizer.lua)
- [Discord](https://discord.gg/GZDXBMjndT)
- [Cash App](https://cash.app/$aeroglass)

## Disclaimer

Fishilizer is an independent project for Roblox serialization and game development research. It is not affiliated with or endorsed by Roblox Corporation.

Only save places and data you are allowed to access. Respect other creators' work and Roblox's rules.

Saving and decompilation depend on the environment. Fishilizer cannot guarantee that every instance, property, or script will be recovered. Keep backups of important files before using it.

<div align="center">

**Made with ❤️ by Garfield Cat Presents**

*Thanks for checking out Fishilizer!*

</div>
