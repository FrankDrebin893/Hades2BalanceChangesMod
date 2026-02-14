-- SteadyGrowthFaster
-- Reduces the number of encounters needed for Steady Growth upgrades by 1
--
-- Original values: Common=6, Rare=5, Epic=4, Heroic=3
-- New values:      Common=5, Rare=4, Epic=3, Heroic=2

rom.on_import.post(function(scriptName)
    -- Wait for TraitData_Demeter.lua to load (contains BoonGrowthBoon)
    if scriptName ~= "TraitData_Demeter.lua" then
        return
    end

    local traitData = rom.game.TraitData.BoonGrowthBoon

    if traitData then
        -- Modify RarityLevels multipliers to reduce encounters by 1
        -- Base is 6 rooms, multipliers give: Common=6, Rare=5, Epic=4, Heroic=3
        -- New multipliers give:              Common=5, Rare=4, Epic=3, Heroic=2
        if traitData.RarityLevels then
            traitData.RarityLevels.Common = { Multiplier = 5/6 }
            traitData.RarityLevels.Rare = { Multiplier = 4/6 }
            traitData.RarityLevels.Epic = { Multiplier = 3/6 }
            traitData.RarityLevels.Heroic = { Multiplier = 2/6 }
        end

        print("[SteadyGrowthFaster] Steady Growth encounter requirements reduced by 1")
    else
        print("[SteadyGrowthFaster] Warning: Could not find BoonGrowthBoon trait data")
    end
end)

-- ============================================================
-- Force First God Feature
-- Lets the player choose which god's boon appears first in a run
-- ============================================================

local GodOptions = {
    { name = "Random (Disabled)", lootName = nil },
    { name = "Aphrodite", lootName = "AphroditeUpgrade" },
    { name = "Apollo",    lootName = "ApolloUpgrade" },
    { name = "Ares",      lootName = "AresUpgrade" },
    { name = "Demeter",   lootName = "DemeterUpgrade" },
    { name = "Hephaestus",lootName = "HephaestusUpgrade" },
    { name = "Hera",      lootName = "HeraUpgrade" },
    { name = "Hestia",    lootName = "HestiaUpgrade" },
    { name = "Poseidon",  lootName = "PoseidonUpgrade" },
    { name = "Zeus",      lootName = "ZeusUpgrade" },
}

local GodDisplayNames = {}
for i, opt in ipairs(GodOptions) do
    GodDisplayNames[i] = opt.name
end

local selectedGodIndex = 0 -- 0-based, 0 = Random/Disabled

-- ImGui menu bar entry
rom.gui.add_to_menu_bar(function()
    if rom.ImGui.BeginMenu("Force First God") then
        for i, opt in ipairs(GodOptions) do
            local idx = i - 1
            local prefix = (selectedGodIndex == idx) and "> " or "  "
            if rom.ImGui.MenuItem(prefix .. opt.name) then
                selectedGodIndex = idx
            end
        end
        rom.ImGui.EndMenu()
    end
end)

-- Hook RewardLogic.lua to override first boon room
rom.on_import.post(function(scriptName)
    if scriptName ~= "RewardLogic.lua" then
        return
    end

    local OriginalSetupRoomReward = rom.game.SetupRoomReward

    rom.game.SetupRoomReward = function(currentRun, room, previouslyChosenRewards, args)
        -- Call original first
        OriginalSetupRoomReward(currentRun, room, previouslyChosenRewards, args)

        -- Only act on Boon rewards
        args = args or {}
        local chosenRewardType = args.ChosenRewardType or room.ChosenRewardType
        if chosenRewardType ~= "Boon" then
            return
        end

        -- Check if user wants to force a god
        local opt = GodOptions[selectedGodIndex + 1]
        if opt == nil or opt.lootName == nil then
            return
        end

        -- Only force the first boon of the run
        if currentRun._forceFirstGod_applied then
            return
        end

        -- Don't override keepsake-forced boons
        if room.ForcedBoonNames and next(room.ForcedBoonNames) ~= nil then
            return
        end

        room.ForceLootName = opt.lootName
        currentRun._forceFirstGod_applied = true
        print("[ForceFirstGod] Forced first boon to: " .. opt.name)
    end

    print("[ForceFirstGod] Hooked SetupRoomReward")
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
-- Chaos Free Rerolls Feature
-- Grants 3 free rerolls on Chaos boon selection screens
-- ============================================================

local chaosMaxRerolls = 3

-- Hook UpgradeChoiceLogic.lua to override reroll display for Chaos boons
rom.on_import.post(function(scriptName)
    if scriptName ~= "UpgradeChoiceLogic.lua" then
        return
    end

    local OriginalCreateBoonLootButtons = rom.game.CreateBoonLootButtons

    rom.game.CreateBoonLootButtons = function(screen, lootData, reroll, args)
        -- Call original first
        OriginalCreateBoonLootButtons(screen, lootData, reroll, args)

        -- Only override for Chaos boons (TrialUpgrade)
        if lootData.Name ~= "TrialUpgrade" then
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

        if spent < chaosMaxRerolls then
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
                LuaValue = { Amount = 0 }
            })
            rom.game.SetAlpha({ Id = components.RerollButton.Id, Fraction = 1.0, Duration = 0.2 })
        else
            -- Hide reroll button after max uses
            rom.game.SetAlpha({ Id = components.RerollButton.Id, Fraction = 0.0, Duration = 0.2 })
        end
    end

    print("[ChaosRerolls] Hooked CreateBoonLootButtons")
end)

-- Hook InteractLogic.lua to make Chaos rerolls free
rom.on_import.post(function(scriptName)
    if scriptName ~= "InteractLogic.lua" then
        return
    end

    local OriginalAttemptPanelReroll = rom.game.AttemptPanelReroll

    rom.game.AttemptPanelReroll = function(screen, button)
        -- For Chaos boons, make rerolls free but limit to max
        if button.LootData and button.LootData.Name == "TrialUpgrade" then
            local spent = 0
            if rom.game.CurrentRun.CurrentRoom.SpentRerolls then
                spent = rom.game.CurrentRun.CurrentRoom.SpentRerolls[button.RerollId] or 0
            end
            if spent >= chaosMaxRerolls then
                return
            end
            button.Cost = 0
        end

        OriginalAttemptPanelReroll(screen, button)
    end

    print("[ChaosRerolls] Hooked AttemptPanelReroll")
end)
