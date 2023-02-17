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
    end
end)

RegisterNetEvent('ps-weedplanting:server:PackageWeed', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item = Player.Functions.GetItemByName(Shared.WeedItem)
    if item and item.amount >= 20 then
        Player.Functions.RemoveItem(Shared.WeedItem, 20, item.slot)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.WeedItem], 'remove', 20)
        Player.Functions.AddItem(Shared.PackedWeedItem, 1, false)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.PackedWeedItem], 'add', 1)
    end
end)

--- Items

QBCore.Functions.CreateUseableItem(Shared.BranchItem, function(source)
    TriggerClientEvent('ps-weedplanting:client:UseBranch', source)
end)

QBCore.Functions.CreateUseableItem(Shared.WeedItem, function(source, item)
    if item and item.amount >= 20 then
        TriggerClientEvent('ps-weedplanting:client:UseDryWeed', source)
    else
        TriggerClientEvent('QBCore:Notify', src, _U('not_enough_dryweed'), 'error', 2500)
    end
end)