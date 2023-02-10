QBCore = exports['qb-core']:GetCoreObject()

--- Functions

--- Method to update a plant prop, removing the existing one and placing a new prop
--- @param k number - WeedPlants table index
--- @param stage number - Stage number
--- @return nil
local updatePlantProp = function(k, stage)
    if not WeedPlants[k] then return end
    if not DoesEntityExist(k) then return end
    local ModelHash = Shared.WeedProps[stage]
    local coords = json.decode(WeedPlants[k].coords)

    DeleteEntity(k)
    local plant = CreateObjectNoOffset(ModelHash, coords.x, coords.y, coords.z + Shared.ObjectZOffset, true, true, false)
    FreezeEntityPosition(plant, true)
    WeedPlants[plant] = WeedPlants[k]
    WeedPlants[k] = nil
end

--- Method to store all weed plants states in database
--- @return nil
local storePlants = function()
    local queries = {}
    for k, v in pairs(WeedPlants) do
        queries[#queries + 1] = {
            query = 'UPDATE weedplants SET growth = (:growth), nutrition = (:nutrition), water = (:water), health = (:health) WHERE id = (:id)',
            values = {
                ['growth'] = WeedPlants[k].growth,
                ['nutrition'] = WeedPlants[k].nutrition,
                ['water'] = WeedPlants[k].water,
                ['health'] = WeedPlants[k].health,
                ['id'] = WeedPlants[k].id,
            }
        }
    end

    if #queries > 0 then
        MySQL.transaction(queries, function(success)
            print('Updated database', success, #queries)
        end)
    end
end

--- Method to perform an update on every weedplant, updating their stats, repeats every Shared.LoopUpdate minutes
--- @return nil
updatePlants = function()
    local current_time = os.time()
    local growTime = Shared.GrowTime * 60

    for k, v in pairs(WeedPlants) do
        if v.health > 0 then
            -- Progress Update
            local progress = os.difftime(current_time, v.time)
            WeedPlants[k].growth = math.min(QBCore.Shared.Round(progress * 100 / growTime, 2), 100.00)

            -- Health Update
            if v.nutrition < Shared.FertilizerThreshold[2] then
                WeedPlants[k].health = math.max(WeedPlants[k].health - Shared.HealthDecayMultiplier * math.random(Shared.HealthBaseDecay[1], Shared.HealthBaseDecay[2]), 0.0)
            elseif v.nutrition < Shared.FertilizerThreshold[1] then
                WeedPlants[k].health = math.max(WeedPlants[k].health - math.random(Shared.HealthBaseDecay[1], Shared.HealthBaseDecay[2]) , 0.0)
            end

            if v.water < Shared.WaterThreshold[2] then
                WeedPlants[k].health = math.max(WeedPlants[k].health - Shared.HealthDecayMultiplier * math.random(Shared.HealthBaseDecay[1], Shared.HealthBaseDecay[2]), 0.0)
            elseif v.water < Shared.WaterThreshold[1] then
                WeedPlants[k].health = math.max(WeedPlants[k].health - math.random(Shared.HealthBaseDecay[1], Shared.HealthBaseDecay[2]) , 0.0)
            end

            -- Fertilizer and Water update
            WeedPlants[k].nutrition = math.max(WeedPlants[k].nutrition - math.random(Shared.FertilizerUpdate[1], Shared.FertilizerUpdate[2]), 0.0)
            WeedPlants[k].water = math.max(WeedPlants[k].water - math.random(Shared.WaterUpdate[1], Shared.WaterUpdate[2]), 0.0)

            -- Stage Update
            local stage = math.floor(WeedPlants[k].growth / 20)
            if stage == 0 then stage += 1 end
            if stage ~= v.stage then
                WeedPlants[k].stage = stage
                updatePlantProp(k, stage)
            end
        end
    end

    SetTimeout(Shared.LoopUpdate * 60 * 1000, updatePlants)
end

--- Resource start/stop events

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if Shared.ClearOnStartup then
        MySQL.query('DELETE from weedplants WHERE health <= 0')
    end
    setupPlants()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    storePlants()
    destroyAllPlants()
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
    storePlants()
end)

