local globalState = GlobalState
local HealthBaseDecay = math.random(Config.HealthBaseDecay[1], Config.HealthBaseDecay[2])

local WeedPlantCache = {}

-- WeedPlant class
-- Represents an individual weed plant with properties for tracking growth, health, water, and fertilizer levels.
-- Each plant is stored in the global WeedPlants table and managed via MySQL.

--- @type table<any, WeedPlant>
--- Global table holding all WeedPlant instances, keyed by their unique ID.
local WeedPlants = {}

--- @class WeedPlant
--- @field id number The unique identifier of the weed plant.
--- @field coords vector3 The coordinates of the weed plant in the game world.
--- @field time number The planting time (Unix timestamp).
--- @field gender string The gender of the plant, "female" or "male".
--- @field fertilizer table A table containing timestamps of fertilizer applications.
--- @field water table A table containing timestamps of water applications.

local WeedPlant = {}
WeedPlant.__index = WeedPlant

--- Creates a new WeedPlant instance.
--- @param id number The unique identifier of the weed plant.
--- @param coords vector3 The coordinates of the weed plant in the game world.
--- @param time number The planting time (Unix timestamp).
--- @param gender string The gender of the plant, "female" or "male".
--- @param fertilizer table A table containing timestamps of fertilizer applications.
--- @param water table A table containing timestamps of water applications.
--- @return DrugLab The created DrugLab object.
function WeedPlant:create(id, coords, time, gender, fertilizer, water)
    local plant = setmetatable({}, WeedPlant)

    plant.id = id
    plant.coords = coords
    plant.time = time or os.time()
    plant.gender = gender or "female"
    plant.fertilizer = fertilizer or {}
    plant.water = water or {}

    WeedPlants[id] = plant
    WeedPlantCache[id] = {
        coords = coords,
        time = time
    }

    return plant
end

--- Inserts a new weed plant into the database, creating a new WeedPlant instance.
--- @param coords (vector3) - Coordinates of the plant
--- @return plant (WeedPlant) or false, error message if failed
function WeedPlant:new(coords)
    if not coords or type(coords) ~= "vector3" then
        return false, "Coords must be a vector3"
    end

    local time = os.time()

    local id = MySQL.insert.await([[
        INSERT INTO `weedplants` (`coords`, `time`, `fertilizer`, `water`, `gender`)
        VALUES (:coords, :time, :fertilizer, :water, :gender)
    ]], {
        coords = json.encode(coords),
        time = os.date('%Y-%m-%d %H:%M:%S', time),
        fertilizer = json.encode({}),
        water = json.encode({}),
        gender = 'female'
    })

    if not id then
        return false, "Failed to insert new weedplant into database"
    end

    -- Create and return the WeedPlant object using newly generated ID.
    local plant = WeedPlant:create(id, coords, time, 'female', {}, {})

    -- Update clients cache
    TriggerClientEvent('weedplanting:client:NewPlant', -1, id, coords, time)
    
    return plant
end

--- Removes the plant from the database and clears it from WeedPlants.
--- Optionally triggers a fire effect if policeDestroy is true.
--- @param policeDestroy (boolean) - Indicates if the plant is destroyed by police
--- @return success (boolean), message (string)
function WeedPlant:remove(policeDestroy)
    local id = self.id
    local coords = self.coords

    local success = MySQL.query.await([[
        DELETE FROM `weedplants`
        WHERE `id` = :id
    ]], { 
        id = id
    })

    WeedPlants[id] = nil
    WeedPlantCache[id] = nil
    
    if policeDestroy then
        TriggerClientEvent('weedplanting:client:FireGoBrrrrrrr', -1, coords)
        Wait(Config.FireTime)
    end

    -- Update clients cache
    TriggerClientEvent('weedplanting:client:RemovePlant', -1, id)

    if success then
        return true, ("Successfully deleted weedplant from database with id %s"):format(id)
    else
        return false, ("Could not delete weedplant from database with id %s"):format(id)
    end
end

--- Sets a specific property of the plant instance.
--- @param property (string) - Property to set
--- @param value - New value for the property
function WeedPlant:set(property, value)
    self[property] = value
end

--- Saves the current state of the plant to the database.
--- @return success (boolean) - True if rows were affected
function WeedPlant:save()
    local affectedRows = MySQL.update.await([[
        UPDATE `weedplants` SET
            `coords` = :coords,
            `time` = :time,
            `fertilizer` = :fertilizer,
            `water` = :water,
            `gender` = :gender
        WHERE `id` = :id
    ]], {
        coords = json.encode(self.coords),
        time = self.time,
        fertilizer = json.encode(self.fertilizer),
        water = json.encode(self.water),
        gender = self.gender,
        id = self.id
    })

    return affectedRows > 0
end

--- Retrieves a WeedPlant instance by its ID.
--- @param id (number) - ID of the plant
--- @return WeedPlant instance or nil if not found
function WeedPlant:getPlant(id)
    return WeedPlants[id]
