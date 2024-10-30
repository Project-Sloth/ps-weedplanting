if GetResourceState('es_extended') ~= 'started' then return end

Config.Framework = 'esx'

server = {}

ESX = exports['es_extended']:getSharedObject()

server.GetPlayerFromId = ESX.GetPlayerFromId
server.GetPlayers = ESX.GetExtendedPlayers

server.isPlayerPolice = function(Player)
    return Player.job.name == 'police'
end

server.getPlayerData = function(Player)
    return {
        source = Player.source,
        identifier = Player.identifier,
        name = GetPlayerName(Player.source),
    }
end

server.addMoney = function(Player, moneyType, amount, reason)
    if moneyType == 'cash' then
        Player.addAccountMoney('money', amount, reason)
        return true
    elseif moneyType == 'bank' then
        Player.addAccountMoney('bank', amount, reason)
        return true
    end

    return false
end

server.createLog = function(source, event, message)
    if Config.Logging == 'ox_lib' then
        lib.logger(source, event, message)
    elseif Config.Logging == 'esx' then
        ESX.DiscordLog('weedplanting', event, 'default', message)
    end
end

server.hasItem = function(source, items, amount)
    amount = amount or 1

    if Config.Inventory == 'ox_inventory' then
        local count = exports['ox_inventory']:Search(source, 'count', items)

        if type(items) == 'table' and type(count) == 'table' then
            for _, v in pairs(count) do
                if v < amount then
                    return false
                end
            end
    
            return true
        end
    
        return count >= amount
    else
        local Player = server.GetPlayerFromId(source)

        if type(items) == 'table' then
            for item in pairs(items) do
                local item = Player.hasItem(item)
                if not item or item.count < amount then
                    return false
                end
            end

            return true
        else
            local hasItem = ESX.SearchInventory(items, amount)
            return hasItem >= amount
        end
    end
end

server.removeItem = function(source, item, count, metadata, slot, ignoreTotal)
    if Config.Inventory == 'ox_inventory' then
        return exports['ox_inventory']:RemoveItem(source, item, count, metadata, slot, ignoreTotal)
    else
        local Player = server.GetPlayerFromId(source)
        Player.removeInventoryItem(item, count, metadata, slot)
        return true
    end
end

server.addItem = function(source, item, count, metadata, slot)
    if Config.Inventory == 'ox_inventory' then
        if exports['ox_inventory']:CanCarryItem(source, item, count, metadata) then
            return exports['ox_inventory']:AddItem(source, item, count, metadata, slot)
        else
            utils.notify(source, Locales['notify_title_planting'], Locales['notify_invent_full'], 'error', 5000)
            
            exports['ox_inventory']:CustomDrop(Locales['notify_title'], {
                { item, count, metadata }
            }, GetEntityCoords(GetPlayerPed(source)))
            return true
        end
    else
        local Player = server.GetPlayerFromId(source)
        if Player.canCarryItem(item, count) then
            Player.addInventoryItem(item, count, metadata, slot)
            return true
        else
            return false
        end
    end
end

server.getItem = function(source, itemName)
    if Config.Inventory == 'ox_inventory' then
        local items = exports['ox_inventory']:Search(source, 1, itemName)
        return items[1]
    else
        local Player = server.GetPlayerFromId(source)
        local item = Player.getInventoryItem(itemName)
        return item
    end
end

server.registerUseableItem = ESX.RegisterUsableItem
