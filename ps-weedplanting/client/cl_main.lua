QBCore = exports['qb-core']:GetCoreObject()
PlayerJob = QBCore.Functions.GetPlayerData().job

-- Player load, unload and update handlers

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerJob = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

-- Events

RegisterNetEvent('ps-weedplanting:client:CheckPlant', function(data)
    local netId = NetworkGetNetworkIdFromEntity(data.entity)
    QBCore.Functions.TriggerCallback('ps-weedplanting:server:GetPlantData', function(result)
        if not result then return end

        if result.health == 0 then -- Destroy plant
            exports['qb-menu']:openMenu({
                {
                    header = "Cannabis Plant",
                    txt = "ESC or click to close",
                    icon = "fas fa-chevron-left",
                    params = {
                        event = "qb-menu:closeMenu"
                    }
                },
                {
                    header = "Clear Plant",
                    txt = "The plant is dead..",
                    icon = "fas fa-skull-crossbones",
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
                        header = "Cannabis Plant",
                        txt = "ESC or click to close",
                        icon = "fas fa-chevron-left",
                        params = {
                            event = "qb-menu:closeMenu"
                        }
                    },
                    {
                        header = "Stage: " .. result.stage .. " - Health: " .. result.health,
                        txt = "This plant is ready for harvest!",
                        icon = "fas fa-scissors",
                        params = {
                            event = 'ps-weedplanting:client:HarvestPlant',
                            args = data.entity
                        }
                    },
                    {
                        header = "Destroy Plant",
                        txt = "This plant is ready for harvest!",
                        icon = "fas fa-fire",
                        params = {
                            event = 'ps-weedplanting:client:PoliceDestroy',
                            args = data.entity
                        }
                    }
                })
            else
                exports['qb-menu']:openMenu({
                    {
                        header = "Cannabis Plant",
                        txt = "ESC or click to close",
                        icon = "fas fa-chevron-left",
                        params = {
                            event = "qb-menu:closeMenu"
                        }
                    },
                    {
                        header = "Stage: " .. result.stage .. " - Health: " .. result.health,
                        txt = "This plant is ready for harvest!",
                        icon = "fas fa-scissors",
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
                        header = "Cannabis Plant",
                        txt = "ESC or click to close",
                        icon = "fas fa-chevron-left",
                        params = {
                            event = "qb-menu:closeMenu"
                        }
                    },
                    {
                        header = "Growth: " .. result.growth .. "%" .. " - Stage: " .. result.stage,
                        txt = "Health: " .. result.health,
                        icon = "fas fa-chart-simple",
                        isMenuHeader = true
                    },
                    {
                        header = "Destroy Plant",
                        txt = "This plant is ready for harvest!",
                        icon = "fas fa-fire",
                        params = {
                            event = 'ps-weedplanting:client:PoliceDestroy',
                            args = data.entity
                        }
                    }
                })
            else
                exports['qb-menu']:openMenu({
                    {
                        header = "Cannabis Plant",
                        txt = "ESC or click to close",
                        icon = "fas fa-chevron-left",
                        params = {
                            event = "qb-menu:closeMenu"
                        }
                    },
                    {
                        header = "Growth: " .. result.growth .. "%" .. " - Stage: " .. result.stage,
                        txt = "Health: " .. result.health,
                        icon = "fas fa-chart-simple",
                        isMenuHeader = true
                    },
                    {
                        header = "Water: " .. result.water .. "%",
                        txt = "Add water to the patch",
                        icon = "fas fa-shower",
                        params = {
                            event = "ps-weedplanting:client:GiveWater",
                            args = data.entity
                        }
                    },
                    {
                        header = "Fertilizer: " .. result.nutrition .. "%",
                        txt = "Add fertilizer to the patch",
                        icon = "fab fa-nutritionix",
                        params = {
                            args = data.entity,
                            event = "ps-weedplanting:client:GiveFertilizer",
                        }
                    },
                    {
                        header = "Gender: " .. result.gender,
                        txt = "Add Male Seeds",
                        icon = "fas fa-venus",
                        params = {
                            args = data.entity,
                            event = "ps-weedplanting:client:AddMaleSeed",
                        }
                    }
                })
            end
        else -- No option to add male seed
            if PlayerJob.type == 'leo' and PlayerJob.onduty then
                exports['qb-menu']:openMenu({
                    {
                        header = "Cannabis Plant",
                        txt = "ESC or click to close",
                        icon = "fas fa-chevron-left",
                        params = {
                            event = "qb-menu:closeMenu"
                        }
                    },
                    {
                        header = "Growth: " .. result.growth .. "%" .. " - Stage: " .. result.stage,
                        txt = "Health: " .. result.health,
                        icon = "fas fa-chart-simple",
                        isMenuHeader = true
                    },
                    {
                        header = "Destroy Plant",
                        txt = "This plant is ready for harvest!",
                        icon = "fas fa-fire",
                        params = {
                            event = 'ps-weedplanting:client:PoliceDestroy',
                            args = data.entity
                        }
                    },
                })
            else
                exports['qb-menu']:openMenu({
                    {
                        header = "Cannabis Plant",
                        txt = "ESC or click to close",
                        icon = "fas fa-chevron-left",
                        params = {
                            event = "qb-menu:closeMenu"
                        }
                    },
                    {
                        header = "Growth: " .. result.growth .. "%" .. " - Stage: " .. result.stage,
                        txt = "Health: " .. result.health,
                        icon = "fas fa-chart-simple",
                        isMenuHeader = true
                    },
                    {
                        header = "Water: " .. result.water .. "%",
                        txt = "Add water to the patch",
                        icon = "fas fa-shower",
                        params = {
                            event = "ps-weedplanting:client:GiveWater",
                            args = data.entity
                        }
                    },
                    {
                        header = "Fertilizer: " .. result.nutrition .. "%",
                        txt = "Add fertilizer to the patch",
                        icon = "fab fa-nutritionix",
                        params = {
                            args = data.entity,
                            event = "ps-weedplanting:client:GiveFertilizer",
                        }
                    },
                    {
                        header = "Gender: " .. result.gender,
                        txt = "Add Male Seeds",
                        icon = "fas fa-mars",
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

    RequestAnimDict("amb@medic@standing@kneel@base")
    RequestAnimDict("anim@gangops@facility@servers@bodysearch@")
    while 
        not HasAnimDictLoaded("amb@medic@standing@kneel@base") or
        not HasAnimDictLoaded("anim@gangops@facility@servers@bodysearch@")
    do 
        Wait(0) 
    end
    TaskPlayAnim(ped, "amb@medic@standing@kneel@base", "base", 8.0, 8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(ped, "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, 8.0, -1, 48, 0, false, false, false)

    QBCore.Functions.Progressbar("clear_plant", "Clearing Plant", 8500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('ps-weedplanting:server:ClearPlant', netId)
        ClearPedTasks(ped)
        RemoveAnimDict("amb@medic@standing@kneel@base")
        RemoveAnimDict("anim@gangops@facility@servers@bodysearch@")
    end, function()
        QBCore.Functions.Notify("Cancelled..", "error", 2500)
        ClearPedTasks(ped)
        RemoveAnimDict("amb@medic@standing@kneel@base")
        RemoveAnimDict("anim@gangops@facility@servers@bodysearch@")
    end)
end)

RegisterNetEvent('ps-weedplanting:client:HarvestPlant', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(1500)

    RequestAnimDict("amb@medic@standing@kneel@base")
    RequestAnimDict("anim@gangops@facility@servers@bodysearch@")
    while 
        not HasAnimDictLoaded("amb@medic@standing@kneel@base") or
        not HasAnimDictLoaded("anim@gangops@facility@servers@bodysearch@")
    do 
        Wait(0) 
    end
    TaskPlayAnim(ped, "amb@medic@standing@kneel@base", "base", 8.0, 8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(ped, "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, 8.0, -1, 48, 0, false, false, false)

    QBCore.Functions.Progressbar("harvest_plant", "Harvesting Plant", 8500, false, true, {
        disableMovement = true, 
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('ps-weedplanting:server:HarvestPlant', netId)
        ClearPedTasks(ped)
        RemoveAnimDict("amb@medic@standing@kneel@base")
        RemoveAnimDict("anim@gangops@facility@servers@bodysearch@")
    end, function()
        QBCore.Functions.Notify("Canceled..", "error", 2500)
        ClearPedTasks(ped)
        RemoveAnimDict("amb@medic@standing@kneel@base")
        RemoveAnimDict("anim@gangops@facility@servers@bodysearch@")
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

    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do Wait(10) end
    SetPtfxAssetNextCall("core")
    local effect = StartParticleFxLoopedAtCoord("ent_ray_paleto_gas_flames", coords.x, coords.y, coords.z + 0.5, 0.0, 0.0, 0.0, 0.6, false, false, false, false)
    Wait(Shared.FireTime)
    StopParticleFxLooped(effect, 0)
end)

RegisterNetEvent('ps-weedplanting:client:GiveWater', function(entity)

end)

RegisterNetEvent('ps-weedplanting:client:GiveFertilizer', function(entity)

end)

-- Threads

CreateThread(function()
    exports['qb-target']:AddTargetModel(Shared.WeedProps, {
        options = {
            {
                type = 'client',
                event = 'ps-weedplanting:client:CheckPlant',
                icon = 'fas fa-cannabis',
                label = 'Check Plant'
            }
        },
        distance = 2.5, 
    })
end)
