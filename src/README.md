# src/README

This directory holds the modular source files for Fishilizer.

Organization (files are concatenated by build.lua in this order):

- Core.lua       -- Top-of-file: Fish table, options, IO resolution, helpers
- Attributes.lua -- Attribute encoding helpers and tag encoding
- UI.lua         -- Progress UI builders and helpers
- Serializers.lua-- Serialization helpers for different property types
- Walker.lua     -- Instance walking, filtering and reference generation
- Main.lua       -- High-level entry points (Fish.Init, Fish.Save, public API)

Notes:
- build.lua concatenates the files into Fishilizer.lua so the loadstring remains a single, distributable file.
- When editing modules, ensure the concatenated result is valid Lua. Do not include 'return' statements in the middle of the concatenation unless intentional.
- After populating the modules, run `lua build.lua` to generate Fishilizer.lua.
