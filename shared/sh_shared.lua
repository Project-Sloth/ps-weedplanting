Shared = Shared or {}

Shared.rayCastingDistance = 7.0 -- distance in meters
Shared.Inventory = 'exports' -- 'exports' for inventory exports, 'player' for player class functions
Shared.ClearOnStartup = true -- Clear dead plants on script start-up
Shared.FireTime = 10000
Shared.AddWaterAmount = 50 -- Amount of water that is added when watering a plant
Shared.AddFertilizerAmount = 50 -- Amount of fertilizer that is added

Shared.GrowTime = 180 -- Time in minutes for a plant to grow from 0 to 100
Shared.LoopUpdate = 30 -- Time in minutes to perform a loop update for water, nutrition, health, growth, etc.
Shared.FertilizerUpdate = {14, 20} -- Amount of fertilizer that gets removed every interval
Shared.WaterUpdate = {14, 20} -- Amount of water that gets removed every interval
Shared.FertilizerThreshold = {60, 20}
Shared.WaterThreshold = {60, 20}
Shared.HealthBaseDecay = {7, 10} -- Amount that health decays when the plant is below a certain threshold for water and nutrition
Shared.HealthDecayMultiplier = 1.2 -- Multiplier for amount of health that decays when second threshold is reached

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
