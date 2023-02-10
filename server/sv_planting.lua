WeedPlants = {}

--- Functions

--- Method to setup all the weedplants, fetched from the database
--- @return nil
setupPlants = function()
    local result = MySQL.Sync.fetchAll('SELECT * FROM weedplants')
    local growTime = Shared.GrowTime * 60
    local current_time = os.time()
    for k, v in pairs(result) do
        local progress = os.difftime(current_time, v.time)
        local growth = math.min(QBCore.Shared.Round(progress * 100 / growTime, 2), 100.00)
        local stage = math.floor(growth / 20)
        if stage == 0 then stage += 1 end
        local ModelHash = Shared.WeedProps[stage]
        local coords = json.decode(v.coords)
        local plant = CreateObjectNoOffset(ModelHash, coords.x, coords.y, coords.z + Shared.ObjectZOffset, true, true, false)
        FreezeEntityPosition(plant, true)

        WeedPlants[plant] = {
            id = v.id,
            coords = v.coords,
            time = v.time,
            growth = growth,
            nutrition = v.nutrition,
            water = v.water,
            health = v.health,
            gender = v.gender,
            stage = stage
        }
    end
end

--- Method to delete all cached plant props and deletes dead plants in the database
--- @return nil
destroyAllPlants = function()    
    for k, v in pairs(WeedPlants) do
        if DoesEntityExist(k) then
            DeleteEntity(k)
            WeedPlants[k] = nil
        end
    end
end

--- Events

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
        MySQL.insert('INSERT into weedplants (coords, time, growth, nutrition, water, health, gender) VALUES (:coords, :time, :growth, :nutrition, :water, :health, :gender)', {
            ['coords'] = json.encode(coords),
            ['time'] = time,
            ['growth'] = 0,
            ['nutrition'] = 0,
            ['water'] = 0,
            ['health'] = 100,
            ['gender'] = 'female'
        }, function(data)
            WeedPlants[plant] = {
                id = data,
                coords = coords,
                time = time,
                growth = 0,
                nutrition = 0,
                water = 0,
                health = 100,
                gender = 'female',
                stage = 1
            }
        end)
    end
end)

--- Items

QBCore.Functions.CreateUseableItem(Shared.FemaleSeed, function(source)
    TriggerClientEvent("ps-weedplanting:client:UseWeedSeed", source)
end)
