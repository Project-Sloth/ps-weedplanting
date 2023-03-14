--- Events

RegisterNetEvent('ps-weedplanting:server:ProcessBranch', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item = Player.Functions.GetItemByName(Shared.BranchItem)
    if item and item.info.health then
        if Player.Functions.RemoveItem(Shared.BranchItem, 1, item.slot) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.BranchItem], 'remove', 1)
            Player.Functions.AddItem(Shared.WeedItem, item.info.health, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WeedItem], 'add', item.info.health)
        end
    elseif item then -- fallback if item.info.health is nil
        if Player.Functions.RemoveItem(Shared.BranchItem, 1, item.slot) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.BranchItem], 'remove', 1)
            Player.Functions.AddItem(Shared.WeedItem, Shared.ProcessingHealthFallback, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WeedItem], 'add', Shared.ProcessingHealthFallback)
        end
    end
end)

RegisterNetEvent('ps-weedplanting:server:PackageWeed', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item = Player.Functions.GetItemByName(Shared.WeedItem)
    if item and item.amount >= Shared.PackageAmount then
        Player.Functions.RemoveItem(Shared.WeedItem, Shared.PackageAmount, item.slot)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WeedItem], 'remove', Shared.PackageAmount)
        Player.Functions.AddItem(Shared.PackedWeedItem, 1, false)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.PackedWeedItem], 'add', 1)
    else
        TriggerClientEvent('QBCore:Notify', src,_U('not_enough_dryweed'), 'error')
    end
end)
