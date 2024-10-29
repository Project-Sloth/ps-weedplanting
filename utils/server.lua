utils = {}

utils.print = function(message)
    print('^3[' .. Config.Resource .. '] ^5' .. message .. '^7')
end

utils.notify = function(source, title, message, notifType, timeOut)
    TriggerClientEvent('ox_lib:notify', source, {
        title = title,
        description = message,
        duration = timeOut,
        type = notifType,
        position = 'center-right',
    })
end

utils.getCopCount = function()
    local amount = 0
    local Players = server.GetPlayers()

    for _, Player in pairs(Players) do
        if server.isPlayerPolice(Player) then
            amount += 1
        end
    end

    return amount
end
