-- SteadyGrowthFaster
-- Reduces the number of encounters needed for Steady Growth upgrades by 1
--
-- Original values: Common=6, Rare=5, Epic=4, Heroic=3
-- New values:      Common=5, Rare=4, Epic=3, Heroic=2

rom.game.OnReady(function()
    -- Modify the BoonGrowthBoon property of Demeter's Steady Growth trait
    -- The Multiplier is a fraction of the base threshold (6 encounters)
    -- To reduce by 1 encounter, we adjust the multipliers accordingly

    local traitData = TraitData.DemeterBoonGrowthBoon

    if traitData and traitData.BoonGrowthBoon then
        -- Original: Common=1 (6 rooms), Rare=5/6 (5 rooms), Epic=4/6 (4 rooms), Heroic=3/6 (3 rooms)
        -- New:      Common=5/6 (5 rooms), Rare=4/6 (4 rooms), Epic=3/6 (3 rooms), Heroic=2/6 (2 rooms)

        if traitData.BoonGrowthBoon.Common then
            traitData.BoonGrowthBoon.Common.Multiplier = 5/6
        end

        if traitData.BoonGrowthBoon.Rare then
            traitData.BoonGrowthBoon.Rare.Multiplier = 4/6
        end

        if traitData.BoonGrowthBoon.Epic then
            traitData.BoonGrowthBoon.Epic.Multiplier = 3/6
        end

        if traitData.BoonGrowthBoon.Heroic then
            traitData.BoonGrowthBoon.Heroic.Multiplier = 2/6
        end

        print("[SteadyGrowthFaster] Steady Growth encounter requirements reduced by 1")
    else
        print("[SteadyGrowthFaster] Warning: Could not find DemeterBoonGrowthBoon trait data")
    end
end)
