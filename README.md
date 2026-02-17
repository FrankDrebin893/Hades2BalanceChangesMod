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

### Force First Reward
Choose what type of reward appears first in a run.

- Press **INSERT** to open the mod menu, then select **Force First Reward**
- **God Boons:** Pick a specific god (Aphrodite, Apollo, Ares, Demeter, Hephaestus, Hera, Hestia, Poseidon, Zeus) or "God Boon (Random)" for a random god
- **Other rewards:** Hermes, Hammer, or Selene
- Select "Disabled" to use default behavior
- **Force Chaos Gate:** Toggle to guarantee a Chaos gate appears in the first eligible room
- Only affects the first reward/room of each run — normal random selection resumes after that
- Respects keepsake-forced boons when forcing a specific god

### Bonus Selene Points
Grants 5 bonus talent points the first time you pick up a Selene spell each run, giving you a head start on your spell's talent tree.

### Chaos Boon Filter
Removes the gathering tool Chaos blessing (ChaosHarvestBlessing) from the Chaos boon pool, so you'll never be offered it.

### Chaos Reroll Fix
Fixes a vanilla game issue where rerolling Chaos boons often shows the same blessings again. The game's reroll exclusion logic is bypassed for Chaos (TransformingTraits), so this mod adds proper exclusion — previously shown blessings are filtered out when rerolling, ensuring you see different options each time (as long as the eligible pool is large enough).

### Free Rerolls
Gives you free rerolls on boon selection screens, regardless of your current reroll count. These rerolls don't consume your regular rerolls.

| Screen | Free Rerolls |
|--------|-------------|
| All god boons | 10 each |
| Chaos | 10 |
| Selene | 10 |
| Hermes | 10 |
| Daedalus Hammer | 10 |

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
   Hades II\Ship\ReturnOfModding\plugins\YourName-FrankDrebin893Mod\
   ```
3. Copy `main.lua` and `manifest.json` into that folder
4. Launch Hades 2

### Verify Installation
When the mod loads successfully, you'll see in the console:
```
[SteadyGrowth] Steady Growth encounter requirements reduced by 1
[ForceFirstReward] Hooked ChooseRoomReward and SetupRoomReward
[ForceFirstReward] Hooked HandleSecretSpawns
[BonusSelenePoints] Hooked AcceptAndCloseSpellScreen
[ChaosFilter] Removed ChaosHarvestBlessing from Chaos boon pool
[ChaosReroll] Hooked SetTransformingTraitsOnLoot for reroll exclusion
[FreeRerolls] Hooked CreateBoonLootButtons
[FreeRerolls] Hooked AttemptPanelReroll
```

## Uninstallation
Delete the mod folder from `plugins/` or remove `d3d12.dll` to disable all mods.

## Compatibility
- Requires Hell2Modding v1.0.28 or later
- Compatible with other mods that don't modify Steady Growth
