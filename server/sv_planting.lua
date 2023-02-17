QBCore = exports['qb-core']:GetCoreObject()
local WeedPlants = {}

--- Functions

--- Method to calculate the growth percentage for a given WeedPlants index
--- @param k number - WeedPlants table index
--- @return retval number - growth index [0-100]
local calcGrowth = function(k)
    if not WeedPlants[k] then return false end
    local current_time = os.time()
    local growTime = Shared.GrowTime * 60
    local progress = os.difftime(current_time, WeedPlants[k].time)
    local growth = QBCore.Shared.Round(progress * 100 / growTime, 2)
    local retval = math.min(growth, 100.00)
    return retval
end

--- Method to calculate the growth stage of a weedplant for a given growth index
--- @param growth number - growth index [0-100]
--- @return stage number - growth stage number [1-5]
local calcStage = function(growth)
    local stage = math.floor(growth / 20)
    if stage == 0 then stage += 1 end
    return stage
end

--- Method to calculate the health percentage for a given WeedPlants index
--- @param k number - WeedPlants table index
--- @return retval number - health index [0-100]
local calcHealth = function(k)
    if not WeedPlants[k] then return false end
    local current_time = os.time()
    return 100
end

--- Method to calculate the current fertilizer percentage for a given WeedPlants index
--- @param k number - WeedPlants table index
--- @return retval number - fertilizer index [0-100]
local calcFertilizer = function(k)
    if not WeedPlants[k] then return false end
    local current_time = os.time()

    if #WeedPlants[k].fertilizer == 0 then
        return 0
    else
        local last_fertilizer = WeedPlants[k].fertilizer[#WeedPlants[k].fertilizer]
        local time_elapsed = os.difftime(current_time, last_fertilizer)
        local fertilizer = QBCore.Shared.Round(100 - (time_elapsed / 60 * Shared.FertilizerDecay), 2)
        local retval = math.max(fertilizer, 0.00)
        return retval
    end
end

--- Method to calculate the current water percentage for a given WeedPlants index
--- @param k number - WeedPlants table index
--- @return retval number - water index [0-100]
local calcWater = function(k)
    if not WeedPlants[k] then return false end
    local current_time = os.time()

    if #WeedPlants[k].water == 0 then
        return 0
    else
        local last_water = WeedPlants[k].water[#WeedPlants[k].water]
        local time_elapsed = os.difftime(current_time, last_water)
        local water = QBCore.Shared.Round(100 - (time_elapsed / 60 * Shared.WaterDecay), 2)
        local retval = math.max(water, 0.00)
        return retval
    end
end

--- Method to setup all the weedplants, fetched from the database
--- @return nil
local setupPlants = function()
    local result = MySQL.Sync.fetchAll('SELECT * FROM weedplants')
    local current_time = os.time()
    local growTime = Shared.GrowTime * 60

    for k, v in pairs(result) do
        local progress = os.difftime(current_time, v.time)
        local growth = math.min(QBCore.Shared.Round(progress * 100 / growTime, 2), 100.00)
        local stage = calcStage(growth)
        local ModelHash = Shared.WeedProps[stage]
        local coords = json.decode(v.coords)
        local plant = CreateObjectNoOffset(ModelHash, coords.x, coords.y, coords.z + Shared.ObjectZOffset, true, true, false)
        FreezeEntityPosition(plant, true)
        WeedPlants[plant] = {
            id = v.id,
            coords = vector3(coords.x, coords.y, coords.z),
            time = v.time,
            fertilizer = json.decode(v.fertilizer),
            water = json.decode(v.water),
            gender = v.gender
        }
    end
end

--- Method to delete all cached weed plants and their entities
--- @return nil
local destroyAllPlants = function()    
    for k, v in pairs(WeedPlants) do
        if DoesEntityExist(k) then
            DeleteEntity(k)
            WeedPlants[k] = nil
        end
    end
end

--- Method to update a plant object, removing the existing one and placing a new object
--- @param k number - WeedPlants table index
--- @param stage number - Stage number
--- @return nil
local updatePlantProp = function(k, stage)
    if not WeedPlants[k] then return end
    if not DoesEntityExist(k) then return end
    local ModelHash = Shared.WeedProps[stage]
    DeleteEntity(k)
    local plant = CreateObjectNoOffset(ModelHash, WeedPlants[k].coords.x, WeedPlants[k].coords.y, WeedPlants[k].coords.z + Shared.ObjectZOffset, true, true, false)
    FreezeEntityPosition(plant, true)
    WeedPlants[plant] = WeedPlants[k]
    WeedPlants[k] = nil
end

--- Resource start/stop events

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    setupPlants()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    destroyAllPlants()
end)

--- Events

RegisterNetEvent('ps-weedplanting:server:ClearPlant', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not WeedPlants[entity] then return end
    if #(GetEntityCoords(GetPlayerPed(source)) - WeedPlants[entity].coords) > 10 then return end
    if calcHealth(entity) ~= 0 then return end

    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        MySQL.query('DELETE from weedplants WHERE id = :id', {
            ['id'] = WeedPlants[entity].id
        })
        WeedPlants[entity] = nil
    end
end)

RegisterNetEvent('ps-weedplanting:server:HarvestPlant', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not WeedPlants[entity] then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[entity].coords) > 10 then return end
    if calcGrowth(entity) ~= 100 then return end

    if DoesEntityExist(entity) then
        local health = calcHealth(entity)
        if WeedPlants[entity].gender == 'female' then
            local info = { health = health }
            Player.Functions.AddItem(Shared.BranchItem, 1, false, info)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.BranchItem], 'add', 1)
        else -- male seed added
            local mSeeds = math.floor(health / 50)
            local fSeeds = math.floor(health / 20)
            Player.Functions.AddItem(Shared.MaleSeed, mSeeds, false)
            Player.Functions.AddItem(Shared.FemaleSeed, fSeeds, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.MaleSeed], 'add', mSeeds)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.FemaleSeed], 'add', fSeeds)
        end
        
        DeleteEntity(entity)
        MySQL.query('DELETE from weedplants WHERE id = :id', {
            ['id'] = WeedPlants[entity].id
        })
        WeedPlants[entity] = nil
    end
