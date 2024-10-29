if GetResourceState('qbx_core') == 'started' then return end
if GetResourceState('qb-core') ~= 'started' then return end

Config.Framework = 'qbcore'

server = {}

QBCore = exports['qb-core']:GetCoreObject()

server.GetPlayerFromId = QBCore.Functions.GetPlayer
server.GetPlayers = QBCore.Functions.GetQBPlayers

server.isPlayerPolice = function(Player)
    return (Player.PlayerData.job.type == 'leo' or Player.PlayerData.job.name == 'police') and Player.PlayerData.job.onduty
end

server.getPlayerData = function(Player)
    return {
        source = Player.PlayerData.source,
        identifier = Player.PlayerData.identifier,
        name = Player.PlayerData.name,
    }
end

server.addMoney = function(Player, moneyType, amount, reason)
    return Player.Functions.AddMoney(moneyType, amount, reason)
end

server.createLog = function(source, event, message)
    if Config.Logging == 'ox_lib' then
        lib.logger(source, event, message)
    elseif Config.Logging == 'qb' then
        TriggerEvent('qb-log:server:CreateLog', 'weedplanting', event, 'default', message)
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
        return QBCore.Functions.HasItem(source, items, amount)
    end
end

server.removeItem = function(source, item, count, metadata, slot, ignoreTotal)
    if Config.Inventory == 'ox_inventory' then
        return exports['ox_inventory']:RemoveItem(source, item, count, metadata, slot, ignoreTotal)
    elseif Config.Inventory == 'qb-inventory' then
        return exports['qb-inventory']:RemoveItem(source, item, count, slot, 'weedplanting-remove')
    elseif Config.Inventory == 'ps-inventory' then
        return exports['ps-inventory']:RemoveItem(source, item, count, slot)
    else
        local Player = server.GetPlayerFromId(source)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove', count)
        return Player.Functions.RemoveItem(item, count, slot)
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
    elseif Config.Inventory == 'qb-inventory' then
        if exports['qb-inventory']:CanAddItem(source, item, count) then
            exports['qb-inventory']:AddItem(source, item, count, slot, metadata, 'weedplanting reward')
            return true
        else
            return false
        end
    elseif Config.Inventory == 'ps-inventory' then
        return exports['ps-inventory']:AddItem(source, item, count, slot, metadata)        
    else
        local Player = server.GetPlayerFromId(source)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add', count)
        return Player.Functions.AddItem(item, count, slot, metadata)
    end
end

server.getItem = function(source, itemName)
    if Config.Inventory == 'ox_inventory' then
        local items = exports['ox_inventory']:Search(source, 1, itemName)
        return items[1]
    elseif Config.Inventory == 'qb-inventory' then
        local item = exports['qb-inventory']:GetItemByName(source, itemName)
        return item
    elseif Config.Inventory == 'ps-inventory' then
        local item = exports['ps-inventory']:GetItemByName(source, itemName)
        return item
    else
        local Player = server.GetPlayerFromId(source)
        local item = Player.Functions.GetItemByName(itemName)
        return item
    end
end

server.setMetaData = function(source, slot, metadata)
    if Config.Inventory == 'ox_inventory' then
        metadata.durability = math.floor(metadata.uses * 100 / Config.LaptopUses)
        exports['ox_inventory']:SetMetadata(source, slot, metadata)
    else
        local Player = server.GetPlayerFromId(source)
        Player.PlayerData.items[slot].info = metadata
        Player.Functions.SetInventory(Player.PlayerData.items)
    end
end

server.registerUseableItem = QBCore.Functions.CreateUseableItem