--- Events

RegisterNetEvent('ps-weedplanting:server:ClearPlant', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not WeedPlants[entity] then return end
    if WeedPlants[entity].health ~= 0 then return end

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
    if WeedPlants[entity].growth ~= 100 then return end

    if DoesEntityExist(entity) then
        if WeedPlants[entity].gender == 'female' then
            local info = { health = WeedPlants[entity].health }

            if Shared.Inventory == 'exports' and exports['qb-inventory']:AddItem(src, Shared.BranchItem, 1, false, info) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.BranchItem], 'add', 1)
            elseif Shared.Inventory == 'player' and Player.Functions.AddItem(Shared.BranchItem, 1, false, info) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.BranchItem], 'add', 1)
            end
        else -- male seed added
            local mSeeds = math.floor(WeedPlants[entity].health / 50)
            local fSeeds = math.floor(WeedPlants[entity].health / 20)

            if Shared.Inventory == 'exports' then
                exports['qb-inventory']:AddItem(src, Shared.MaleSeed, mSeeds, false)
                exports['qb-inventory']:AddItem(src, Shared.FemaleSeed, fSeeds, false)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.MaleSeed], 'add', mSeeds)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.FemaleSeed], 'add', fSeeds)
            elseif Shared.Inventory == 'player' then 
                Player.Functions.AddItem(Shared.MaleSeed, mSeeds, false)
                Player.Functions.AddItem(Shared.FemaleSeed, fSeeds, false)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.MaleSeed], 'add', mSeeds)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.FemaleSeed], 'add', fSeeds)
            end
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
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.type ~= 'leo' then return end

    if DoesEntityExist(entity) then
        local coords = json.decode(WeedPlants[entity].coords)
        MySQL.query('DELETE from weedplants WHERE id = :id', {
            ['id'] = WeedPlants[entity].id
        })
        WeedPlants[entity] = nil
        TriggerClientEvent('ps-weedplanting:client:FireGoBrrrrrrr', -1, coords)
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

    if Shared.Inventory == 'exports' and exports['qb-inventory']:RemoveItem(src, Shared.WaterItem, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WaterItem], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('watered_plant'), 'success', 2500)

        WeedPlants[entity].water += Shared.AddWaterAmount
        if WeedPlants[entity].water > 100 then
            WeedPlants[entity].water = 100
        end

        MySQL.update('UPDATE weedplants SET water = (:water) WHERE id = (:id)', {
            ['water'] = WeedPlants[entity].water,
            ['id'] = WeedPlants[entity].id,
        })
    elseif Shared.Inventory == 'player' and Player.Functions.RemoveItem(Shared.WaterItem, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WaterItem], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('watered_plant'), 'success', 2500)

        WeedPlants[entity].water += Shared.AddWaterAmount
        if WeedPlants[entity].water > 100 then
            WeedPlants[entity].water = 100
        end

        MySQL.update('UPDATE weedplants SET water = (:water) WHERE id = (:id)', {
            ['water'] = WeedPlants[entity].water,
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

    if Shared.Inventory == 'exports' and exports['qb-inventory']:RemoveItem(src, Shared.FertilizerItem, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.FertilizerItem], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('fertilizer_added'), 'success', 2500)

        WeedPlants[entity].nutrition += Shared.AddFertilizerAmount
        if WeedPlants[entity].nutrition > 100 then
            WeedPlants[entity].nutrition = 100
        end

        MySQL.update('UPDATE weedplants SET nutrition = (:nutrition) WHERE id = (:id)', {
            ['nutrition'] = WeedPlants[entity].nutrition,
            ['id'] = WeedPlants[entity].id,
        })
    elseif Shared.Inventory == 'player' and Player.Functions.RemoveItem(Shared.FertilizerItem, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.FertilizerItem], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('fertilizer_added'), 'success', 2500)

        WeedPlants[entity].nutrition += Shared.AddFertilizerAmount
        if WeedPlants[entity].nutrition > 100 then
            WeedPlants[entity].nutrition = 100
        end

        MySQL.update('UPDATE weedplants SET nutrition = (:nutrition) WHERE id = (:id)', {
            ['nutrition'] = WeedPlants[entity].nutrition,
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

    if Shared.Inventory == 'exports' and exports['qb-inventory']:RemoveItem(src, Shared.MaleSeed, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.MaleSeed], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('male_seed_added'), 'success', 2500)
        WeedPlants[entity].gender = 'male'

        MySQL.update('UPDATE weedplants SET gender = (:gender) WHERE id = (:id)', {
            ['gender'] = WeedPlants[entity].gender,
            ['id'] = WeedPlants[entity].id,
        })
    elseif Shared.Inventory == 'player' and Player.Functions.RemoveItem(Shared.MaleSeed, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.MaleSeed], 'remove', 1)
        TriggerClientEvent('QBCore:Notify', src, _U('male_seed_added'), 'success', 2500)
        WeedPlants[entity].gender = 'male'

        MySQL.update('UPDATE weedplants SET gender = (:gender) WHERE id = (:id)', {
            ['gender'] = WeedPlants[entity].gender,
            ['id'] = WeedPlants[entity].id,
        })
    end
