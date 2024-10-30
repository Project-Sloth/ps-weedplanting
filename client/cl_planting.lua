local RayCast = lib.raycast.cam
local rayCastDistance = Config.rayCastingDistance

local seedPlaced = false
local placingSeed = false

--- Player load, unload and update handlers

AddEventHandler('onResourceStop', function(resource)
    if resource ~= Config.Resource then return end

    clearWeedRun()
end)

--- Events

RegisterNetEvent('weedplanting:client:UseWeedSeed', function()
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

    while not seedPlaced do
        hit, entityHit, endCoords, surfaceNormal, materialHash = RayCast(511, 4, rayCastDistance)

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
                    else
                        placingSeed = false
                        ClearPedTasks(ped)

                        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
                    end
                else
                    utils.notify(Locales['notify_title_planting'], Locales['cannot_plant_here'], 'error', 3000)

                    Wait(200)
                end
            end
            
            -- [X] to cancel
            if IsControlPressed(0, 186) then
                lib.hideTextUI()
                seedPlaced = false
                placingSeed = false
                DeleteObject(plant)
                return
            end
        end

        Wait(0)
    end
end)

RegisterNetEvent('weedplanting:client:CheckPlant', function(data)
    local netId = NetworkGetNetworkIdFromEntity(data.entity)

    local result = lib.callback.await('weedplanting:server:GetPlantData', 200, netId)
    if not result then return end

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
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local ped = cache.ped

    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(500)

    ClearPedTasks(ped)
    TriggerServerEvent('weedplanting:server:PoliceDestroy', netId)
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
    local netId = NetworkGetNetworkIdFromEntity(entity)
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
        TriggerServerEvent('weedplanting:server:ClearPlant', netId)
        ClearPedTasks(ped)
    else
        ClearPedTasks(ped)

        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
    end
end)

RegisterNetEvent('weedplanting:client:HarvestPlant', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
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
        TriggerServerEvent('weedplanting:server:HarvestPlant', netId)
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

    local netId = NetworkGetNetworkIdFromEntity(entity)
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
        TriggerServerEvent('weedplanting:server:GiveWater', netId)
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

    local netId = NetworkGetNetworkIdFromEntity(entity)
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
        TriggerServerEvent('weedplanting:server:GiveFertilizer', netId)
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

    local netId = NetworkGetNetworkIdFromEntity(entity)
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
        TriggerServerEvent('weedplanting:server:AddMaleSeed', netId)
    else
        ClearPedTasks(ped)
        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
    end
end)

--- Threads

if Config.Target == 'ox_target' then
    exports['ox_target']:addModel(Config.WeedProps, {
        {
            name = 'weedplanting_main',
            event = 'weedplanting:client:CheckPlant',
            icon = 'fas fa-cannabis',
            label = Locales['check_plant'],
            distance = 1.5,
            canInteract = function(entity)
                return Entity(entity)?.state.weedplanting
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
                    return Entity(entity)?.state.weedplanting
                end,
            }
        },
        distance = 1.5, 
    })
end
