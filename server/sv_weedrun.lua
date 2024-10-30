local packageCache = {}

--- Events

RegisterNetEvent('weedplanting:server:CollectPackageGoods', function()
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local identifier = Player.PlayerData.identifier
    if not packageCache[identifier] then return end

    if packageCache[identifier] == 'waiting' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = Locales['notify_title_run'],
            description = Locales['still_waiting'],
            duration = 2500,
            type = 'inform',
            position = 'center-right',
        })
    elseif packageCache[identifier] == 'done' then
        packageCache[identifier] = nil
        TriggerClientEvent('weedplanting:client:PackageGoodsReceived', src)
        exports['ox_inventory']:AddItem(src, Config.SusPackageItem, 1)
    end
end)

RegisterNetEvent('weedplanting:server:DestroyWaitForPackage', function()
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    local identifier = Player.PlayerData.identifier
    if not packageCache[identifier] then return end
    
    packageCache[identifier] = nil

    TriggerClientEvent('ox_lib:notify', src, {
        title = Locales['notify_title_run'],
        description = Locales['moved_too_far'],
        duration = 2500,
        type = 'inform',
        position = 'center-right',
    })
end)

RegisterNetEvent('weedplanting:server:WeedrunDelivery', function()
    local src = source
    local Player = server.GetPlayerFromId(src)
    if not Player then return end

    if server.removeItem(src, Config.SusPackageItem, 1) then
        Wait(2000)
        local payout = math.random(Config.PayOut[1], Config.PayOut[2])
        server.addMoney(Player, 'cash', payout, 'weedrun-delivery')

        server.createLog(PlayerData.name, 'Weedrun Delivery', PlayerData.name .. ' (identifier: ' .. PlayerData.identifier .. ' | id: ' .. src .. ')' .. ' Received ' .. payout .. ', cash for delivering package')
    end
end)

--- Callbacks

lib.callback.register('weedplanting:server:PackageGoods', function(source)
    local src = source
    local Player = server.GetPlayerFromId(src)
    local identifier = Player.PlayerData.identifier

    if packageCache[identifier] then return false end
    
    if not server.removeItem(src, Config.PackedWeedItem, 1) then
        return false
    end

    packageCache[identifier] = 'waiting'

    CreateThread(function()
        Wait(Config.PackageTime * 60 * 1000)

        if packageCache[identifier] then
            packageCache[identifier] = 'done'
        end
    end)

    return true
end)