end)

RegisterNetEvent('ps-weedplanting:server:PoliceDestroy', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not WeedPlants[entity] then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end
    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[entity].coords) > 10 then return end

    if DoesEntityExist(entity) then
        MySQL.query('DELETE from weedplants WHERE id = :id', {
            ['id'] = WeedPlants[entity].id
        })
        WeedPlants[entity] = nil

        TriggerClientEvent('ps-weedplanting:client:FireGoBrrrrrrr', -1, WeedPlants[entity].coords)
        Wait(Shared.FireTime)
        DeleteEntity(entity)
    end
end)

RegisterNetEvent('ps-weedplanting:server:GiveWater', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not WeedPlants[entity] then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[entity].coords) > 10 then return end

    if Player.Functions.RemoveItem(Shared.WaterItem, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WaterItem], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('watered_plant'), 'success', 2500)
        
        WeedPlants[entity].water[#WeedPlants[entity].water + 1] = os.time()
        MySQL.update('UPDATE weedplants SET water = (:water) WHERE id = (:id)', {
            ['water'] = json.encode(WeedPlants[entity].water),
            ['id'] = WeedPlants[entity].id,
        })
    end
end)

RegisterNetEvent('ps-weedplanting:server:GiveFertilizer', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not WeedPlants[entity] then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[entity].coords) > 10 then return end

    if Player.Functions.RemoveItem(Shared.FertilizerItem, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.FertilizerItem], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('fertilizer_added'), 'success', 2500)
        
        WeedPlants[entity].fertilizer[#WeedPlants[entity].fertilizer + 1] = os.time()
        MySQL.update('UPDATE weedplants SET fertilizer = (:fertilizer) WHERE id = (:id)', {
            ['fertilizer'] = json.encode(WeedPlants[entity].fertilizer),
            ['id'] = WeedPlants[entity].id,
        })
    end
end)

RegisterNetEvent('ps-weedplanting:server:AddMaleSeed', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not WeedPlants[entity] then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if #(GetEntityCoords(GetPlayerPed(src)) - WeedPlants[entity].coords) > 10 then return end

    if Player.Functions.RemoveItem(Shared.MaleSeed, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.MaleSeed], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('male_seed_added'), 'success', 2500)
        
        WeedPlants[entity].gender = 'male'
        MySQL.update('UPDATE weedplants SET gender = (:gender) WHERE id = (:id)', {
            ['gender'] = WeedPlants[entity].gender,
            ['id'] = WeedPlants[entity].id,
        })
    end
end)

RegisterNetEvent('ps-weedplanting:server:CreateNewPlant', function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if #(GetEntityCoords(GetPlayerPed(src)) - coords) > Shared.rayCastingDistance + 10 then return end
    if exports['qb-inventory']:RemoveItem(src, Shared.FemaleSeed, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.FemaleSeed], 'remove', 1)
        local ModelHash = Shared.WeedProps[1]
        local plant = CreateObjectNoOffset(ModelHash, coords.x, coords.y, coords.z + Shared.ObjectZOffset, true, true, false)
        FreezeEntityPosition(plant, true)
        local time = os.time()
        MySQL.insert('INSERT into weedplants (coords, time, fertilizer, water, gender) VALUES (:coords, :time, :fertilizer, :water, :gender)', {
            ['coords'] = json.encode(coords),
            ['time'] = time,
            ['fertilizer'] = json.encode({}),
            ['water'] = json.encode({}),
            ['gender'] = 'female'
        }, function(data)
            WeedPlants[plant] = {
                id = data,
                coords = coords,
                time = time,
                fertilizer = {},
                water = {},
                gender = 'female'
            }
        end)
    end
end)

--- Callbacks

QBCore.Functions.CreateCallback('ps-weedplanting:server:GetPlantData', function(source, cb, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not WeedPlants[entity] then cb(nil) return end
    local temp = {
        id = WeedPlants[entity].id,
        coords = WeedPlants[entity].coords,
        time = WeedPlants[entity].time,
        fertilizer = calcFertilizer(entity),
        water = calcWater(entity),
        gender = WeedPlants[entity].gender,
        stage = calcStage(calcGrowth(entity)),
        health = calcHealth(entity),
        growth = calcGrowth(entity)
    }
    cb(temp)
end)

--- Items

QBCore.Functions.CreateUseableItem(Shared.FemaleSeed, function(source)
    TriggerClientEvent("ps-weedplanting:client:UseWeedSeed", source)
end)


--- Threads

CreateThread(function()
    Wait(Shared.LoopUpdate * 60 * 1000)

end)
