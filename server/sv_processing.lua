--- Process Branch

server.registerUseableItem(Config.BranchItem, function(source, item)
    if not server.hasItem(source, item.name) then return end

    local removeItem = lib.callback.await('weedplanting:client:UseBranch', source)

    if removeItem then
        local item = server.getItem(source, Config.BranchItem)

        if not item then return end
    
        local health = item?.metadata.health or item?.info.health or 100

        if server.removeItem(source, item.name, 1, item.metadata or item.info, item.slot) then
            server.addItem(source, Config.WeedItem, health)
        end
    end
end)

--- Package Bags

server.registerUseableItem(Config.WeedItem, function(source, item)
    local hasItem = server.hasItem(src, Config.WeedItem, 20)

    if hasItem then
        local removeItem = lib.callback.await('weedplanting:client:UseDryWeed', source)

        if removeItem then
            if server.removeItem(src, Config.WeedItem, 20) then
                server.addItem(src, Config.PackedWeedItem, 1)
            end
        end
    else
        utils.notify(src, Locales['notify_title_processing'], Locales['not_enough_dryweed'], 'error', 2500)
    end
end)
