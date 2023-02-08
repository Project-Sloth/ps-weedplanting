QBCore = exports['qb-core']:GetCoreObject()
PlayerJob = QBCore.Functions.GetPlayerData().job

--- Player load, unload and update handlers

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerJob = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

--- Events

RegisterNetEvent('ps-weedplanting:client:CheckPlant', function(data)
    local netId = NetworkGetNetworkIdFromEntity(data.entity)
    QBCore.Functions.TriggerCallback('ps-weedplanting:server:GetPlantData', function(result)
        if not result then return end

        if result.health == 0 then -- Destroy plant
            exports['qb-menu']:openMenu({
                {
                    header = _U('plant_header'),
                    txt = _U('esc_to_close'),
                    icon = 'fas fa-chevron-left',
                    params = {
                        event = 'qb-menu:closeMenu'
                    }
                },
                {
                    header = _U('clear_plant_header'),
                    txt = _U('clear_plant_text'),
                    icon = 'fas fa-skull-crossbones',
                    params = {
                        event = 'ps-weedplanting:client:ClearPlant',
                        args = data.entity
                    }
                }
            })
        elseif result.growth == 100 then -- Harvest
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-menu']:openMenu({
                    {
                        header = _U('plant_header'),
                        txt = _U('esc_to_close'),
                        icon = 'fas fa-chevron-left',
                        params = {
                            event = 'qb-menu:closeMenu'
                        }
                    },
                    {
                        header = 'Stage: ' .. result.stage .. ' - Health: ' .. result.health,
                        txt = _U('ready_for_harvest'),
                        icon = 'fas fa-scissors',
                        params = {
                            event = 'ps-weedplanting:client:HarvestPlant',
                            args = data.entity
                        }
                    },
                    {
                        header = _U('destroy_plant'),
                        txt = _U('ready_for_harvest'),
                        icon = 'fas fa-fire',
                        params = {
                            event = 'ps-weedplanting:client:PoliceDestroy',
                            args = data.entity
                        }
                    }
                })
            else
                exports['qb-menu']:openMenu({
                    {
                        header = _U('plant_header'),
                        txt = _U('esc_to_close'),
                        icon = 'fas fa-chevron-left',
                        params = {
                            event = 'qb-menu:closeMenu'
                        }
                    },
                    {
                        header = 'Stage: ' .. result.stage .. ' - Health: ' .. result.health,
                        txt = _U('ready_for_harvest'),
                        icon = 'fas fa-scissors',
                        params = {
                            event = 'ps-weedplanting:client:HarvestPlant',
                            args = data.entity
                        }
                    },
                })
            end
        elseif result.gender == 'female' then -- Option to add male seed
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-menu']:openMenu({
                    {
                        header = _U('plant_header'),
                        txt = _U('esc_to_close'),
                        icon = 'fas fa-chevron-left',
                        params = {
                            event = 'qb-menu:closeMenu'
                        }
                    },
                    {
                        header = 'Growth: ' .. result.growth .. '%' .. ' - Stage: ' .. result.stage,
                        txt = 'Health: ' .. result.health,
                        icon = 'fas fa-chart-simple',
                        isMenuHeader = true
                    },
                    {
                        header = _U('destroy_plant'),
                        txt = _U('ready_for_harvest'),
                        icon = 'fas fa-fire',
                        params = {
                            event = 'ps-weedplanting:client:PoliceDestroy',
                            args = data.entity
                        }
                    }
                })
            else
                exports['qb-menu']:openMenu({
                    {
                        header = _U('plant_header'),
                        txt = _U('esc_to_close'),
                        icon = 'fas fa-chevron-left',
                        params = {
                            event = 'qb-menu:closeMenu'
                        }
                    },
                    {
                        header = 'Growth: ' .. result.growth .. '%' .. ' - Stage: ' .. result.stage,
                        txt = 'Health: ' .. result.health,
                        icon = 'fas fa-chart-simple',
                        isMenuHeader = true
                    },
                    {
                        header = 'Water: ' .. result.water .. '%',
                        txt = _U('add_water'),
                        icon = 'fas fa-shower',
                        params = {
                            event = 'ps-weedplanting:client:GiveWater',
                            args = data.entity
                        }
                    },
                    {
                        header = 'Fertilizer: ' .. result.nutrition .. '%',
                        txt = _U('add_fertilizer'),
                        icon = 'fab fa-nutritionix',
                        params = {
                            args = data.entity,
                            event = 'ps-weedplanting:client:GiveFertilizer',
                        }
                    },
                    {
                        header = 'Gender: ' .. result.gender,
                        txt = _U('add_mseed'),
                        icon = 'fas fa-venus',
                        params = {
                            args = data.entity,
                            event = 'ps-weedplanting:client:AddMaleSeed',
                        }
                    }
                })
            end
        else -- No option to add male seed
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-menu']:openMenu({
                    {
                        header = _U('plant_header'),
                        txt = _U('esc_to_close'),
                        icon = 'fas fa-chevron-left',
                        params = {
                            event = 'qb-menu:closeMenu'
                        }
                    },
                    {
                        header = 'Growth: ' .. result.growth .. '%' .. ' - Stage: ' .. result.stage,
                        txt = 'Health: ' .. result.health,
                        icon = 'fas fa-chart-simple',
                        isMenuHeader = true
                    },
                    {
                        header = _U('destroy_plant'),
                        txt = _U('ready_for_harvest'),
                        icon = 'fas fa-fire',
                        params = {
                            event = 'ps-weedplanting:client:PoliceDestroy',
                            args = data.entity
                        }
                    },
                })
            else
                exports['qb-menu']:openMenu({
                    {
                        header = _U('plant_header'),
                        txt = _U('esc_to_close'),
                        icon = 'fas fa-chevron-left',
                        params = {
                            event = 'qb-menu:closeMenu'
                        }
                    },
                    {
                        header = 'Growth: ' .. result.growth .. '%' .. ' - Stage: ' .. result.stage,
                        txt = 'Health: ' .. result.health,
                        icon = 'fas fa-chart-simple',
                        isMenuHeader = true
                    },
                    {
                        header = 'Water: ' .. result.water .. '%',
                        txt = _U('add_water'),
                        icon = 'fas fa-shower',
                        params = {
                            event = 'ps-weedplanting:client:GiveWater',
                            args = data.entity
                        }
                    },
                    {
                        header = 'Fertilizer: ' .. result.nutrition .. '%',
                        txt = _U('add_water'),
                        icon = 'fab fa-nutritionix',
                        params = {
                            args = data.entity,
                            event = 'ps-weedplanting:client:GiveFertilizer',
                        }
                    },
                    {
                        header = 'Gender: ' .. result.gender,
                        txt = _U('add_mseed'),
                        icon = 'fas fa-mars',
                        isMenuHeader = true
                    }
                })
            end
        end
    end, netId)
