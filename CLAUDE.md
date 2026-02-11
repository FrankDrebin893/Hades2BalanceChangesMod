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

## Implementation Notes

See `README.md` for the list of features and user-facing documentation. Keep README.md updated when adding or changing features.

### Steady Growth (BoonGrowthBoon)
- Trait is in `TraitData_Demeter.lua`, hooked via `rom.on_import.post`
- Key properties: `RoomsPerUpgrade.Amount.BaseValue` (default: 6), `RarityLevels` multipliers

### Force First God
- Hooks `SetupRoomReward` in `RewardLogic.lua` via `rom.on_import.post`
- Wraps the original function, overrides `room.ForceLootName` when reward is "Boon"
- Tracks per-run state via `CurrentRun._forceFirstGod_applied` flag (auto-resets on new run)
- ImGui menu via `rom.gui.add_to_menu_bar`

## Modding Notes
- Trait names don't always match display names (e.g., "Steady Growth" is `BoonGrowthBoon`)
- Always verify trait names and property structures against actual game files
- Use `rom.on_import.post()` to hook after specific scripts load (e.g., `TraitData_Demeter.lua`)

## Workflow
- Always commit and push changes to the repository after making modifications
- Deploy to local installation at: `C:\Program Files (x86)\Steam\steamapps\common\Hades II\Ship\ReturnOfModding\plugins\BalanceMod-SteadyGrowthFaster\`
- Use `deploy.ps1` (gitignored) for local deployment
