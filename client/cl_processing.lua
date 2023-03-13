local props = {}

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

local function openHouseAnim()
    local ped = PlayerPedId()
    loadAnimDict("anim@heists@keycard@")
    TaskPlayAnim(ped, "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Wait(100)
    if Shared.WeedLab.EnableSound then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "LockerOpen", 0.1)
    end
    DoScreenFadeOut(800)
    Wait(850)
    DoScreenFadeIn(900)
    ClearPedTasks(ped)
end

local function SpawnWeedProcessProps()
    for k, v in pairs(Shared.ProcessingProps) do
	    props[#props+1] = CreateObject(v.model,vector3(v.coords.x,v.coords.y,v.coords.z-1.00))
	    SetEntityHeading(props[#props],v.coords.w)
        FreezeEntityPosition(props, true)
    end
end

CreateThread(function ()
    
    SpawnWeedProcessProps()

    exports['qb-target']:AddBoxZone('weedprocess', vector3(1045.4, -3197.62, -38.16), 2.3, 1.0, {
        name = 'weedprocess',
        heading = 0,
        minZ = -41.16,
        maxZ = -37.50,
        debugPoly = Shared.Debug,
    }, {
        options = {
            {
                type = 'client',
                event = 'ps-weedplanting:client:ProcessBranch',
                icon = 'fa-solid fa-cannabis',
                label = _U('process_branch'),
            },
            { -- Create Package
                type = 'client',
                event = 'ps-weedplanting:client:PackDryWeed',
                icon = 'fa-solid fa-box',
                label = _U('pack_dry_weed'),
            }
           
        },
        distance = 1.5
    })
    if Shared.WeedLab.EnableTp then
        exports['qb-target']:AddBoxZone('weedlab-enter', vector3(-66.95, -1311.66, 29.27), 1.5, 0.5, {
            name = 'weedlab-enter',
            heading = 90,
            minZ = 29.27 - 2,
            maxZ = 29.27 + 2,
            debugPoly = Shared.Debug,
        }, {
            options = {
                {
                    type = 'client',
                    event = 'ps-weedplanting:client:EnterLab',
                    icon = 'fa-solid fa-warehouse',
                    label = _U('enter_weedlab'),
                }
            },
            distance = 1.5
        })
        exports['qb-target']:AddBoxZone('weedlab-exit', vector3(1066.65, -3183.45, -39.16), 1.5, 0.5, {
            name = 'weedlab-exit',
            heading = 0,
            minZ = -39.16 - 2,
            maxZ = -39.16 + 2,
            debugPoly = Shared.Debug,
        }, {
            options = {
                {
                    type = 'client',
                    event = 'ps-weedplanting:client:ExitLab',
                    icon = 'fa-solid fa-warehouse',
                    label = _U('exit_weedlab'),
                }
            },
            distance = 1.5
        })
    end
end)


RegisterNetEvent('ps-weedplanting:client:EnterLab', function()
    
    local hasItem = QBCore.Functions.HasItem(Shared.LabkeyItem)
    
    if Shared.WeedLab.RequireKey then
        if not hasItem then
            QBCore.Functions.Notify(_U('dont_have_key'), 'error')
            return
        end
    end
    local ped = PlayerPedId()    
    openHouseAnim()
    SetEntityCoords(ped, 1066.2, -3183.38, -39.16)
    SetEntityHeading(ped, 89.3)
end)

RegisterNetEvent('ps-weedplanting:client:ExitLab', function()
    
    local hasItem = QBCore.Functions.HasItem(Shared.LabkeyItem)
    
    if Shared.WeedLab.RequireKey then
        if not hasItem then
            QBCore.Functions.Notify(_U('dont_have_key'), 'error')
            return
        end
    end
    local ped = PlayerPedId()    
    openHouseAnim()
    SetEntityCoords(ped, -66.95, -1312.37, 29.28)
    SetEntityHeading(ped, 180.95)
end)

RegisterNetEvent('ps-weedplanting:client:ProcessBranch', function()
    
    local hasItem = QBCore.Functions.HasItem(Shared.BranchItem, 1)
    
    if not hasItem then
        QBCore.Functions.Notify(_U('dont_have_branch'), 'error', 2500)
        return
    end

    local ped = PlayerPedId()
    local table = vector4(1045.4, -3197.62, -38.16, 0.0)

    TaskTurnPedToFaceCoord(ped, table, 1000)
    Wait(1300)
  
    QBCore.Functions.Progressbar('weedbranch', _U('processing_branch'), 12000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 8, }, {}, {}, function()
        TriggerServerEvent('ps-weedplanting:server:ProcessBranch')
    end, function() -- Cancel
        QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
        ClearPedTasks(ped)
    end)
end)

RegisterNetEvent('ps-weedplanting:client:PackDryWeed', function()
    
    local hasItem = QBCore.Functions.HasItem(Shared.WeedItem)
    
    if not hasItem then
        QBCore.Functions.Notify(_U('dont_have_enough_dryweed'), 'error', 2500)
        return
    end
  
    local ped = PlayerPedId()
    local table = vector4(1045.4, -3197.62, -38.16, 0.0)

    TaskTurnPedToFaceCoord(ped, table, 1000)
    Wait(1300)
   
    QBCore.Functions.Progressbar('dryweed', _U('packaging_weed'), 12000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 8, }, {}, {}, function()
        TriggerServerEvent('ps-weedplanting:server:PackageWeed')
    end, function() -- Cancel
        QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
        ClearPedTasks(ped)
    end)
end)
