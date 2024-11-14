local RayCast = lib.raycast.cam
local rayCastDistance = Config.rayCastingDistance

local seedPlaced = false
local placingSeed = false

local WeedPlantCache = {}

--- Global StateBag

local currentTime = GlobalState.WeedplantingTime

AddStateBagChangeHandler('WeedplantingTime', '', function(bagName, _, value)
    if bagName == 'global' and value then
        currentTime = value
    end
end)

--- Functions

--- Determines the growth stage of the plant.
--- @param time number The time when the plant was created (Unix timestamp).
--- @return stage (number) - Growth stage (1-5) 
local calculateStage = function(time)
    local current_time = currentTime
    local growTime = Config.GrowTime * 60
    local progress = current_time - time
    local growthThreshold = 20

    local growth = math.min(lib.math.round(progress * 100 / growTime, 2), 100.00)
    
    return math.min(5, math.floor((growth - 1) / growthThreshold) + 1)
end

--- Starts the raycasting process to plant a new weedplant object
local useWeedSeed = function()
    if cache.vehicle then return end

    local hasItem = client.hasItems(Config.FemaleSeed, 1)
    if not hasItem then return end

    if placingSeed then return end
    placingSeed = true
    seedPlaced = false

    lib.showTextUI(Locales['place_or_cancel'], {
        position = 'left-center',
        icon = 'fab fa-canadian-maple-leaf',
        style = { borderRadius = 10 }
    })

    local hit, entityHit, endCoords, surfaceNormal, materialHash = RayCast(511, 4, rayCastDistance)

    local ModelHash = Config.WeedProps[1]
    lib.requestModel(ModelHash)
    local plant = CreateObject(ModelHash, endCoords.x, endCoords.y, endCoords.z + Config.ObjectZOffset, false, false, false)
    
    SetModelAsNoLongerNeeded(ModelHash)
    SetEntityCollision(plant, false, false)
    SetEntityAlpha(plant, 200, true)
    -- SetEntityDrawOutline(plant, true) -- Draw outline

    while not seedPlaced do
        hit, entityHit, endCoords, surfaceNormal, materialHash = RayCast(511, 4, rayCastDistance)

        -- [X] to cancel
        if IsControlPressed(0, 186) then
            lib.hideTextUI()
            seedPlaced = false
            placingSeed = false
            DeleteObject(plant)
            return
        end

        if hit then
            SetEntityCoords(plant, endCoords.x, endCoords.y, endCoords.z + Config.ObjectZOffset)

            -- [E] To spawn plant
            if IsControlPressed(0, 38) then
                -- print(materialHash)

                if Config.GroundHashes[materialHash] then

                    seedPlaced = true
                    lib.hideTextUI()
                    DeleteObject(plant)

                    local ped = cache.ped

                    lib.playAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
                    lib.playAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)
                    
                    if lib.progressBar({
                        duration = 2000,
                        label = Locales['place_sapling'],
                        useWhileDead = false,
                        canCancel = true,
                        disable = { car = true, move = true, combat = true, mouse = false },
                    }) then
                        TriggerServerEvent('weedplanting:server:CreateNewPlant', endCoords)
                        placingSeed = false
                        ClearPedTasks(ped)
                        return
                    else
                        placingSeed = false
                        ClearPedTasks(ped)

                        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
                        return
                    end
                else
                    utils.notify(Locales['notify_title_planting'], Locales['cannot_plant_here'], 'error', 3000)

                    Wait(200)
                end
            end
        end

        Wait(0)
    end
end

--- Class

--- @type table<any, WeedPlant>
--- Global table holding all WeedPlant instances, keyed by their unique ID.
local WeedPlants = {}

--- @class WeedPlant
--- @field id number The unique identifier of the weed plant.
--- @field coords vector3 The coordinates of the weed plant in the game world.
--- @field time number The planting time (Unix timestamp) representing when the plant was created.
--- @field point ox_lib.CPoint A point object used for tracking player proximity to the plant.

local WeedPlant = {}
WeedPlant.__index = WeedPlant