end)

RegisterNetEvent('ps-weedplanting:server:ProcessBranch', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item = Player.Functions.GetItemByName(Shared.BranchItem)
    if item and item.info.health then
        if Shared.Inventory == 'exports' and exports['qb-inventory']:RemoveItem(src, Shared.BranchItem, 1, item.slot) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.BranchItem], 'remove', 1)
            exports['qb-inventory']:AddItem(src, Shared.WeedItem, item.info.health, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WeedItem], 'add', item.info.health)
        elseif Shared.Inventory == 'player' and Player.Functions.RemoveItem(Shared.BranchItem, 1, item.slot) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.BranchItem], 'remove', 1)
            Player.Functions.AddItem(Shared.WeedItem, item.info.health, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WeedItem], 'add', item.info.health)
        end
    end
end)

RegisterNetEvent('ps-weedplanting:server:PackageWeed', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item = Player.Functions.GetItemByName(Shared.WeedItem)
    if item and item.amount >= 20 then
        if Shared.Inventory == 'exports' then
            exports['qb-inventory']:RemoveItem(src, Shared.WeedItem, 20, item.slot)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WeedItem], 'remove', 20)
            exports['qb-inventory']:AddItem(src, Shared.PackedWeedItem, 1, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.PackedWeedItem], 'add', 1)
        elseif Shared.Inventory == 'player' then
            Player.Functions.RemoveItem(Shared.WeedItem, 20, item.slot)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WeedItem], 'remove', 20)
            Player.Functions.AddItem(Shared.PackedWeedItem, 1, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.PackedWeedItem], 'add', 1)
        end
    end
end)

--- Callbacks

QBCore.Functions.CreateCallback('ps-weedplanting:server:GetPlantData', function(source, cb, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    cb(WeedPlants[entity])
end)

--- Items

QBCore.Functions.CreateUseableItem(Shared.BranchItem, function(source)
    TriggerClientEvent('ps-weedplanting:client:UseBranch', source)
end)

QBCore.Functions.CreateUseableItem(Shared.WeedItem, function(source, item)
    if item and item.amount >= 20 then
        TriggerClientEvent('ps-weedplanting:client:UseDryWeed', source)
    else
        TriggerClientEvent('QBCore:Notify', src, _U('not_enough_dryweed'), 'error', 2500)
    end
end)

--- Threads

CreateThread(function()
    Wait(Shared.LoopUpdate * 60 * 1000)
    updatePlants()
end)
