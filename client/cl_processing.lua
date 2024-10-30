--- Callbacks

lib.callback.register('weedplanting:client:UseBranch', function()
    if lib.progressBar({
        duration = 5000,
        label = Locales['processing_branch'],
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false },
    }) then
        return true
    else
        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
        return false
    end
end)

lib.callback.register('weedplanting:client:UseDryWeed', function()
    if lib.progressBar({
        duration = 5000,
        label = Locales['packaging_weed'],
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false },
    }) then
        return true
    else
        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)
        return false
    end
end)
