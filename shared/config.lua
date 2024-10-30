Config = {
    --- Compatibility Settings
    Resource = GetCurrentResourceName(),
    Lang = 'en', -- check the prefixes in the locales folder or create your own
    Target = 'qb-target', -- 'qb-target' or 'ox_target'
    Inventory = 'qb-inventory', -- 'ox_inventory', 'qb-inventory' or 'ps-inventory'
    Logging = 'qb', -- 'ox_lib' or 'qb' or 'esx'

    --- Items
    MaleSeed = 'weedplant_seedm',
    FemaleSeed = 'weedplant_seedf',
    FertilizerItem = 'weed_nutrition',
    WaterItem = 'water',
    BranchItem = 'weedplant_branch',
    WeedItem = 'weedplant_weed',
    PackedWeedItem = 'weedplant_packedweed',
    SusPackageItem = 'weedplant_package',

    --- Props
    WeedProps = {
        [1] = joaat('bkr_prop_weed_01_small_01b'),
        [2] = joaat('bkr_prop_weed_med_01a'),
        [3] = joaat('bkr_prop_weed_med_01b'),
        [4] = joaat('bkr_prop_weed_lrg_01a'),
        [5] = joaat('bkr_prop_weed_lrg_01b')
    },

    PackageProp = joaat('prop_mp_drug_package'),

    --- Ground MaterialHash
    GroundHashes = {
        [1333033863] = true,
        [-1286696947] = true,
        [223086562] = true,
        [-1885547121] = true,
        [-461750719] = true,
        [951832588] = true,
        [-1942898710] = true,
        [510490462] = true,
    },

    --- Growing Related Settings
    rayCastingDistance = 7.0, -- distance in meters
    ClearOnStartup = true, -- Clear dead plants on script start-up
    ObjectZOffset = - 0.5, -- Z-coord offset for WeedProps
    FireTime = 10000, -- Time in milliseconds

    GrowTime = 180, -- Time in minutes for a plant to grow from 0 to 100
    LoopUpdate = 15, -- Time in minutes to perform a loop update for water, nutrition, health, growth, etc.
    WaterDecay = 0.5, -- Percent of water that decays every minute
    FertilizerDecay = 0.5, -- Percent of fertilizers that decays every minute

    FertilizerThreshold = 50,
    WaterThreshold = 40,
    HealthBaseDecay = {10, 13}, -- Min/Max Amount of health decay when the plant is below the above thresholds for water and nutrition

    --- Weedrun Related Settings
    WeedRunStart = vec4(-36.85, 1947.46, 190.19, 168.51),
    PedModel = 'a_m_y_breakdance_01',
    PackageTime = 2, -- Time in minutes to wait for packaging
    DeliveryWaitTime = {8, 12}, -- Time in seconds (min, max) the player has to wait to receive a new delivery location
    CallCopsChance = 80, -- 80%
    PayOut = {1000, 1250}, -- Min/max payout for delivering a suspicious package

    DropOffLocations = { -- Drop-off locations
        vec4(74.5, -762.17, 31.68, 160.98),
        vec4(100.58, -644.11, 44.23, 69.11),
        vec4(175.45, -445.95, 41.1, 92.72),
        vec4(130.3, -246.26, 51.45, 219.63),
        vec4(198.1, -162.11, 56.35, 340.09),
        vec4(341.0, -184.71, 58.07, 159.33),
        vec4(-26.96, -368.45, 39.69, 251.12),
        vec4(-155.88, -751.76, 33.76, 251.82),
        vec4(-305.02, -226.17, 36.29, 306.04),
        vec4(-347.19, -791.04, 33.97, 3.06),
        vec4(-703.75, -932.93, 19.22, 87.86),
        vec4(-659.35, -256.83, 36.23, 118.92),
        vec4(-934.18, -124.28, 37.77, 205.79),
        vec4(-1214.3, -317.57, 37.75, 18.39),
        vec4(-822.83, -636.97, 27.9, 160.23),
        vec4(308.04, -1386.09, 31.79, 47.23),
        vec4(-1041.13, -392.04, 37.81, 25.98),
        vec4(-731.69, -291.67, 36.95, 330.53),
        vec4(-835.17, -353.65, 38.68, 265.05),
        vec4(-1062.43, -436.19, 36.63, 121.55),
        vec4(-1147.18, -520.47, 32.73, 215.39),
        vec4(-1174.68, -863.63, 14.11, 34.24),
        vec4(-1688.04, -1040.9, 13.02, 232.85),
        vec4(-1353.48, -621.09, 28.24, 300.64),
        vec4(-1029.98, -814.03, 16.86, 335.74),
        vec4(-893.09, -723.17, 19.78, 91.08),
        vec4(-789.23, -565.2, 30.28, 178.86),
        vec4(-345.48, -1022.54, 30.53, 341.03),
        vec4(218.9, -916.12, 30.69, 6.56),
        vec4(57.66, -1072.3, 29.45, 245.38)
    },

    DropOffPeds = { -- Drop-off ped models
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
}
