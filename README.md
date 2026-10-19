
<div align="center">
  <img src="https://files.catbox.moe/5uumgz.png" alt="Fishilizer Logo" width="150">

  <h1>Fishilizer</h1>

  <p>A Roblox place serializer written in Lua.</p>

  <p>Fishilizer saves Roblox instances and their properties to .rbxlx files that can be opened in Roblox Studio.</p>

  <p>
    <a href="https://fishilizer.github.io/documentation.html"><img src="https://img.shields.io/badge/Documentation-Read%20the%20Docs-blue?style=flat-square" alt="Documentation"></a>
    <a href="https://fishilizer.github.io/options.html"><img src="https://img.shields.io/badge/Configuration-Options-orange?style=flat-square" alt="Configuration"></a>
    <a href="https://fishilizer.github.io/"><img src="https://img.shields.io/badge/Version-10.8.1-brightgreen?style=flat-square" alt="Version 10.8.1"></a>
    <a href="https://discord.gg/GZDXBMjndT"><img src="https://img.shields.io/badge/Discord-Community-5865F2?style=flat-square&logo=discord&logoColor=white" alt="Discord"></a>
  </p>

  <p>
    <a href="https://fishilizer.github.io/">Website</a> ·
    <a href="https://fishilizer.github.io/documentation.html">Documentation</a> ·
    <a href="https://fishilizer.github.io/builder.html">Loadstring Builder</a> ·
    <a href="https://fishilizer.github.io/data.html">Data API</a>
  </p>
</div>

## Overview

Fishilizer reads the DataModel of a running Roblox game and saves the instances it can access. It supports property discovery, terrain data, CSG data, attributes, tags, and script extraction where the environment allows it.

You can save an entire place, export scripts separately, save models without scripts, or choose a specific instance to serialize.

Fishilizer uses Roblox API information, fallback property maps, and engine reflection when available to find properties to save. Some properties need special handling because they contain binary data or values that cannot be written as ordinary XML.

The goal is to preserve as much of the original place as possible. Some properties and data may not be accessible, so exported files might not be exact copies of the original.

## Preview

![Fishilizer Preview](https://files.catbox.moe/7si6e9.PNG)

## Features

- **Property discovery:** Uses `getproperties()` when available, with fallback property maps for other environments.
- **Roblox API dump:** Retrieves class and property information to help with serialization.
- **Reflection support:** Uses engine reflection when available.
- **Terrain:** Attempts to save terrain materials and occupancy data through voxel capture.
- **CSG data:** Supports accessible binary properties such as `ChildData` and `PhysicsData`.
- **Attributes:** Can save instance attributes.
- **CollectionService tags:** Can save tags attached to instances.
- **Script extraction:** Attempts to recover script source when the environment supports it.
- **Bytecode fallback:** Can preserve bytecode when enabled and available.
- **Export modes:** Supports full-place, script-only, and model-only exports.
- **Instance filtering:** Provides options for excluding player characters, core scripts, and other instances.
- **Tool preservation:** Can temporarily move eligible backpack tools into `StarterPack` during serialization.
- **Output options:** Supports file output and other methods available in the environment.
- **Remote data:** Loads serializer data from the project website and uses fallback data when needed.
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
    "https://fishilizer.github.io/Fishilizer.lua"
))()
```

This loads the script and runs its default initialization and save behavior.

### Manual execution

To control the save process yourself, disable automatic execution before loading Fishilizer.

```lua
getgenv().FISHILIZER_NO_AUTORUN = true

