WeedPlants = {}

setupPlants = function()
    local result = MySQL.Sync.fetchAll('SELECT * FROM weedplants')
    for k, v in pairs(result) do
        local stage = math.floor(v.growth / 20)
        if stage == 0 then stage += 1 end
        local ModelHash = Shared.WeedProps[stage]
        local coords = json.decode(v.coords)
        local plant = CreateObjectNoOffset(ModelHash, coords.x, coords.y, coords.z, true, true, false)
        FreezeEntityPosition(plant, true)

        WeedPlants[plant] = {
            id = v.id,
            coords = v.coords,
            growth = v.growth,
            nutrition = v.nutrition,
            water = v.water,
            health = v.health,
            gender = v.gender,
            stage = stage
        }
    end
end

destroyAllPlants = function()
    if Shared.ClearOnStartup then
        MySQL.query('DELETE from weedplants WHERE health <= 0')
    end
    
    for k, v in pairs(WeedPlants) do
        if DoesEntityExist(k) then
            DeleteEntity(k)
            WeedPlants[k] = nil
        end
    end
end

RegisterNetEvent('ps-weedplanting:server:CreateNewPlant', function(coords)
    local ModelHash = Shared.WeedProps[1]
    local plant = CreateObjectNoOffset(ModelHash, coords.x, coords.y, coords.z, true, true, false)
    FreezeEntityPosition(plant, true)
    MySQL.insert('INSERT into weedplants (coords, growth, nutrition, water, health, gender) VALUES (:coords, :growth, :nutrition, :water, :health, :gender)', {
        ['coords'] = json.encode(coords),
        ['growth'] = 0,
        ['nutrition'] = 0,
        ['water'] = 0,
        ['health'] = 100,
        ['gender'] = 'female'
    }, function(data)
        WeedPlants[plant] = {
            id = data,
            coords = coords,
            growth = 0,
            nutrition = 0,
            water = 0,
            health = 100,
            gender = 'female',
            stage = 1
        }
    end)
end)
