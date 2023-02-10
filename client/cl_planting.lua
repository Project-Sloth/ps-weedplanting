local seedUsed = false

--- Functions

local RotationToDirection = function(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end
  
local RayCastCamera = function(dist)
    local camRot = GetGameplayCamRot()
    local camPos = GetGameplayCamCoord()
    local dir = RotationToDirection(camRot)
    local dest = camPos + (dir * dist)
    local ray = StartShapeTestRay(camPos, dest, 17, -1, 0)
    local _, hit, endPos, surfaceNormal, entityHit = GetShapeTestResult(ray)
    if hit == 0 then endPos = dest end
    return hit, endPos, entityHit, surfaceNormal
end

--- Events

RegisterNetEvent('ps-weedplanting:client:UseWeedSeed', function()
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then return end
    if seedUsed then return end
    seedUsed = true
    local ModelHash = Shared.WeedProps[1]
    RequestModel(ModelHash)
    while not HasModelLoaded(ModelHash) do Wait(0) end
    exports['qb-core']:DrawText(_U('place_or_cancel'), 'left')
    local hit, dest, _, _ = RayCastCamera(Shared.rayCastingDistance)
    local plant = CreateObject(ModelHash, dest.x, dest.y, dest.z + Shared.ObjectZOffset, false, false, false)
    SetEntityCollision(plant, false, false)
    SetEntityAlpha(plant, 80, true)

    local planted = false
    while not planted do
        Wait(0)
        hit, dest, _, _ = RayCastCamera(Shared.rayCastingDistance)
        if hit == 1 then
            SetEntityCoords(plant, dest.x, dest.y, dest.z + Shared.ObjectZOffset)

            -- [E] To spawn plant
            if IsControlJustPressed(0, 38) then
                planted = true
                exports['qb-core']:KeyPressed(38)
                DeleteObject(plant)
                local ped = PlayerPedId()
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
                QBCore.Functions.Progressbar('spawn_plant', _U('place_sapling'), 2000, false, true, {
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() 
                    TriggerServerEvent('ps-weedplanting:server:CreateNewPlant', dest)
                    planted = false
                    seedUsed = false
                    ClearPedTasks(ped)
                    RemoveAnimDict('amb@medic@standing@kneel@base')
                    RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
                end, function() 
                    QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
                    planted = false
                    seedUsed = false
                    ClearPedTasks(ped)
                    RemoveAnimDict('amb@medic@standing@kneel@base')
                    RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
                end)
            end
            
            -- [G] to cancel
            if IsControlJustPressed(0, 47) then
                exports['qb-core']:KeyPressed(47)
                planted = false
                seedUsed = false
                DeleteObject(plant)
                return
            end
        end
    end
end)
