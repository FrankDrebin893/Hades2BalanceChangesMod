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
            if rom.ImGui.MenuItem(opt.name, nil, selectedGodIndex == idx) then
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