end)

RegisterNetEvent('ps-weedplanting:client:ClearPlant', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(1500)

    RequestAnimDict('amb@medic@standing@kneel@base')
    RequestAnimDict('anim@gangops@facility@servers@bodysearch@')
    while 
        not HasAnimDictLoaded('amb@medic@standing@kneel@base') or
        not HasAnimDictLoaded('anim@gangops@facility@servers@bodysearch@')
    do 
        Wait(0) 
    end
    TaskPlayAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)

    QBCore.Functions.Progressbar('clear_plant', _U('clear_plant'), 8500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('ps-weedplanting:server:ClearPlant', netId)
        ClearPedTasks(ped)
        RemoveAnimDict('amb@medic@standing@kneel@base')
        RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
    end, function()
        QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
        ClearPedTasks(ped)
        RemoveAnimDict('amb@medic@standing@kneel@base')
        RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
    end)
end)

RegisterNetEvent('ps-weedplanting:client:HarvestPlant', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(1500)

    RequestAnimDict('amb@medic@standing@kneel@base')
    RequestAnimDict('anim@gangops@facility@servers@bodysearch@')
    while 
        not HasAnimDictLoaded('amb@medic@standing@kneel@base') or
        not HasAnimDictLoaded('anim@gangops@facility@servers@bodysearch@')
    do 
        Wait(0) 
    end
    TaskPlayAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)

    QBCore.Functions.Progressbar('harvest_plant', _U('harvesting_plant'), 8500, false, true, {
        disableMovement = true, 
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('ps-weedplanting:server:HarvestPlant', netId)
        ClearPedTasks(ped)
        RemoveAnimDict('amb@medic@standing@kneel@base')
        RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
    end, function()
        QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
        ClearPedTasks(ped)
        RemoveAnimDict('amb@medic@standing@kneel@base')
        RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
    end)
end)

RegisterNetEvent('ps-weedplanting:client:PoliceDestroy', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(500)
    ClearPedTasks(ped)
    TriggerServerEvent('ps-weedplanting:server:PoliceDestroy', netId)
end)

RegisterNetEvent('ps-weedplanting:client:FireGoBrrrrrrr', function(coords)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    if #(pedCoords - vector3(coords.x, coords.y, coords.z)) > 300 then return end

    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Wait(10) end
    SetPtfxAssetNextCall('core')
    local effect = StartParticleFxLoopedAtCoord('ent_ray_paleto_gas_flames', coords.x, coords.y, coords.z + 0.5, 0.0, 0.0, 0.0, 0.6, false, false, false, false)
    Wait(Shared.FireTime)
    StopParticleFxLooped(effect, 0)
end)

