# Hades 2 Balance Changes Mod

## Project Overview
This is a Hades 2 mod that makes balance changes to boons and game mechanics. Built using the Hell2Modding framework.

## Game Files Location
The user's Hades 2 installation is at:
```
C:\Program Files (x86)\Steam\steamapps\common\Hades II
```

Key script locations:
- `Content/Scripts/` - All Lua game scripts
- `Content/Scripts/TraitData.lua` - Base trait definitions
- `Content/Scripts/TraitData_Demeter.lua` - Demeter boon definitions
- `Content/Scripts/TraitLogic.lua` - Trait processing logic

## Mod Structure
- `manifest.json` - Thunderstore mod metadata
- `main.lua` - Mod entry point

## Hell2Modding API
- Folder naming: Must be `AuthorName-ModName` format (e.g., `YourName-SteadyGrowthFaster`)
- `rom.game` - Reference to game's global table (`_G`), use `rom.game.TraitData` to access traits
- `rom.on_import.pre(fn)` - Callback before a script loads, receives (scriptName, env)
- `rom.on_import.post(fn)` - Callback after a script loads, receives (scriptName)

Scripts are loaded from `Content/Scripts/`. Hook into specific scripts like `TraitData_Demeter.lua` to modify data after it's loaded.

## Current Changes

### Steady Growth (BoonGrowthBoon)
Located in `TraitData_Demeter.lua`. Demeter boon that upgrades a random boon's rarity after clearing encounters.

Key properties:
- `RoomsPerUpgrade.Amount.BaseValue` - Base number of rooms (default: 6)
- `RarityLevels` - Multipliers applied to base value per rarity

Original encounter requirements: Common=6, Rare=5, Epic=4, Heroic=3
Modified to: Common=5, Rare=4, Epic=3, Heroic=2

## Modding Notes
- Trait names don't always match display names (e.g., "Steady Growth" is `BoonGrowthBoon`)
- Always verify trait names and property structures against actual game files
- Use `rom.game.OnReady()` to ensure TraitData is loaded before modifying
