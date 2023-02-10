local package
local hasPackage = false

--- Functions

--- Creates a new suspicious package object and makes the player unable to run
--- @return nil
local createPackage = function()
    if not hasPackage then
        -- Animation
        local ped = PlayerPedId()
        RequestAnimDict('anim@heists@box_carry@')
        while not HasAnimDictLoaded('anim@heists@box_carry@') do Wait(0) end
        TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)

        -- Package
        local pos = GetEntityCoords(ped, true)
        RequestModel(Shared.PackageProp)
        while not HasModelLoaded(Shared.PackageProp) do Wait(0) end
        local object = CreateObject(Shared.PackageProp, pos.x, pos.y, pos.z, true, true, true)
        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 57005), 0.1, 0.1, -0.25, 300.0, 250.0, 15.0, true, true, false, true, 1, true)
        package = object
        hasPackage = true
        
        -- Walk
        CreateThread(function()
            while hasPackage do
                Wait(0)
                SetPlayerSprint(PlayerId(), false)
                DisableControlAction(0, 21, true)
                if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
                    TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
                end
            end
        end)
    end
end

--- Deletes the package object
--- @return nil
local destroyPackage = function()
    StopAnimTask(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 1.0)
    DetachEntity(package, true, true)
    DeleteObject(package)
    ClearPedTasks(PlayerPedId())
    package = nil
    hasPackage = false
end

--- Checks if a player has a suspicious package on him or her
--- @return nil
local checkPackage = function()
    Wait(250) -- May have to increase this to 500 or 1000 so the core/invent can catch up
    if QBCore.Functions.HasItem(Shared.SusPackageItem, 1) then
        createPackage()
    else
        destroyPackage()
    end
end

--- Events

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    checkPackage()
end)