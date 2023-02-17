local packageCache = {}

--- Events

RegisterNetEvent('ps-weedplanting:server:CollectPackageGoods', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    if not packageCache[citizenid] then return end

    if packageCache[citizenid] == 'waiting' then
        TriggerClientEvent('QBCore:Notify', src, _U('still_waiting'), 'error', 2500)
    elseif packageCache[citizenid] == 'done' then
        packageCache[citizenid] = nil
        TriggerClientEvent('ps-weedplanting:client:PackageGoodsReceived', src)
        if Player.Functions.AddItem(Shared.SusPackageItem, 1) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.SusPackageItem], 'add', 1)
        end
    end
end)

RegisterNetEvent('ps-weedplanting:server:DestroyWaitForPackage', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    if not packageCache[citizenid] then return end
    
    packageCache[citizenid] = nil
    TriggerClientEvent('QBCore:Notify', src, _U('moved_too_far'), 'error', 2500)
end)

RegisterNetEvent('ps-weedplanting:server:WeedrunDelivery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveItem(Shared.SusPackageItem, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.SusPackageItem], 'remove', 1)
        Wait(2000)
        local payout = math.random(Shared.PayOut[1], Shared.PayOut[2])
        Player.Functions.AddMoney('cash', payout)
    end
end)

--- Callbacks

QBCore.Functions.CreateCallback('ps-weedplanting:server:PackageGoods', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    if packageCache[citizenid] then
        cb(false)
        return
    end
    
    if Player.Functions.RemoveItem(Shared.PackedWeedItem, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Shared.PackedWeedItem], 'remove', 1)
    else
        cb(false)
        return
    end

    packageCache[citizenid] = 'waiting'
    cb(true)

    CreateThread(function()
        Wait(Shared.PackageTime * 60 * 1000)
        if packageCache[citizenid] then
            packageCache[citizenid] = 'done'
        end
    end)
end)