--- Creates a new WeedPlant instance and sets up proximity tracking with `ox_lib`.
--- @param id number The unique identifier for the plant.
--- @param coords vector3 The coordinates where the plant is located.
--- @param time number The time when the plant was created (Unix timestamp).
--- @return WeedPlant The created WeedPlant instance.
function WeedPlant:create(id, coords, time)
    local plant = setmetatable({}, WeedPlant)

    plant.id = id
    plant.coords = coords
    plant.time = time

    -- Create a proximity point to track the player entering/exiting the plant's vicinity.
    plant.point = lib.points.new({
        coords = coords,
        distance = Config.SpawnRadius,
        plantId = id,
        time = time,

        --- Callback for when a player enters the proximity of the plant.
        --- Loads and displays the plant's 3D model based on its growth stage.
        onEnter = function(self)
            local stage = math.max(1, calculateStage(self.time))
            local model = Config.WeedProps[stage]
            if not model then return end
            
            lib.requestModel(model)
            local entity = CreateObjectNoOffset(model, self.coords.x, self.coords.y, self.coords.z + Config.ObjectZOffset, false, false, false)
            SetModelAsNoLongerNeeded(model)
            
            FreezeEntityPosition(entity, true)
            SetEntityInvincible(entity, true)
        
            self.entity = entity
            WeedPlantCache[entity] = self.plantId
        end,

        --- Callback for when a player exits the proximity of the plant.
        --- Removes the 3D model entity from the game world.
        onExit = function(self)
            local entity = self.entity
            if not entity then return end
        
            SetEntityAsMissionEntity(entity, false, true)
            DeleteEntity(entity)
        
            self.entity = nil
            WeedPlantCache[entity] = nil
        end,
        nearby = function(self)
            Wait(1000) -- Check every second

            local entity = self.entity
            if not entity then return end

            local stage = math.max(1, calculateStage(self.time))
            local model = Config.WeedProps[stage]
            if not model then return end

            local currentModel = GetEntityModel(entity)
            if currentModel ~= model then
                -- Create New
                lib.requestModel(model)
                local newEntity = CreateObjectNoOffset(model, self.coords.x, self.coords.y, self.coords.z + Config.ObjectZOffset, false, false, false)
                SetModelAsNoLongerNeeded(model)
                
                FreezeEntityPosition(newEntity, true)
                SetEntityInvincible(entity, true)
            
                self.entity = newEntity
                WeedPlantCache[newEntity] = self.plantId

                -- Delete Current
                SetEntityAsMissionEntity(entity, false, true)
                DeleteEntity(entity)
                WeedPlantCache[entity] = nil
            end
        end
    })

    WeedPlants[id] = plant

    return plant
end

--- Removes the WeedPlant instance and the object from the game world.
--- Deletes any associated 3D model entity and proximity tracking.
function WeedPlant:remove()
    local point = self.point
    
    local entity = point.entity
    
    if entity then
        SetEntityAsMissionEntity(entity, false, true)
        DeleteEntity(entity)
        WeedPlantCache[entity] = nil
    end

    point:remove()
    WeedPlants[self.id] = nil
end

--- Sets a property on the WeedPlant instance.
--- @param property string The property name to set.
--- @param value any The value to assign to the property.
function WeedPlant:set(property, value)
    self[property] = value
end

--- Retrieves a WeedPlant instance from the global WeedPlants table by its ID.
--- @param id number The unique identifier of the plant to retrieve.
--- @return WeedPlant|nil The WeedPlant instance if found, or nil if not.
function WeedPlant:getPlant(id)
    return WeedPlants[id]
end

--- Event Handlers

AddEventHandler('onResourceStop', function(resource)
    if resource ~= Config.Resource then return end

    for entity, plantId in pairs(WeedPlantCache) do
        if DoesEntityExist(entity) then
            SetEntityAsMissionEntity(entity, false, true)
            DeleteEntity(entity)
        end
    end
end)

--- Events

RegisterNetEvent('weedplanting:client:UseWeedSeed', useWeedSeed)

RegisterNetEvent('weedplanting:client:NewPlant', function(id, coords, time)
    local plant = WeedPlant:create(id, coords, time)
end)

RegisterNetEvent('weedplanting:client:RemovePlant', function(plantId)
    local plant = WeedPlant:getPlant(plantId)
    if not plant then return end
    
    plant:remove()
end)

