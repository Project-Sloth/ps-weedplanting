Shared = Shared or {}

--- Other
Shared.Debug = false
Shared.CopJob = "leo"
Shared.Dispatch = "ps-dispatch"

--- Items
Shared.MaleSeed = 'weedplant_seedm'
Shared.FemaleSeed = 'weedplant_seedf'
Shared.PlantTubItem = 'plant_tub'
Shared.EmptyCanItem = 'empty_watering_can'
Shared.FullCanItem = 'full_watering_can'
Shared.FertilizerItem = 'weed_nutrition'
Shared.WaterItem = 'water_bottle'
Shared.BranchItem = 'weedplant_branch'
Shared.WeedItem = 'weedplant_weed'
Shared.PackedWeedItem = 'weedplant_packedweed'
Shared.SusPackageItem = 'weedplant_package'
Shared.LabkeyItem = 'keya' -- Key required to enter the weed lab

--- Weed Processing | Weed-Lab
Shared.WeedLab = {
    EnableTp = true, -- Set this to false if you do not want to use this teleportation system. 
    RequireKey = true,  -- Set this to false to disable the requirement of a lab key to enter the weed lab (set to true if you want to use the key)
    EnableSound = true, --  Set this to false if you dont want the interact sound while exiting / entering the wee lab.
}

--- Props
Shared.WeedProps = {
    [1] = `bkr_prop_weed_01_small_01b`,
    [2] = `bkr_prop_weed_med_01a`,
    [3] = `bkr_prop_weed_med_01b`,
    [4] = `bkr_prop_weed_lrg_01a`,
    [5] = `bkr_prop_weed_lrg_01b`
}

Shared.ProcessingProps = {
    {model = "bkr_prop_weed_table_01a",    coords = vector4(1045.41, -3197.64, -38.13, 270),},
    {model = "hei_prop_heist_weed_pallet", coords = vector4(1044.89, -3192.6, -37.91, 196.56),},
    {model = "hei_prop_heist_weed_pallet", coords = vector4(1043.07, -3192.55, -37.91, 183.94),},
    {model = "hei_prop_heist_weed_pallet", coords = vector4(1041.27, -3192.61, -37.91, 183.98),},
    {model = "hei_prop_heist_weed_pallet", coords = vector4(1042.64, -3206.14, -37.85, 21.93),},
}

Shared.PackageProp = `prop_mp_drug_package`

--- Growing Related Settings
Shared.rayCastingDistance = 7.0 -- distance in meters
Shared.ClearOnStartup = true -- Clear dead plants on script start-up
Shared.ObjectZOffset = - 0.5 -- Z-coord offset for WeedProps
Shared.FireTime = 10000

Shared.GrowTime = 180 -- Time in minutes for a plant to grow from 0 to 100
Shared.LoopUpdate = 15 -- Time in minutes to perform a loop update for water, nutrition, health, growth, etc.
Shared.WaterDecay = 0.4 -- Percent of water that decays every minute
Shared.FertilizerDecay = 0.4 -- Percent of fertilizers that decays every minute

Shared.FertilizerThreshold = 40
Shared.WaterThreshold = 40
Shared.HealthBaseDecay = {7, 10} -- Min/Max Amount of health decay when the plant is below the above thresholds for water and nutrition

--- Weedrun Related Settings
Shared.WeedRunStart = vector4(428.19, -1515.52, 29.29, 203.72)
Shared.PedModel = 'a_m_y_breakdance_01'
Shared.PackageTime = 2 -- Time in minutes to wait for packaging
Shared.DeliveryWaitTime = {8, 12} -- Time in seconds (min, max) the player has to wait to receive a new delivery location
Shared.CallCopsChance = 20 -- 20%
Shared.PayOut = {16000, 20000} -- Min/max payout for delivering a suspicious package

Shared.DropOffLocations = { -- Drop-off locations
    vector4(74.5, -762.17, 31.68, 160.98),
    vector4(100.58, -644.11, 44.23, 69.11),
    vector4(175.45, -445.95, 41.1, 92.72),
    vector4(130.3, -246.26, 51.45, 219.63),
    vector4(198.1, -162.11, 56.35, 340.09),
    vector4(341.0, -184.71, 58.07, 159.33),
    vector4(-26.96, -368.45, 39.69, 251.12),
    vector4(-155.88, -751.76, 33.76, 251.82),
    vector4(-305.02, -226.17, 36.29, 306.04),
    vector4(-347.19, -791.04, 33.97, 3.06),
    vector4(-703.75, -932.93, 19.22, 87.86),
    vector4(-659.35, -256.83, 36.23, 118.92),
    vector4(-934.18, -124.28, 37.77, 205.79),
    vector4(-1214.3, -317.57, 37.75, 18.39),
    vector4(-822.83, -636.97, 27.9, 160.23),
    vector4(308.04, -1386.09, 31.79, 47.23),
    vector4(-1041.13, -392.04, 37.81, 25.98),
    vector4(-731.69, -291.67, 36.95, 330.53),
    vector4(-835.17, -353.65, 38.68, 265.05),
    vector4(-1062.43, -436.19, 36.63, 121.55),
    vector4(-1147.18, -520.47, 32.73, 215.39),
    vector4(-1174.68, -863.63, 14.11, 34.24),
    vector4(-1688.04, -1040.9, 13.02, 232.85),
    vector4(-1353.48, -621.09, 28.24, 300.64),
    vector4(-1029.98, -814.03, 16.86, 335.74),
    vector4(-893.09, -723.17, 19.78, 91.08),
    vector4(-789.23, -565.2, 30.28, 178.86),
    vector4(-345.48, -1022.54, 30.53, 341.03),
    vector4(218.9, -916.12, 30.69, 6.56),
    vector4(57.66, -1072.3, 29.45, 245.38)
}

Shared.DropOffPeds = { -- Drop-off ped models
	'a_m_y_stwhi_02',
	'a_m_y_stwhi_01',
	'a_f_y_genhot_01',
	'a_f_y_vinewood_04',
	'a_m_m_golfer_01',
	'a_m_m_soucent_04',
	'a_m_o_soucent_02',
	'a_m_y_epsilon_01',
	'a_m_y_epsilon_02',
	'a_m_y_mexthug_01'
}
