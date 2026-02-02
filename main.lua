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
