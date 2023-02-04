local planted = false

RegisterNetEvent('ps-weedplanting:client:UseWeedSeed', function()
    if planted then return end
    local ModelHash = Shared.WeedProps[1]
    RequestModel(ModelHash)
    while not HasModelLoaded(ModelHash) do Wait(0) end
    exports['qb-core']:DrawText(_U('place_or_cancel'), 'left')
    local hit, dest, _, _ = RayCastCamera(Shared.rayCastingDistance)
    local plant = CreateObject(ModelHash, dest.x, dest.y, dest.z, false, false, false)
    SetEntityCollision(plant, false, false)
    SetEntityAlpha(plant, 80, true)

    while not planted do
        Wait(0)
        hit, dest, _, _ = RayCastCamera(Shared.rayCastingDistance)
        if hit == 1 then
            SetEntityCoords(plant, dest.x, dest.y, dest.z)

            -- [E] To spawn plant
            if IsControlJustPressed(0, 38) then
                planted = true
                exports['qb-core']:KeyPressed(38)
                DeleteObject(plant)

                QBCore.Functions.Progressbar("spawn_plant", _U('place_sapling'), 2000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                }, {}, {}, {}, function() 
                    TriggerServerEvent('ps-weedplanting:server:CreateNewPlant', dest)
                    planted = false
                end, function() 
                    QBCore.Functions.Notify(_U('canceled'), "error")
                    planted = false
                end)
            end
            
            -- [G] to cancel
            if IsControlJustPressed(0, 47) then
                exports['qb-core']:KeyPressed(47)
                planted = false
                DeleteObject(plant)
                return
            end
        end
    end
end)

RegisterCommand('test', function()
    TriggerEvent('ps-weedplanting:client:UseWeedSeed')
end, false)
