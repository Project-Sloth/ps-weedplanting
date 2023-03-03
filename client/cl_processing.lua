local props = {}

function SpawnWeedProcessProps()
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
