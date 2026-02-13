# Hades 2 Balance Changes Mod

A mod for Hades 2 that adjusts game balance.

## Features

### Steady Growth (Demeter) - Balance Tweak
Reduces the number of encounters needed for Steady Growth to upgrade a boon by 1:

| Rarity | Original | Modified |
|--------|----------|----------|
| Common | 6 encounters | 5 encounters |
| Rare | 5 encounters | 4 encounters |
| Epic | 4 encounters | 3 encounters |
| Heroic | 3 encounters | 2 encounters |

### Force First God
Choose which god's boon appears as the first boon in a run.

- Press **INSERT** to open the mod menu, then select **Force First God**
- Pick any of the 9 Olympian gods: Aphrodite, Apollo, Ares, Demeter, Hephaestus, Hera, Hestia, Poseidon, Zeus
- Select "Random (Disabled)" to use default behavior
- Only affects the first boon room of each run — normal random selection resumes after that
- Respects keepsake-forced boons

### Bonus Selene Points
Grants 5 bonus talent points the first time you pick up a Selene spell each run, giving you a head start on your spell's talent tree.

## Installation

### Prerequisites
1. Install [Hell2Modding](https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/)
   - Download the latest release
   - Extract `d3d12.dll` to your Hades 2 `Ship` folder (next to `Hades2.exe`)
   - Typically: `C:\Program Files (x86)\Steam\steamapps\common\Hades II\Ship\`

### Install the Mod
1. Download this mod (or clone the repository)
2. Create a folder for the mod in the Hell2Modding plugins directory (folder must be `AuthorName-ModName` format):
   ```
   Hades II\Ship\ReturnOfModding\plugins\YourName-SteadyGrowthFaster\
   ```
3. Copy `main.lua` and `manifest.json` into that folder
4. Launch Hades 2

### Verify Installation
When the mod loads successfully, you'll see in the console:
```
[SteadyGrowthFaster] Steady Growth encounter requirements reduced by 1
[ForceFirstGod] Hooked SetupRoomReward
[BonusSelenePoints] Hooked AcceptAndCloseSpellScreen
```

## Uninstallation
Delete the mod folder from `plugins/` or remove `d3d12.dll` to disable all mods.

## Compatibility
- Requires Hell2Modding v1.0.28 or later
- Compatible with other mods that don't modify Steady Growth
