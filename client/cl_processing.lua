--- Events

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

RegisterNetEvent('ps-weedplanting:client:UseDryWeed', function()
    QBCore.Functions.Progressbar('dryweed', _U('packaging_weed'), 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('ps-weedplanting:server:PackageWeed')
    end, function() -- Cancel
        QBCore.Functions.Notify(_U('canceled'), 'error', 2500)
    end)
end)
