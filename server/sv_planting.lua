local WeedPlants = {}

local HealthBaseDecay = math.random(Config.HealthBaseDecay[1], Config.HealthBaseDecay[2])

--- Functions

--- Rounds a given numeric value to the specified number of decimal places.
---@param value number - The numeric value to be rounded.
---@param numDecimalPlaces number | nil - (Optional) The number of decimal places to round to. If not provided, the value will be rounded to the nearest integer.
---@return number - The rounded value.
local round = function(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces

    return math.floor((value * power) + 0.5) / (power)
end

--- Method to calculate the growth percentage for a given WeedPlants id
---@param k number - WeedPlant id
---@return number - growth index [0-100]
local calcGrowth = function(k)
    if not WeedPlants[k] then return nil end

    local current_time = os.time()
    local growTime = Config.GrowTime * 60
    local progress = os.difftime(current_time, WeedPlants[k].time)
    local growth = round(progress * 100 / growTime, 2)

    return math.min(growth, 100.00)
end

--- Method to calculate the growth stage of a weed plant for a given growth index
---@param growth number - growth index [0-100]
---@return number - growth stage number [1-5]
local calcStage = function(growth)
    local growthThreshold = 20
    
    return math.min(5, math.floor((growth - 1) / growthThreshold) + 1)
end

--- Method to calculate the current fertilizer percentage for a given WeedPlants id
---@param k number - WeedPlant id
---@return number - fertilizer index [0-100]
local calcFertilizer = function(k)
    if not WeedPlants[k] then return nil end

    local current_time = os.time()

    if #WeedPlants[k].fertilizer == 0 then
        return 0
    else
        local last_fertilizer = WeedPlants[k].fertilizer[#WeedPlants[k].fertilizer]

        if not last_fertilizer then
            return 0
        end

        local time_elapsed = os.difftime(current_time, last_fertilizer)
        local fertilizer = round(100 - (time_elapsed / 60 * Config.FertilizerDecay), 2)

        return math.max(fertilizer, 0.00)
    end
end

--- Method to calculate the current water percentage for a given WeedPlants id
---@param k number - WeedPlant id
---@return number - water index [0-100]
local calcWater = function(k)
    if not WeedPlants[k] then return nil end

    local current_time = os.time()

    if #WeedPlants[k].water == 0 then
        return 0
    else
        local last_water = WeedPlants[k].water[#WeedPlants[k].water]
        if not last_water then
            return 0
        end
        local time_elapsed = os.difftime(current_time, last_water)
        local water = round(100 - (time_elapsed / 60 * Config.WaterDecay), 2)
        return math.max(water, 0.00)
    end
end

--- Method to calculate the health percentage for a given WeedPlants id
---@param k number - WeedPlant id
---@return number - health index [0-100]
local calcHealth = function(k)
    if not WeedPlants[k] then return false end

    local health = 100
    local current_time = os.time()
    local planted_time = WeedPlants[k].time
    local elapsed_time = os.difftime(current_time, planted_time)
    local intervals = math.floor(elapsed_time / 60 / Config.LoopUpdate)

    if intervals == 0 then return 100 end

    for i = 1, intervals do
        local interval_time = planted_time + math.floor(i * Config.LoopUpdate * 60)

        if #WeedPlants[k].fertilizer == 0 then
            health -= HealthBaseDecay
        else
            -- Find last_fertilizer time before interval_time
            local last_fertilizer = planted_time

            for j = 1, #WeedPlants[k].fertilizer, 1 do
                if WeedPlants[k].fertilizer[j] < interval_time then
                    last_fertilizer = math.max(last_fertilizer, WeedPlants[k].fertilizer[j])
                end
            end

            local time_since_fertilizer = os.difftime(interval_time, last_fertilizer)

            local fertilizer_amount = math.max(round(100 - (time_since_fertilizer / 60 * Config.FertilizerDecay), 2), 0.00)

            if last_fertilizer == planted_time or fertilizer_amount < Config.FertilizerThreshold then
                health -= HealthBaseDecay
            end
        end
    
        if #WeedPlants[k].water == 0 then
            health -= HealthBaseDecay
        else
            -- Find last_water time before interval_time
            local last_water = planted_time

            for j = 1, #WeedPlants[k].water, 1 do
                if WeedPlants[k].water[j] < interval_time then
                    last_water = math.max(last_water, WeedPlants[k].water[j])
                end
            end

            local time_since_water = os.difftime(interval_time, last_water)
            local water_amount = math.max(round(100 - (time_since_water / 60 * Config.WaterDecay), 2), 0.00)

            if last_water == planted_time or water_amount < Config.WaterThreshold then
                health -= HealthBaseDecay
            end
        end
    end

    return math.max(health, 0.0)
end

--- Method to setup all the weedplants, fetched from the database
---@return nil
local setupPlants = function()
    local result = MySQL.Sync.fetchAll([[
        SELECT * 
        FROM `weedplants`
    ]])

    local current_time = os.time()
    local growTime = Config.GrowTime * 60

    for k, v in pairs(result) do
        local progress = os.difftime(current_time, v.time)
        local growth = math.min(round(progress * 100 / growTime, 2), 100.00)
        local stage = calcStage(growth)

        local ModelHash = Config.WeedProps[stage]
        local coords = json.decode(v.coords)
        local plant = CreateObjectNoOffset(ModelHash, coords.x, coords.y, coords.z + Config.ObjectZOffset, true, true, false)

        FreezeEntityPosition(plant, true)

        local state = Entity(plant).state

        if state and not state.weedplanting then
            state:set('weedplanting', v.id, true)
        end
        
        WeedPlants[v.id] = {
            id = v.id,
            entity = plant,
            coords = vec3(coords.x, coords.y, coords.z),
            time = v.time,
            fertilizer = json.decode(v.fertilizer),
            water = json.decode(v.water),
            gender = v.gender
        }
    end
end

--- Method to delete all cached weed plants and their entities
---@return nil
local destroyAllPlants = function()    
    for k, v in pairs(WeedPlants) do
        if DoesEntityExist(v.entity) then
            DeleteEntity(v.entity)
            WeedPlants[k] = nil
        end
    end
end

--- Method to update a plant object, removing the existing one and placing a new object
---@param k number - WeedPlant id
---@param stage number - Stage number
---@return nil
local updatePlantProp = function(k, stage)
    if not WeedPlants[k] then return end

    if not DoesEntityExist(WeedPlants[k].entity) then return end
    DeleteEntity(WeedPlants[k].entity)

    local ModelHash = Config.WeedProps[stage]
    local plant = CreateObjectNoOffset(ModelHash, WeedPlants[k].coords.x, WeedPlants[k].coords.y, WeedPlants[k].coords.z + Config.ObjectZOffset, true, true, false)
    FreezeEntityPosition(plant, true)
    WeedPlants[k].entity = plant

    local state = Entity(plant).state

    if state and not state.weedplanting then
        state:set('weedplanting', WeedPlants[k].id, true)
    end
end

--- Method to perform an update on every weedplant, updating their prop if needed, repeats every Config.LoopUpdate minutes
---@return nil
updatePlants = function()
    for k, v in pairs(WeedPlants) do
        local growth = calcGrowth(k)
        local stage = calcStage(growth)

        if stage ~= v.stage then
            WeedPlants[k].stage = stage
            updatePlantProp(k, stage)
        end
    end

    SetTimeout(Config.LoopUpdate * 60 * 1000, updatePlants)
end

--- Resource start/stop events

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    setupPlants()

    if Config.ClearOnStartup then
        Wait(5000) -- Wait 5 seconds to allow all functions to be executed on startup

        for k, v in pairs(WeedPlants) do
            if calcHealth(k) == 0 then
                DeleteEntity(v.entity)

                MySQL.query([[
                    DELETE FROM `weedplants`
                    WHERE `id` = :id
                ]], {
                    ['id'] = v.id
                })

                utils.print('Clear on startup plant ' .. v.id)

                WeedPlants[k] = nil
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= Config.Resource then return end

    destroyAllPlants()
end)

--- Events

RegisterNetEvent('weedplanting:server:CreateNewPlant', function(coords)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local PlayerData = server.getPlayerData(Player)

    if #(GetEntityCoords(GetPlayerPed(src)) - coords) > Config.rayCastingDistance + 10 then return end

    if server.removeItem(src, Config.FemaleSeed, 1) then
        local ModelHash = Config.WeedProps[1]
        local plant = CreateObjectNoOffset(ModelHash, coords.x, coords.y, coords.z + Config.ObjectZOffset, true, true, false)
        FreezeEntityPosition(plant, true)
        local time = os.time()

        MySQL.insert([[
            INSERT INTO `weedplants` (`coords`, `time`, `fertilizer`, `water`, `gender`)
            VALUES (:coords, :time, :fertilizer, :water, :gender)
        ]], {
            ['coords'] = json.encode(coords),
            ['time'] = time,
            ['fertilizer'] = json.encode({}),
            ['water'] = json.encode({}),
            ['gender'] = 'female'
        }, function(data)
            WeedPlants[data] = {
                id = data,
                entity = plant,
                coords = coords,
                time = time,
                fertilizer = {},
                water = {},
                gender = 'female'
            }

            local state = Entity(plant).state

            if state and not state.weedplanting then
                state:set('weedplanting', data, true)
            end

            server.createLog(PlayerData.name, 'New Plant', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' placed new plant ' .. coords)
        end)
    end
end)

RegisterNetEvent('weedplanting:server:PoliceDestroy', function(netId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local PlayerData = server.getPlayerData(Player)

    if not server.isPlayerPolice(Player) then return end

    local entity = NetworkGetEntityFromNetworkId(netId)
    local state = entity and Entity(entity)?.state
    local id = state?.weedplanting

    if not WeedPlants[id] then return end

    local plant = WeedPlants[id].entity
    local coords = WeedPlants[id].coords
    
    if #(GetEntityCoords(GetPlayerPed(src)) - coords) > 10 then return end

    if DoesEntityExist(WeedPlants[id].entity) then
        MySQL.query([[
            DELETE FROM `weedplants`
            WHERE `id` = :id
        ]], {
            ['id'] = WeedPlants[id].id
        })

        WeedPlants[id] = nil

        TriggerClientEvent('weedplanting:client:FireGoBrrrrrrr', -1, coords)
        Wait(Config.FireTime)
        DeleteEntity(plant)

        server.createLog(PlayerData.name, 'Police Destroy', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' destroyed plant ' .. id)
    end
end)

RegisterNetEvent('weedplanting:server:ClearPlant', function(netId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local PlayerData = server.getPlayerData(Player)

    local entity = NetworkGetEntityFromNetworkId(netId)
    local state = entity and Entity(entity)?.state
    local id = state?.weedplanting

    if not WeedPlants[id] then return end

    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[id].coords) > 10 then return end

    if calcHealth(id) ~= 0 then return end

    if DoesEntityExist(WeedPlants[id].entity) then
        DeleteEntity(WeedPlants[id].entity)

        MySQL.query([[
            DELETE FROM `weedplants`
            WHERE `id` = :id
        ]], {
            ['id'] = WeedPlants[id].id
        })

        WeedPlants[id] = nil

        server.createLog(PlayerData.name, 'Clear Plant', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' cleared plant ' .. id)
    end
end)

RegisterNetEvent('weedplanting:server:HarvestPlant', function(netId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local PlayerData = server.getPlayerData(Player)

    local entity = NetworkGetEntityFromNetworkId(netId)
    local state = entity and Entity(entity)?.state
    local id = state?.weedplanting

    if not WeedPlants[id] then return end
    
    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[id].coords) > 10 then return end

    if calcGrowth(id) ~= 100 then return end

    if DoesEntityExist(WeedPlants[id].entity) then
        local health = calcHealth(id)
        local gender = WeedPlants[id].gender

        if gender == 'female' then
            local metaData = { health = health }

            server.addItem(src, Config.BranchItem, 1, metaData)
        else -- male seed added
            local mSeeds = math.floor(health / 20)
            server.addItem(src, Config.MaleSeed, mSeeds)

            local fSeeds = math.floor(health / 20)
            server.addItem(src, Config.FemaleSeed, fSeeds)
        end
        
        DeleteEntity(WeedPlants[id].entity)

        MySQL.query([[
            DELETE FROM `weedplants`
            WHERE `id` = :id
        ]], {
            ['id'] = WeedPlants[id].id
        })

        WeedPlants[id] = nil

        server.createLog(PlayerData.name, 'Harvest Plant', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' harvested plant: ' .. id .. ' Gender: ' .. gender .. ' Health: ' .. health)
    end
end)

RegisterNetEvent('weedplanting:server:GiveWater', function(netId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end
    
    local entity = NetworkGetEntityFromNetworkId(netId)
    local state = entity and Entity(entity)?.state
    local id = state?.weedplanting

    if not WeedPlants[id] then return end

    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[id].coords) > 10 then return end

    if exports['ox_inventory']:RemoveItem(src, Config.WaterItem, 1) then        
        WeedPlants[id].water[#WeedPlants[id].water + 1] = os.time()

        MySQL.update([[
            UPDATE `weedplants`
            SET `water` = (:water)
            WHERE `id` = (:id)
        ]], { 
            ['water'] = json.encode(WeedPlants[id].water),
            ['id'] = WeedPlants[id].id,
        })

        utils.notify(src, Locales['notify_title_planting'], Locales['watered_plant'], 'success', 2500)
    end
end)

RegisterNetEvent('weedplanting:server:GiveFertilizer', function(netId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local entity = NetworkGetEntityFromNetworkId(netId)
    local state = entity and Entity(entity)?.state
    local id = state?.weedplanting

    if not WeedPlants[id] then return end
    
    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[id].coords) > 10 then return end

    if exports['ox_inventory']:RemoveItem(src, Config.FertilizerItem, 1) then
        WeedPlants[id].fertilizer[#WeedPlants[id].fertilizer + 1] = os.time()
        
        MySQL.update([[
            UPDATE `weedplants`
            SET `fertilizer` = (:fertilizer)
            WHERE `id` = (:id)
        ]], {
            ['fertilizer'] = json.encode(WeedPlants[id].fertilizer),
            ['id'] = WeedPlants[id].id,
        })

        utils.notify(src, Locales['notify_title_planting'], Locales['fertilizer_added'], 'success', 2500)
    end
end)

RegisterNetEvent('weedplanting:server:AddMaleSeed', function(netId)
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local entity = NetworkGetEntityFromNetworkId(netId)
    local state = entity and Entity(entity)?.state
    local id = state?.weedplanting

    if not WeedPlants[id] then return end
    
    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[id].coords) > 10 then return end

    if exports['ox_inventory']:RemoveItem(src, Config.MaleSeed, 1) then
        WeedPlants[id].gender = 'male'

        MySQL.update([[
            UPDATE `weedplants`
            SET `gender` = (:gender)
            WHERE `id` = (:id)
        ]], {
            ['gender'] = WeedPlants[id].gender,
            ['id'] = WeedPlants[id].id,
        })

        utils.notify(src, Locales['notify_title_planting'], Locales['male_seed_added'], 'success', 2500)
    end
end)

--- Callbacks

lib.callback.register('weedplanting:server:GetPlantData', function(source, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    local state = entity and Entity(entity)?.state
    local id = state?.weedplanting

    if not WeedPlants[id] then return nil end
    
    local temp = {
        id = WeedPlants[id].id,
        coords = WeedPlants[id].coords,
        time = WeedPlants[id].time,
        fertilizer = calcFertilizer(id),
        water = calcWater(id),
        gender = WeedPlants[id].gender,
        stage = calcStage(calcGrowth(id)),
        health = calcHealth(id),
        growth = calcGrowth(id)
    }

    return temp
end)

--- Items

server.registerUseableItem(Config.FemaleSeed, function(source)
    TriggerClientEvent('weedplanting:client:UseWeedSeed', source)
end)

--- Threads

CreateThread(function()
    Wait(Config.LoopUpdate * 60 * 1000)
    updatePlants()
end)
