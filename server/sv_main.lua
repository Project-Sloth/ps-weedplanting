QBCore = exports['qb-core']:GetCoreObject()

-- (Re)start events

AddEventHandler("onResourceStart", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    setupPlants()
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    destroyAllPlants()
end)

-- Events

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
    if WeedPlants[entity].growth ~= 100 then return end
    if DoesEntityExist(entity) then
        local Player = QBCore.Functions.GetPlayer(source)
        if Shared.Inventory == 'exports' and exports['qb-inventory']:AddItem(source, Shared.WeedItem, WeedPlants[entity].health, false) then
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Shared.WeedItem], "add", WeedPlants[entity].health)
        elseif Shared.Inventory == 'player' and Player.Functions.AddItem(Shared.WeedItem, WeedPlants[entity].health, false) then
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Shared.WeedItem], "add", WeedPlants[entity].health)
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
        TriggerClientEvent('ps-weedplanting:client:FireGoBrrrrrrr', -1, coords)
        Wait(Shared.FireTime)
        DeleteEntity(entity)
        MySQL.query('DELETE from weedplants WHERE id = :id', {
            ['id'] = WeedPlants[entity].id
        })
        WeedPlants[entity] = nil
    end
end)

-- Callbacks

QBCore.Functions.CreateCallback('ps-weedplanting:server:GetPlantData', function(source, cb, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    cb(WeedPlants[entity])
end)