RegisterNetEvent('weedplanting:client:CheckPlant', function(data)
    local plantId = WeedPlantCache[data.entity]
    if not plantId then return end

    local success, result = lib.callback.await('weedplanting:server:GetPlantData', 200, plantId)
    if not success then
        print(result)
        return
    end

    local isLEO = client.isPlayerPolice()
    local options = {}

    if result.health == 0 then -- Destroy plant
        options = {
            {
                title = Locales['clear_plant_header'],
                description = Locales['clear_plant_text'],
                icon = 'fas fa-skull-crossbones',
                event = 'weedplanting:client:ClearPlant',
                args = data.entity
            }
        }
    elseif result.growth == 100 then -- Harvest
        options[#options + 1] = {
            title = 'Health: ' .. result.health .. '%' .. ' - Stage: ' .. result.stage,
            description = 'Growth: ' .. result.growth .. '%',
            progress = result.growth,
            colorScheme = 'green',
            icon = 'fas fa-scissors',
            event = 'weedplanting:client:HarvestPlant',
            args = data.entity
        }

        if isLEO then
            options[#options + 1] = {
                title = Locales['destroy_plant'],
                description = Locales['destroy_plant_text'],
                icon = 'fas fa-fire',
                event = 'weedplanting:client:PoliceDestroy',
                args = data.entity
            }
        end
    elseif result.gender == 'female' then -- Option to add male seed
        options[#options + 1] = {
            title = 'Health: ' .. result.health .. '%' .. ' - Stage: ' .. result.stage,
            description = 'Growth: ' .. result.growth .. '%',
            progress = result.growth,
            colorScheme = 'green',
            icon = 'fas fa-chart-simple',
        }

        options[#options + 1] = {
            title = 'Water: ' .. result.water .. '%',
            description = Locales['add_water'],
            progress = result.water,
            colorScheme = 'cyan',
            icon = 'fas fa-shower',
            event = 'weedplanting:client:GiveWater',
            args = data.entity
        }
        
        options[#options + 1] = {
            title = 'Fertilizer: ' .. result.fertilizer .. '%',
            description = Locales['add_fertilizer'],
            progress = result.fertilizer,
            colorScheme = 'yellow',
            icon = 'fab fa-nutritionix',
            event = 'weedplanting:client:GiveFertilizer',
            args = data.entity
        }

        options[#options + 1] = {
            title = 'Gender: ' .. result.gender,
            description = Locales['add_mseed'],
            icon = 'fas fa-venus',
            event = 'weedplanting:client:AddMaleSeed',
            args = data.entity
        }

        if isLEO then
            options[#options + 1] = {
                title = Locales['destroy_plant'],
                description = Locales['destroy_plant_text'],
                icon = 'fas fa-fire',
                event = 'weedplanting:client:PoliceDestroy',
                args = data.entity
            }
        end
    else -- No option to add male seed
        options[#options + 1] = {
            title = 'Health: ' .. result.health .. '%' .. ' - Stage: ' .. result.stage,
            description = 'Growth: ' .. result.growth .. '%',
            progress = result.growth,
            colorScheme = 'green',
            icon = 'fas fa-chart-simple',
        }

        options[#options + 1] = {
            title = 'Water: ' .. result.water .. '%',
            description = Locales['add_water'],
            progress = result.water,
            colorScheme = 'cyan',
            icon = 'fas fa-shower',
            event = 'weedplanting:client:GiveWater',
            args = data.entity
        }
        
        options[#options + 1] = {
            title = 'Fertilizer: ' .. result.fertilizer .. '%',
            description = Locales['add_fertilizer'],
            progress = result.fertilizer,
            colorScheme = 'yellow',
            icon = 'fab fa-nutritionix',
            event = 'weedplanting:client:GiveFertilizer',
            args = data.entity
        }

        options[#options + 1] = {
            title = 'Gender: ' .. result.gender,
            description = Locales['add_mseed'],
            icon = 'fas fa-mars',
        }

        if isLEO then
            options[#options + 1] = {
                title = Locales['destroy_plant'],
                description = Locales['destroy_plant_text'],
                icon = 'fas fa-fire',
                event = 'weedplanting:client:PoliceDestroy',
                args = data.entity
            }
        end
    end
    
    lib.registerContext({
        id = 'weedplanting_main',
        title = Locales['plant_header'],
        options = options
    })

    lib.showContext('weedplanting_main')
end)

RegisterNetEvent('weedplanting:client:PoliceDestroy', function(entity)
    local plantId = WeedPlantCache[entity]
    if not plantId then return end

    local ped = cache.ped

    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(500)

    ClearPedTasks(ped)
    TriggerServerEvent('weedplanting:server:ClearPlant', plantId, true)
end)

RegisterNetEvent('weedplanting:client:FireGoBrrrrrrr', function(coords)
    local ped = cache.ped
    local pedCoords = GetEntityCoords(ped)
    if #(pedCoords - vec3(coords.x, coords.y, coords.z)) > 300 then return end

    lib.requestNamedPtfxAsset('core')
    UseParticleFxAsset('core')
    local effect = StartParticleFxLoopedAtCoord('ent_ray_paleto_gas_flames', coords.x, coords.y, coords.z + 0.5, 0.0, 0.0, 0.0, 0.6, false, false, false, false)
    Wait(Config.FireTime)

    StopParticleFxLooped(effect, 0)
    RemoveNamedPtfxAsset('core')
end)

RegisterNetEvent('weedplanting:client:ClearPlant', function(entity)
    local plantId = WeedPlantCache[entity]
    if not plantId then return end

    local ped = cache.ped

    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(500)

    lib.playAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
    lib.playAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)

    if lib.progressBar({
        duration = 8500,
        label = Locales['clear_plant'],
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false },
    }) then
        TriggerServerEvent('weedplanting:server:ClearPlant', plantId, false)
        ClearPedTasks(ped)
    else
        ClearPedTasks(ped)
        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
    end
end)

