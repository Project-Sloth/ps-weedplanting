Shared = Shared or {}

Shared.rayCastingDistance = 7.0 -- distance in meters
Shared.Inventory = 'exports' -- 'exports' for inventory exports, 'player' for player class functions
Shared.ClearOnStartup = true -- Clear dead plants on script start-up
Shared.FireTime = 10000
Shared.AddWaterAmount = 50 -- Amount of water that is added when watering a plant
Shared.AddFertilizerAmount = 50 -- Amount of fertilizer that is added

--- Items
Shared.MaleSeed = 'weedplant_seedm'
Shared.FemaleSeed = 'weedplant_seedf'
Shared.BranchItem = 'weedplant_branch'
Shared.WeedItem = 'weedplant_weed'
Shared.FertilizerItem = 'weed_nutrition'
Shared.WaterItem = 'water_bottle'

--- Props
Shared.WeedProps = {
    [1] = `bkr_prop_weed_01_small_01b`,
    [2] = `bkr_prop_weed_med_01a`,
    [3] = `bkr_prop_weed_med_01b`,
    [4] = `bkr_prop_weed_lrg_01a`,
    [5] = `bkr_prop_weed_lrg_01b`
}
