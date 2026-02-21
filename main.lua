-- FrankDrebin893Mod
-- Hades 2 balance mod
--
-- Steady Growth (Demeter)
-- Reduces the number of encounters needed for Steady Growth upgrades by 1
--
-- Original values: Common=6, Rare=5, Epic=4, Heroic=3
-- New values:      Common=4, Rare=3, Epic=2, Heroic=1

rom.on_import.post(function(scriptName)
    -- Wait for TraitData_Demeter.lua to load (contains BoonGrowthBoon)
    if scriptName ~= "TraitData_Demeter.lua" then
        return
    end

    local traitData = rom.game.TraitData.BoonGrowthBoon

    if traitData then
        -- Modify RarityLevels multipliers to reduce encounters by 1
        -- Base is 6 rooms, multipliers give: Common=6, Rare=5, Epic=4, Heroic=3
        -- New multipliers give:              Common=4, Rare=3, Epic=2, Heroic=1
        if traitData.RarityLevels then
            traitData.RarityLevels.Common = { Multiplier = 4/6 }
            traitData.RarityLevels.Rare = { Multiplier = 3/6 }
            traitData.RarityLevels.Epic = { Multiplier = 2/6 }
            traitData.RarityLevels.Heroic = { Multiplier = 1/6 }
        end

        print("[SteadyGrowth] Steady Growth encounter requirements reduced by 1")
    else
        print("[SteadyGrowth] Warning: Could not find BoonGrowthBoon trait data")
    end
end)

-- ============================================================
-- Force First Reward Feature
-- Lets the player choose the type and god of the first reward in a run
-- ============================================================

local ForceRewardOptions = {
    { name = "Disabled",           rewardType = nil,              lootName = nil,                section = "control" },
    { name = "God Boon (Random)",  rewardType = "Boon",           lootName = nil,                section = "gods" },
    { name = "Aphrodite",          rewardType = "Boon",           lootName = "AphroditeUpgrade", section = "gods" },
    { name = "Apollo",             rewardType = "Boon",           lootName = "ApolloUpgrade",    section = "gods" },
    { name = "Ares",               rewardType = "Boon",           lootName = "AresUpgrade",      section = "gods" },
    { name = "Demeter",            rewardType = "Boon",           lootName = "DemeterUpgrade",   section = "gods" },
    { name = "Hephaestus",         rewardType = "Boon",           lootName = "HephaestusUpgrade",section = "gods" },
    { name = "Hera",               rewardType = "Boon",           lootName = "HeraUpgrade",      section = "gods" },
    { name = "Hestia",             rewardType = "Boon",           lootName = "HestiaUpgrade",    section = "gods" },
    { name = "Poseidon",           rewardType = "Boon",           lootName = "PoseidonUpgrade",  section = "gods" },
    { name = "Zeus",               rewardType = "Boon",           lootName = "ZeusUpgrade",      section = "gods" },
    { name = "Hermes",             rewardType = "HermesUpgrade",  lootName = nil,                section = "other" },
    { name = "Hammer",             rewardType = "WeaponUpgrade",  lootName = nil,                section = "other" },
    { name = "Selene",             rewardType = "SpellDrop",      lootName = nil,                section = "other" },
}

local selectedRewardIndex = 0 -- 0-based, 0 = Disabled
local forceChaosGate = false

-- ImGui menu bar entry
rom.gui.add_to_menu_bar(function()
    if rom.ImGui.BeginMenu("Force First Reward") then
        local lastSection = nil
        for i, opt in ipairs(ForceRewardOptions) do
            local idx = i - 1
            if lastSection and opt.section ~= lastSection and rom.ImGui.Separator then
                rom.ImGui.Separator()
            end
            lastSection = opt.section
            local prefix = (selectedRewardIndex == idx) and "> " or "  "
            if rom.ImGui.MenuItem(prefix .. opt.name) then
                selectedRewardIndex = idx
            end
        end
        if rom.ImGui.Separator then
            rom.ImGui.Separator()
        end
        local chaosPrefix = forceChaosGate and "> " or "  "
        if rom.ImGui.MenuItem(chaosPrefix .. "Force Chaos Gate") then
            forceChaosGate = not forceChaosGate
        end
        rom.ImGui.EndMenu()
    end
end)