RegisterNetEvent('weedplanting:client:HarvestPlant', function(entity)
    local plantId = WeedPlantCache[entity]
    if not plantId then return end

    local ped = cache.ped
    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(500)

    lib.playAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
    lib.playAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)

    if lib.progressBar({
        duration = 8500,
        label = Locales['harvesting_plant'],
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false },
    }) then
        TriggerServerEvent('weedplanting:server:HarvestPlant', plantId)
        ClearPedTasks(ped)
    else
        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent('weedplanting:client:GiveWater', function(entity)
    if not client.hasItems(Config.WaterItem, 1) then
        return utils.notify(Locales['notify_title_planting'], Locales['missing_water'], 'error', 3000)
    end

    local plantId = WeedPlantCache[entity]
    if not plantId then return end

    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local model = joaat('prop_wateringcan')

    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(500)

    lib.requestModel(model)
    local created_object = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(created_object, ped, GetPedBoneIndex(ped, 28422), 0.4, 0.1, 0.0, 90.0, 180.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)

    lib.requestNamedPtfxAsset('core')
    UseParticleFxAsset('core')
    local effect = StartParticleFxLoopedOnEntity('ent_sht_water', created_object, 0.35, 0.0, 0.25, 0.0, 0.0, 0.0, 2.0, false, false, false)

    if lib.progressBar({
        duration = 6000,
        label = Locales['watering_plant'],
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false },
        anim = { dict = 'weapon@w_sp_jerrycan', clip = 'fire', flags = 1 },
    }) then
        DeleteEntity(created_object)
        StopParticleFxLooped(effect, 0)
        RemoveNamedPtfxAsset('core')
        TriggerServerEvent('weedplanting:server:GiveWater', plantId)
    else
        DeleteEntity(created_object)
        StopParticleFxLooped(effect, 0)
        RemoveNamedPtfxAsset('core')

        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
    end
end)

RegisterNetEvent('weedplanting:client:GiveFertilizer', function(entity)
    if not client.hasItems(Config.FertilizerItem, 1) then
        return utils.notify(Locales['notify_title_planting'], Locales['missing_fertilizer'], 'error', 3000)
    end

    local plantId = WeedPlantCache[entity]
    if not plantId then return end

    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local model = joaat('w_am_jerrycan_sf')

    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(500)

    lib.requestModel(model)
    local created_object = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    SetModelAsNoLongerNeeded(model)
    AttachEntityToEntity(created_object, ped, GetPedBoneIndex(ped, 28422), 0.3, 0.1, 0.0, 90.0, 180.0, 0.0, true, true, false, true, 1, true)

    if lib.progressBar({
        duration = 6000,
        label = Locales['fertilizing_plant'],
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false },
        anim = { dict = 'weapon@w_sp_jerrycan', clip = 'fire', flags = 1 },
    }) then
        TriggerServerEvent('weedplanting:server:GiveFertilizer', plantId)
        ClearPedTasks(ped)
        DeleteEntity(created_object)
    else
        ClearPedTasks(ped)
        DeleteEntity(created_object)

        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
    end
end)

RegisterNetEvent('weedplanting:client:AddMaleSeed', function(entity)
    if not client.hasItems(Config.MaleSeed, 1) then
        return utils.notify(Locales['notify_title_planting'], Locales['missing_mseed'], 'error', 3000)
    end

    local plantId = WeedPlantCache[entity]
    if not plantId then return end

    local ped = cache.ped

    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(500)

    lib.playAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
    lib.playAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)

    if lib.progressBar({
        duration = 8500,
        label = Locales['adding_male_seed'],
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('weedplanting:server:AddMaleSeed', plantId)
    else
        ClearPedTasks(ped)
        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
    end
end)

--- Threads

CreateThread(function()
    Wait(2000)

    local result = lib.callback.await('weedplanting:server:GetPlantLocations', 200)

    for id, data in pairs(result) do
        if data then
            local plant = WeedPlant:create(id, data.coords, data.time)
        end
    end
end)

--- Target

if Config.Target == 'ox_target' then
    exports['ox_target']:addModel(Config.WeedProps, {
        {
            name = 'weedplanting_main',
            event = 'weedplanting:client:CheckPlant',
            icon = 'fas fa-cannabis',
            label = Locales['check_plant'],
            distance = 1.5,
            canInteract = function(entity)
                return WeedPlantCache[entity]
            end,
        }
    })
elseif Config.Target == 'qb-target' then
    exports['qb-target']:AddTargetModel(Config.WeedProps, {
        options = {
            {
                type = 'client',
                event = 'weedplanting:client:CheckPlant',
                icon = 'fas fa-cannabis',
                label = Locales['check_plant'],
                canInteract = function(entity)
                    return WeedPlantCache[entity]
                end,
            }
        },
        distance = 1.5, 
    })
end

exports('useWeedSeed', useWeedSeed)