local Fish = loadstring(game:HttpGetAsync(
    "https://fishilizer.github.io/Fishilizer.lua"
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

The resulting output depends on the selected options and the functions available in the environment.

## API reference

The main functions available through the `Fish` table include:

| Function | Description |
| --- | --- |
| `Fish.Init()` | Initializes Fishilizer and loads supporting data. |
| `Fish.Save(instance, name?, opts?)` | Saves an instance or an array of instances. |
| `Fish.SavePlace(name?, opts?)` | Saves the current place. |
| `Fish.SaveInstance(instance, name?, opts?)` | Saves a specific instance. |
| `Fish.SaveScripts(instance, name?, opts?)` | Exports scripts. |
| `Fish.SaveModels(instance, name?, opts?)` | Exports non-script instances. |
| `Fish.FetchClasses(cacheFile?)` | Fetches or loads cached Roblox API information. |
| `Fish.LoadData()` | Loads supporting serializer data. |
| `Fish.ApplyAPIDump(data)` | Processes API dump information for property discovery. |

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

For additional details, see the [API documentation](https://fishilizer.github.io/documentation.html).

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
    "https://fishilizer.github.io/Fishilizer.lua"
))()
```

This example disables decompilation, enables attribute and tag serialization, and excludes player characters.

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

This lets you change settings for an individual export without changing the global configuration.

### Common options

| Option | Default | Description |
| --- | --- | --- |
| `Mode` | `"full"` | Selects the export mode. |
| `Decompile` | `true` | Attempts to recover script source when supported. |
| `SaveBytecode` | `false` | Enables bytecode fallback where available. |
| `UseGetProperties` | `true` | Uses `getproperties()` when available. |
| `APIProperties` | `true` | Uses API property information during serialization. |
| `UseReflectionService` | `true` | Enables property discovery through engine reflection when available. |
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

See the [Options page](https://fishilizer.github.io/options.html) for the complete list.

> [!WARNING]
> `KillAllScripts` is an available option that defaults to `false`. Enabling it can disable accessible script instances during serialization and affect the running game.

## How it works

Fishilizer processes the selected instances and builds an XML representation of their accessible data.

1. Loads configuration and supporting property data.
2. Builds property information using API dumps, fallback maps, and reflection when available.
3. Traverses the selected instances and applies configured filters.
4. Collects supported properties, attributes, tags, and content data.
5. Attempts to capture terrain voxels and CSG binary data.
6. Attempts script source recovery when enabled and supported.
7. Generates the `.rbxlx` XML output.
8. Writes the result using the configured output method.

Some properties need special handling because they contain binary data or values that cannot be represented as ordinary XML attributes.

The [Data API](https://fishilizer.github.io/data.html) contains information about the data used by the serializer, including class maps, property lists, binary properties, and other supporting information.

## Limitations

Fishilizer cannot guarantee a complete copy of every Roblox place. Results depend on which instances and properties are accessible to the environment.

### Script source

Server `Script` instances receive placeholder source in the current implementation. Their original source should not be expected in the exported file.

`LocalScript` and `ModuleScript` source recovery depends on available source access and decompilation functions. Bytecode fallback does not guarantee that the original source can be reconstructed.

### Terrain

Terrain capture depends on accessible voxel APIs. Large regions may exceed the configured cell limit, and some terrain data may not be available.

Adjust `TerrainResolution` and `TerrainCellCap` when working with large terrain regions.

### Properties

Some properties may be inaccessible, unsupported, or filtered out. Roblox updates can introduce new classes and properties that the current property maps do not handle.

### Runtime state

Not all runtime state can be restored from an exported file. Engine-managed values, unavailable assets, server-only data, and unsupported instance types can prevent an exact reconstruction.

### File output

File-writing and clipboard functions depend on the environment. Successful serialization does not necessarily mean the output was written successfully.

## Troubleshooting

### The save fails

- Check the execution output for errors.
- Confirm that the required functions are available.
- Verify that file writing is supported.
- Try saving a smaller model to identify problematic instances.

### Properties are missing

- Check whether `getproperties()` is available.
- Review the API property configuration.
- Check which properties are filtered by your options.
- Update the supporting API data if it is outdated.

### Terrain is incomplete

- Check whether voxel-reading functions are available.
- Reduce the size of the terrain region being exported.
- Review `TerrainResolution` and `TerrainCellCap`.

### Scripts are missing source

- Check whether `Decompile` is enabled.
- Verify that the environment provides compatible decompilation functions.
- Remember that server script source is not recovered by the current implementation.

### The exported file will not open

- Check the output for serialization errors.
- Confirm that the file was written completely.
- Try exporting a smaller section.
- Open the file in Roblox Studio to identify invalid or unsupported data.

## TODO

### Completed

- [x] Implement the core XML serializer.
- [x] Add full-place, script-only, and model-only export modes.
- [x] Support saving individual instances.
- [x] Add property discovery and fallback property maps.
- [x] Integrate Roblox API dump information.
- [x] Add engine reflection support where available.
- [x] Add configurable instance filtering.
- [x] Add attribute and CollectionService tag serialization.
- [x] Implement terrain voxel capture.
- [x] Add support for accessible CSG binary properties.
- [x] Add optional script decompilation and bytecode fallback.
- [x] Add remote configuration data and fallback tables.
- [x] Add progress feedback and configurable output methods.
- [x] Publish documentation and configuration pages.

### Planned

- [ ] Improve terrain capture and handling of large regions.
- [ ] Add support for more engine-specific properties.
- [ ] Add automated validation for generated `.rbxlx` files.
- [ ] Test compatibility with new Roblox engine updates.
- [ ] Improve reporting for skipped instances and properties.
- [ ] Improve error messages when serialization fails.
- [ ] Add more examples to the documentation.
- [ ] Add regression tests for attributes, tags, terrain, and CSG data.

The unchecked items are potential future improvements, not features that are already implemented.

## Links

- [Website](https://fishilizer.github.io/)
- [Documentation](https://fishilizer.github.io/documentation.html)
- [Configuration options](https://fishilizer.github.io/options.html)
- [Loadstring Builder](https://fishilizer.github.io/builder.html)
- [Data API](https://fishilizer.github.io/data.html)
- [Source code](https://github.com/Civilation/Fishilizer/blob/main/Fishilizer.lua)
- [Discord](https://discord.gg/GZDXBMjndT)

## Disclaimer

Fishilizer is an independent project for Roblox serialization and game development research. It is not affiliated with or endorsed by Roblox Corporation.

Only export places and data you are authorized to access. Respect other creators' work and applicable platform rules.

Serialization and decompilation depend on the available environment. Complete recovery of every instance, property, or script is not guaranteed. Keep backups of important files before using the tool.

<div align="center">

**Made with ❤️ by Garfield Cat Presents**

*Thanks for checking out Fishilizer!*

</div>