-- Hook RewardLogic.lua to force first reward type and god
rom.on_import.post(function(scriptName)
    if scriptName ~= "RewardLogic.lua" then
        return
    end

    -- Hook ChooseRoomReward to force the reward type
    local OriginalChooseRoomReward = rom.game.ChooseRoomReward

    rom.game.ChooseRoomReward = function(run, room, rewardStoreName, previouslyChosenRewards, args)
        local opt = ForceRewardOptions[selectedRewardIndex + 1]

        if opt and opt.rewardType and not run._forceFirstReward_applied then
            run._forceFirstReward_applied = true
            -- If a specific god is selected, mark it for SetupRoomReward to apply
            if opt.lootName then
                run._forceFirstGod_pending = opt.lootName
            end
            print("[ForceFirstReward] Forced first reward to: " .. opt.name)
            return opt.rewardType
        end

        return OriginalChooseRoomReward(run, room, rewardStoreName, previouslyChosenRewards, args)
    end

    -- Hook SetupRoomReward to force specific god when applicable
    local OriginalSetupRoomReward = rom.game.SetupRoomReward

    rom.game.SetupRoomReward = function(currentRun, room, previouslyChosenRewards, args)
        -- Call original first
        OriginalSetupRoomReward(currentRun, room, previouslyChosenRewards, args)

        -- Apply pending god override (set by ChooseRoomReward hook)
        if currentRun._forceFirstGod_pending then
            -- Don't override keepsake-forced boons
            if room.ForcedBoonNames and next(room.ForcedBoonNames) ~= nil then
                currentRun._forceFirstGod_pending = nil
                return
            end

            room.ForceLootName = currentRun._forceFirstGod_pending
            print("[ForceFirstReward] Forced god to: " .. currentRun._forceFirstGod_pending)
            currentRun._forceFirstGod_pending = nil
        end
    end

    print("[ForceFirstReward] Hooked ChooseRoomReward and SetupRoomReward")
end)

-- Hook RoomLogic.lua to force Chaos gate in first eligible room
rom.on_import.post(function(scriptName)
    if scriptName ~= "RoomLogic.lua" then
        return
    end

    local OriginalHandleSecretSpawns = rom.game.HandleSecretSpawns

    rom.game.HandleSecretSpawns = function(currentRun)
        if forceChaosGate and not currentRun._forceChaosGate_applied then
            currentRun._forceChaosGate_applied = true
            currentRun.CurrentRoom.ForceSecretDoor = true
            print("[ForceFirstReward] Forcing Chaos gate in room: " .. (currentRun.CurrentRoom.Name or "unknown"))
        end

        OriginalHandleSecretSpawns(currentRun)
    end

    print("[ForceFirstReward] Hooked HandleSecretSpawns")
end)

-- ============================================================
-- Bonus Selene Points Feature
-- Grants 5 bonus talent points after first Selene spell pickup in a run
-- ============================================================

local bonusSelenePoints = 5

rom.on_import.post(function(scriptName)
    if scriptName ~= "SpellScreenLogic.lua" then
        return
    end

    local OriginalAcceptAndCloseSpellScreen = rom.game.AcceptAndCloseSpellScreen

    rom.game.AcceptAndCloseSpellScreen = function(screen, button)
        -- Call original first (player selects their spell)
        OriginalAcceptAndCloseSpellScreen(screen, button)

        -- Grant bonus talent points on first spell selection of the run
        local currentRun = rom.game.CurrentRun
        if currentRun and not currentRun._bonusSelenePoints_applied then
            currentRun._bonusSelenePoints_applied = true
            currentRun.NumTalentPoints = (currentRun.NumTalentPoints or 0) + bonusSelenePoints

            -- Open the talent screen after the spell screen finishes closing
            rom.game.thread(function()
                rom.game.wait(1.0)
                rom.game.OpenTalentScreen({})
            end)

            print("[BonusSelenePoints] Granted " .. bonusSelenePoints .. " bonus talent points, opening talent screen")
        end
    end

    print("[BonusSelenePoints] Hooked AcceptAndCloseSpellScreen")
end)

