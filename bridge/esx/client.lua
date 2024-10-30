if GetResourceState('es_extended') ~= 'started' then return end

Config.Framework = 'esx'

client = {}

ESX = exports['es_extended']:getSharedObject()
local PlayerData = ESX.GetPlayerData()

--- Event Handlers

RegisterNetEvent("esx:playerLoaded", function()
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent("esx:onPlayerLogout", function()
    PlayerData = {}

    clearWeedRun()
end)

RegisterNetEvent('esx:setJob', function(job, lastJob)
    PlayerData.job = job
end)

--- Functions

client.isPlayerPolice = function()
    return PlayerData.job.name == 'police'
end

client.hasItems = function(items, amount)
    amount = amount or 1

    if Config.Inventory == 'ox_inventory' then
        local count = exports['ox_inventory']:Search('count', items)

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
        if type(items) == 'table' then
            for item in pairs(items) do
                if not ESX.SearchInventory(items, amount) then
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