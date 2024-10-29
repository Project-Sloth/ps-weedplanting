utils = {}

utils.alertPolice = function()
    if GetResourceState('ps-dispatch') ~= 'started' then return end

    exports['ps-dispatch']:DrugSale() -- Project-Sloth ps-dispatch
end

utils.notify = function(title, message, notifType, timeOut)
    lib.notify({
        title = title,
        description = message,
        duration = timeOut,
        type = notifType,
        position = 'center-right',
    })
end

utils.phoneNotification = function(title, message, icon, hex, timeOut)
    TriggerEvent('qb-phone:client:CustomNotification', title, message, icon, hex, timeOut)
end