-- ============================================================
-- Remove Gathering Tool Chaos Boons
-- Removes ChaosHarvestBlessing from the Chaos boon pool
-- ============================================================

rom.on_import.post(function(scriptName)
    if scriptName ~= "LootData_Chaos.lua" then
        return
    end

    local trialUpgrade = rom.game.LootData.TrialUpgrade
    if trialUpgrade and trialUpgrade.PermanentTraits then
        for i = #trialUpgrade.PermanentTraits, 1, -1 do
            if trialUpgrade.PermanentTraits[i] == "ChaosHarvestBlessing" then
                table.remove(trialUpgrade.PermanentTraits, i)
                print("[ChaosFilter] Removed ChaosHarvestBlessing from Chaos boon pool")
                break
            end
        end
    end
end)

-- ============================================================
-- Chaos Reroll Fix
-- Adds exclusion logic so rerolling Chaos boons doesn't repeat the same options
-- (The game's ExclusionNames logic is bypassed for TransformingTraits like Chaos)
-- ============================================================

rom.on_import.post(function(scriptName)
    if scriptName ~= "TraitLogic.lua" then
        return
    end

    -- Wrap GetHeroTrait so any code that calls it directly can find our mod rarify trait.
    -- The trait lives in CurrentRun._modRarifyTrait (not in Hero.Traits permanently),
    -- so keepsake display systems never see it.
    local OriginalGetHeroTrait = rom.game.GetHeroTrait
    rom.game.GetHeroTrait = function(traitName)
        local result = OriginalGetHeroTrait(traitName)
        if result == nil and traitName == "RarifyKeepsake"
                and rom.game.CurrentRun and rom.game.CurrentRun._modRarifyTrait then
            return rom.game.CurrentRun._modRarifyTrait
        end
        return result
    end

    -- Hook SetTraitsOnLoot to exclude all 3 current options on reroll.
    -- Vanilla bug: RerollBoonLoot only passes 1 random item as ExclusionNames, so the other 2
    -- can repeat immediately. We expand it to all current UpgradeOptions so every reroll
    -- shows 3 boons you haven't just seen. Previous sets can come back on future rerolls.
    local OriginalSetTraitsOnLoot = rom.game.SetTraitsOnLoot

    rom.game.SetTraitsOnLoot = function(lootData, args)
        if args and args.ExclusionNames and lootData.UpgradeOptions then
            -- Expand ExclusionNames to cover all 3 current options (not just 1 random)
            local allExclusions = {}
            for _, name in ipairs(args.ExclusionNames) do
                allExclusions[name] = true
            end
            for _, opt in pairs(lootData.UpgradeOptions) do
                if opt.ItemName then
                    allExclusions[opt.ItemName] = true
                end
            end
            local exclusionList = {}
            for name, _ in pairs(allExclusions) do
                table.insert(exclusionList, name)
            end
            args.ExclusionNames = exclusionList
            -- Allow fresh rarity roll on each reroll
            args.BoonRaritiesOverride = nil
            args.IgnoreAllRarityBonus = nil
            args.IgnoreRoomRarityBonus = nil
            print("[GodBoonReroll] Excluding " .. #exclusionList .. " current boons")
        end
        OriginalSetTraitsOnLoot(lootData, args)
    end

    local OriginalSetTransformingTraitsOnLoot = rom.game.SetTransformingTraitsOnLoot

    rom.game.SetTransformingTraitsOnLoot = function(lootData, upgradeChoiceData)
        -- Only apply exclusion if this is a reroll (UpgradeOptions already populated)
        local currentOptions = {}
        if lootData.UpgradeOptions then
            for _, opt in pairs(lootData.UpgradeOptions) do
                if opt.ItemName then
                    currentOptions[opt.ItemName] = true
                end
            end
        end

        if next(currentOptions) then
            local originalTraits = upgradeChoiceData.PermanentTraits
            local filteredTraits = {}
            for _, traitName in ipairs(originalTraits) do
                if not currentOptions[traitName] then
                    table.insert(filteredTraits, traitName)
                end
            end

            -- Check that enough eligible traits remain after filtering
            local eligibleCount = 0
            for _, traitName in ipairs(filteredTraits) do
                if rom.game.IsTraitEligible(rom.game.TraitData[traitName]) then
                    eligibleCount = eligibleCount + 1
                end
            end

            if eligibleCount >= rom.game.GetTotalLootChoices() then
                upgradeChoiceData.PermanentTraits = filteredTraits
                OriginalSetTransformingTraitsOnLoot(lootData, upgradeChoiceData)
                upgradeChoiceData.PermanentTraits = originalTraits
                print("[ChaosReroll] Rerolled with " .. eligibleCount .. " eligible traits")
                return
            end
            print("[ChaosReroll] Pool too small after exclusion (" .. eligibleCount .. " eligible), allowing repeats")
        end

        OriginalSetTransformingTraitsOnLoot(lootData, upgradeChoiceData)
    end

    print("[ChaosReroll] Hooked SetTransformingTraitsOnLoot for reroll exclusion")
end)

-- ============================================================
-- Bonus Rarify Uses Feature
-- Grants 10 rarity upgrade uses per run (Calling Card mechanic)
-- Hover over a boon option on any god boon screen to upgrade its rarity
-- ============================================================

local bonusRarifyUses = 10

-- ============================================================
-- Free Rerolls Feature
-- Grants free rerolls on boon screens
-- ============================================================

local freeRerollLootTypes = {
    -- Special screens
    TrialUpgrade       = 10,  -- Chaos: 10 rerolls
    SpellDrop          = 10,  -- Selene: 10 rerolls
    HermesUpgrade      = 10,  -- Hermes: 10 rerolls
    WeaponUpgrade      = 10,  -- Daedalus Hammer: 10 rerolls
    -- God boons
    AphroditeUpgrade   = 10,
    ApolloUpgrade      = 10,
    AresUpgrade        = 10,
    DemeterUpgrade     = 10,
    HephaestusUpgrade  = 10,
    HeraUpgrade        = 10,
    HestiaUpgrade      = 10,
    PoseidonUpgrade    = 10,
    ZeusUpgrade        = 10,
}

-- Hook UpgradeChoiceLogic.lua to override reroll display
rom.on_import.post(function(scriptName)
    if scriptName ~= "UpgradeChoiceLogic.lua" then
        return
    end

    -- Wrap UpgradeMouseOverUpgradeChoice: allow one upgrade per hover-enter event.
    -- The function fires every frame while hovering. We deduplicate by tracking the
    -- last button argument; if it hasn't changed the mouse is still over the same boon,
    -- so we skip. When the mouse enters a new boon button the upgrade fires once.
    --
    -- Vanilla iterates Hero.Traits directly to find RarifyKeepsake, so we temporarily
    -- inject our mod trait for the duration of this call, then remove it immediately.
    -- Lua is single-threaded, so no other system sees the trait during this window.
    local OriginalUpgradeMouseOver = rom.game.UpgradeMouseOverUpgradeChoice
    rom.game.UpgradeMouseOverUpgradeChoice = function(screen, button)
        if button == screen._rarifyLastButton then
            -- Same button, still hovering — vanilla's UpgradedRarity flag is already set,
            -- so it won't upgrade again. Just return.
            return
        end
        -- Hover-enter: new button (or moved off all buttons).
        -- Clear vanilla's per-hover dedup flag so it can upgrade on this new hover-enter.
        screen.UpgradedRarity = nil
        screen._rarifyLastButton = button

        local currentRun = rom.game.CurrentRun
        local modTrait = currentRun and currentRun._modRarifyTrait
        if modTrait then
            table.insert(currentRun.Hero.Traits, modTrait)
        end

        local result = OriginalUpgradeMouseOver(screen, button)

        if modTrait then
            for i = #currentRun.Hero.Traits, 1, -1 do
                if currentRun.Hero.Traits[i] == modTrait then
                    table.remove(currentRun.Hero.Traits, i)
                    break
                end
            end
        end

        return result
    end

    local OriginalCreateBoonLootButtons = rom.game.CreateBoonLootButtons

    rom.game.CreateBoonLootButtons = function(screen, lootData, reroll, args)
        -- Call original first
        OriginalCreateBoonLootButtons(screen, lootData, reroll, args)

        -- Grant rarify uses at start of each run (once, on first boon screen)
        local currentRun = rom.game.CurrentRun
        if currentRun and not currentRun._rarifyGranted then
            currentRun._rarifyGranted = true
            if rom.game.HeroHasTrait("RarifyKeepsake") then
                -- Player has the real Calling Card keepsake; boost their uses
                local trait = rom.game.GetHeroTrait("RarifyKeepsake")
                if trait and trait.RarityUpgradeData then
                    trait.RarityUpgradeData.Uses = math.max(trait.RarityUpgradeData.Uses or 0, bonusRarifyUses)
                    trait.RarityUpgradeData.MultiUse = true
                    trait.RarityUpgradeData.RequireFated = false
                    trait.RarityUpgradeData.RequireNotExcludeFromLastRunBoon = false
                end
            else
                -- Store trait in mod-specific field only. UpgradeMouseOverUpgradeChoice
                -- will inject it temporarily into Hero.Traits for each hover call so
                -- vanilla can find it, then remove it immediately after. This keeps it
                -- invisible to keepsake display systems that run at other times.
                currentRun._modRarifyTrait = {
                    Name = "RarifyKeepsake",
                    RarityUpgradeData = {
                        Uses = bonusRarifyUses,
                        MultiUse = true,
                        MaxRarity = 3,
                        RequireFated = false,
                        RequireNotExcludeFromLastRunBoon = false,
                    },
                }
            end
            print("[BonusRarify] Granted " .. bonusRarifyUses .. " rarify uses for this run")
        end

        -- Check if this loot type has free rerolls
        local maxRerolls = freeRerollLootTypes[lootData.Name]
        if not maxRerolls then
            return
        end

        local components = screen.Components
        if not components or not components.RerollButton then
            return
        end

        -- Check how many rerolls already used on this panel
        local spent = 0
        if rom.game.CurrentRun.CurrentRoom.SpentRerolls then
            spent = rom.game.CurrentRun.CurrentRoom.SpentRerolls[lootData.ObjectId] or 0
        end

        if spent < maxRerolls then
            -- Show reroll button as free
            components.RerollButton.Cost = 0
            components.RerollButton.OnPressedFunctionName = "AttemptPanelReroll"
            components.RerollButton.RerollFunctionName = "RerollBoonLoot"
            components.RerollButton.RerollColor = lootData.LootColor
            components.RerollButton.RerollId = lootData.ObjectId
            components.RerollButton.LootData = lootData
            rom.game.ModifyTextBox({
                Id = components.RerollButton.Id,
                Text = "Boon_Reroll",
                LuaKey = "TempTextData",
                LuaValue = { Amount = maxRerolls - spent }
            })
            rom.game.SetAlpha({ Id = components.RerollButton.Id, Fraction = 1.0, Duration = 0.2 })
        else
            -- Hide reroll button after max uses
            rom.game.SetAlpha({ Id = components.RerollButton.Id, Fraction = 0.0, Duration = 0.2 })
        end
    end

    print("[FreeRerolls] Hooked CreateBoonLootButtons")
end)

-- Hook InteractLogic.lua to make rerolls free
rom.on_import.post(function(scriptName)
    if scriptName ~= "InteractLogic.lua" then
        return
    end

    local OriginalAttemptPanelReroll = rom.game.AttemptPanelReroll

    rom.game.AttemptPanelReroll = function(screen, button)
        -- For supported loot types, make rerolls free but limit to max
        if button.LootData and freeRerollLootTypes[button.LootData.Name] then
            local maxRerolls = freeRerollLootTypes[button.LootData.Name]
            local spent = 0
            if rom.game.CurrentRun.CurrentRoom.SpentRerolls then
                spent = rom.game.CurrentRun.CurrentRoom.SpentRerolls[button.RerollId] or 0
            end
            if spent >= maxRerolls then
                return
            end
            button.Cost = 0
        end

        OriginalAttemptPanelReroll(screen, button)
    end

    print("[FreeRerolls] Hooked AttemptPanelReroll")
end)