end

--- Calculates the plant's growth progress as a percentage.
--- @return growth (number) - Growth percentage (0-100)
function WeedPlant:calcGrowth()
    local current_time = os.time()
    local growTime = Config.GrowTime * 60
    local progress = os.difftime(current_time, self.time)
    local growth = lib.math.round(progress * 100 / growTime, 2)

    return math.min(growth, 100.00)
end

--- Determines the growth stage of the plant.
--- @return stage (number) - Growth stage (1-5)
function WeedPlant:calcStage()
    local current_time = os.time()
    local growTime = Config.GrowTime * 60
    local progress = os.difftime(current_time, self.time)
    local growth = math.min(lib.math.round(progress * 100 / growTime, 2), 100.00)

    local growthThreshold = 20
    
    return math.min(5, math.floor((growth - 1) / growthThreshold) + 1)
end

--- Calculates the remaining fertilizer level as a percentage.
--- @return fertilizer (number) - Fertilizer level percentage (0-100)
function WeedPlant:calcFertilizer()
    local current_time = os.time()

    if #self.fertilizer == 0 then
        return 0
    else
        local last_fertilizer = self.fertilizer[#self.fertilizer]
        local time_elapsed = os.difftime(current_time, last_fertilizer)
        local fertilizer = lib.math.round(100 - (time_elapsed / 60 * Config.FertilizerDecay), 2)

        return math.max(fertilizer, 0.00)
    end
end

--- Calculates the remaining water level as a percentage.
--- @return water (number) - Water level percentage (0-100)
function WeedPlant:calcWater()
    local current_time = os.time()

    if #self.water == 0 then
        return 0
    else
        local last_water = self.water[#self.water]
        local time_elapsed = os.difftime(current_time, last_water)
        local water = lib.math.round(100 - (time_elapsed / 60 * Config.WaterDecay), 2)

        return math.max(water, 0.00)
    end
end

--- Calculates the overall health of the plant based on water and fertilizer levels over time.
--- @return health (number) - Plant health percentage (0-100)
function WeedPlant:calcHealth()
    local health = 100
    local current_time = os.time()
    local planted_time = self.time
    local elapsed_time = os.difftime(current_time, planted_time)
    local intervals = math.floor(elapsed_time / 60 / Config.LoopUpdate)

    if intervals == 0 then return 100 end

    for i = 1, intervals do
        local interval_time = planted_time + math.floor(i * Config.LoopUpdate * 60)

        if #self.fertilizer == 0 then
            health -= HealthBaseDecay
        else
            -- Find last_fertilizer time before interval_time
            local last_fertilizer = planted_time

            for j = 1, #self.fertilizer, 1 do
                if self.fertilizer[j] < interval_time then
                    last_fertilizer = math.max(last_fertilizer, self.fertilizer[j])
                end
            end

            local time_since_fertilizer = os.difftime(interval_time, last_fertilizer)
            local fertilizer_amount = math.max(lib.math.round(100 - (time_since_fertilizer / 60 * Config.FertilizerDecay), 2), 0.00)

            if last_fertilizer == planted_time or fertilizer_amount < Config.FertilizerThreshold then
                health -= HealthBaseDecay
            end
        end
    
        if #self.water == 0 then
            health -= HealthBaseDecay
        else
            -- Find last_water time before interval_time
            local last_water = planted_time

            for j = 1, #self.water, 1 do
                if self.water[j] < interval_time then
                    last_water = math.max(last_water, self.water[j])
                end
            end

            local time_since_water = os.difftime(interval_time, last_water)
            local water_amount = math.max(lib.math.round(100 - (time_since_water / 60 * Config.WaterDecay), 2), 0.00)

            if last_water == planted_time or water_amount < Config.WaterThreshold then
                health -= HealthBaseDecay
            end
        end
    end

    return math.max(health, 0.0)
end

--- Fetches all data from the database and creates WeedPlant instances
local setupPlants = function()
    local clear = Config.ClearOnStartup
    local result = MySQL.Sync.fetchAll([[
        SELECT * 
        FROM `weedplants`
    ]])

    for _, data in pairs(result) do
        local coords = json.decode(data.coords)
        local fertilizer = json.decode(data.fertilizer)
        local water = json.decode(data.water)
        local time = math.round(data.time / 1000)

        local plant = WeedPlant:create(data.id, vector3(coords.x, coords.y, coords.z), time, data.gender, fertilizer, water)

        if clear then
            if plant:calcHealth() == 0 then
                utils.print(("Clear on startup plant %s"):format(plant.id))
                plant:remove()
            end
        end
    end
end

--- Events

RegisterNetEvent('weedplanting:server:CreateNewPlant', function(coords)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local PlayerData = server.getPlayerData(Player)

    if not coords or type(coords) ~= "vector3" then return end
    if #(GetEntityCoords(GetPlayerPed(src)) - coords) > Config.rayCastingDistance + 10 then return end

    if server.removeItem(src, Config.FemaleSeed, 1) then
        WeedPlant:new(coords)
        server.createLog(PlayerData.name, 'New Plant', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' placed new plant ' .. coords)
    end
end)

RegisterNetEvent('weedplanting:server:ClearPlant', function(plantId, policeDestroy)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local PlayerData = server.getPlayerData(Player)

    local plant = WeedPlant:getPlant(plantId)
    if not plant then return end

    if #(GetEntityCoords(GetPlayerPed(src)) - plant.coords) > 10 then return end

    if policeDestroy and server.isPlayerPolice(Player) then
        plant:remove(true)
        server.createLog(PlayerData.name, 'Police Destroy', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' destroyed plant ' .. plantId)
    elseif not policeDestroy and plant:calcHealth() ~= 0 then
        plant:remove(false)
        server.createLog(PlayerData.name, 'Clear Plant', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' cleared plant ' .. plantId)
    end
end)

RegisterNetEvent('weedplanting:server:HarvestPlant', function(plantId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local PlayerData = server.getPlayerData(Player)

    local plant = WeedPlant:getPlant(plantId)
    if not plant then return end

    if #(GetEntityCoords(GetPlayerPed(src)) - plant.coords) > 10 then return end

    if plant:calcGrowth() ~= 100 then return end

    local health = plant:calcHealth()
    local gender = plant.gender

    if gender == 'female' then
        local metaData = { health = health }
        server.addItem(src, Config.BranchItem, 1, metaData)
    else -- male seed added
        local mSeeds = math.floor(health / 20)
        server.addItem(src, Config.MaleSeed, mSeeds)

        local fSeeds = math.floor(health / 20)
        server.addItem(src, Config.FemaleSeed, fSeeds)
    end

    plant:remove(false)

    server.createLog(PlayerData.name, 'Harvest Plant', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' harvested plant: ' .. id .. ' Gender: ' .. gender .. ' Health: ' .. health)
end)

RegisterNetEvent('weedplanting:server:GiveWater', function(plantId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end
    
    local plant = WeedPlant:getPlant(plantId)
    if not plant then return end

    if #(GetEntityCoords(GetPlayerPed(src)) - plant.coords) > 10 then return end

    if server.removeItem(src, Config.WaterItem, 1) then
        local water = plant.water
        water[#water + 1] = os.time()

        plant:set('water', water)
        local saved = plant:save()

        if not saved then
            utils.print(("Could not save plant with id %s"):format(plantId))
        end

        utils.notify(src, Locales['notify_title_planting'], Locales['watered_plant'], 'success', 2500)
    end
end)

RegisterNetEvent('weedplanting:server:GiveFertilizer', function(plantId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local plant = WeedPlant:getPlant(plantId)
    if not plant then return end

    if #(GetEntityCoords(GetPlayerPed(src)) - plant.coords) > 10 then return end

    if server.removeItem(src, Config.FertilizerItem, 1) then
        local fertilizer = plant.fertilizer
        fertilizer[#fertilizer + 1] = os.time()

        plant:set('fertilizer', fertilizer)
        local saved = plant:save()

        if not saved then
            utils.print(("Could not save plant with id %s"):format(plantId))
        end

        utils.notify(src, Locales['notify_title_planting'], Locales['fertilizer_added'], 'success', 2500)
    end
end)

RegisterNetEvent('weedplanting:server:AddMaleSeed', function(plantId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local plant = WeedPlant:getPlant(plantId)
    if not plant then return end

    if #(GetEntityCoords(GetPlayerPed(src)) - plant.coords) > 10 then return end

    if server.removeItem(src, Config.MaleSeed, 1) then
        plant:set('gender', 'male')
        local saved = plant:save()

        if not saved then
            utils.print(("Could not save plant with id %s"):format(plantId))
        end

        utils.notify(src, Locales['notify_title_planting'], Locales['male_seed_added'], 'success', 2500)
    end
end)

--- Callbacks

lib.callback.register('weedplanting:server:GetPlantData', function(source, plantId)
    local plant = WeedPlant:getPlant(plantId)
    if not plant then
        return false, ("Could not find weedplant with id %s"):format(plantId)
    end
    
    local retData = {
        id = plant.id,
        coords = plant.coords,
        time = plant.time,
        gender = plant.gender,
        fertilizer = plant:calcFertilizer(),
        water = plant:calcWater(),
        stage = plant:calcStage(),
        health = plant:calcHealth(),
        growth = plant:calcGrowth()
    }

    return true, retData
end)

lib.callback.register('weedplanting:server:GetPlantLocations', function(source)
    return(WeedPlantCache)
end)

--- Items

server.registerUseableItem(Config.FemaleSeed, function(source)
    TriggerClientEvent('weedplanting:client:UseWeedSeed', source)
end)

--- Threads

CreateThread(function()
    setupPlants()

    while true do
        globalState.WeedplantingTime = os.time()
        Wait(1000)
    end
end)
