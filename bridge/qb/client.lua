if GetResourceState('qbx_core') == 'started' then return end
if GetResourceState('qb-core') ~= 'started' then return end

Config.Framework = 'qbcore'

client = {}

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

--- Event Handlers

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}

    clearWeedRun()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

--- Functions

client.isPlayerPolice = function()
    return PlayerData.job.type == 'leo' or PlayerData.job.name == 'police'
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
        return QBCore.Functions.HasItem(items, amount)
    end
end