RegisterNetEvent('ps-weedplanting:client:GiveWater', function(entity)
    if QBCore.Functions.HasItem(Shared.WaterItem, 1) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local model = `prop_wateringcan`
        TaskTurnPedToFaceEntity(ped, entity, 1.0)
        Wait(1500)
        RequestModel(model)
        RequestNamedPtfxAsset('core')
        while not HasModelLoaded(model) or not HasNamedPtfxAssetLoaded('core') do Wait(10) end
        SetPtfxAssetNextCall('core')
        local created_object = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(created_object, ped, GetPedBoneIndex(ped, 28422), 0.4, 0.1, 0.0, 90.0, 180.0, 0.0, true, true, false, true, 1, true)
        local effect = StartParticleFxLoopedOnEntity('ent_sht_water', created_object, 0.35, 0.0, 0.25, 0.0, 0.0, 0.0, 2.0, false, false, false)
        QBCore.Functions.Progressbar('weedplanting_water', _U('watering_plant'), 6000, false, false, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'weapon@w_sp_jerrycan',
            anim = 'fire',
            flags = 1,
        }, {}, {}, function()
            TriggerServerEvent('ps-weedplanting:server:GiveWater', netId)
            ClearPedTasks(ped)
            DeleteEntity(created_object)
            StopParticleFxLooped(effect, 0)
        end, function()
            ClearPedTasks(ped)
            DeleteEntity(created_object)
            StopParticleFxLooped(effect, 0)
            QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
        end)
    else
        QBCore.Functions.Notify(_U('missing_water'), 'error', 2500)
    end
end)

RegisterNetEvent('ps-weedplanting:client:GiveFertilizer', function(entity)
    if QBCore.Functions.HasItem(Shared.FertilizerItem, 1) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local model = `w_am_jerrycan_sf`
        TaskTurnPedToFaceEntity(ped, entity, 1.0)
        Wait(1500)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        local created_object = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(created_object, ped, GetPedBoneIndex(ped, 28422), 0.3, 0.1, 0.0, 90.0, 180.0, 0.0, true, true, false, true, 1, true)
        QBCore.Functions.Progressbar('weedplanting_fertilizer', _U('fertilizing_plant'), 6000, false, false, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'weapon@w_sp_jerrycan',
            anim = 'fire',
            flags = 1,
        }, {}, {}, function()
            TriggerServerEvent('ps-weedplanting:server:GiveFertilizer', netId)
            ClearPedTasks(ped)
            DeleteEntity(created_object)
        end, function()
            ClearPedTasks(ped)
            DeleteEntity(created_object)
            QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
        end)
    else
        QBCore.Functions.Notify(_U('missing_fertilizer'), 'error', 2500)
    end
end)

RegisterNetEvent('ps-weedplanting:client:AddMaleSeed', function(entity)
    if QBCore.Functions.HasItem(Shared.MaleSeed, 1) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        local ped = PlayerPedId()
        TaskTurnPedToFaceEntity(ped, entity, 1.0)
        Wait(1500)

        RequestAnimDict('amb@medic@standing@kneel@base')
        RequestAnimDict('anim@gangops@facility@servers@bodysearch@')
        while 
            not HasAnimDictLoaded('amb@medic@standing@kneel@base') or
            not HasAnimDictLoaded('anim@gangops@facility@servers@bodysearch@')
        do 
            Wait(0) 
        end
        TaskPlayAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
        TaskPlayAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)

        QBCore.Functions.Progressbar('add_maleseed', _U('adding_male_seed'), 8500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            TriggerServerEvent('ps-weedplanting:server:AddMaleSeed', netId)
            ClearPedTasks(ped)
            RemoveAnimDict('amb@medic@standing@kneel@base')
            RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
        end, function()
            QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
            ClearPedTasks(ped)
            RemoveAnimDict('amb@medic@standing@kneel@base')
            RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
        end)
    else
        QBCore.Functions.Notify(_U('missing_mseed'), 'error', 2500)
    end
end)

RegisterNetEvent('ps-weedplanting:client:UseBranch', function()
    QBCore.Functions.Progressbar('weedbranch', _U('processing_branch'), 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('ps-weedplanting:server:ProcessBranch')
    end, function() -- Cancel
        QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
    end)
end)

--- Threads

CreateThread(function()
    exports['qb-target']:AddTargetModel(Shared.WeedProps, {
        options = {
            {
                type = 'client',
                event = 'ps-weedplanting:client:CheckPlant',
                icon = 'fas fa-cannabis',
                label = _U('check_plant')
            }
        },
        distance = 1.5, 
    })
end)
