local package
local hasPackage = false

local waitingForPackage = false
local packageZone

local delivering = false
local dropOffBlip
local hasDropOff = false
local dropOffArea
local deliveryPed
local madeDeal = false

--- Functions

--- Checks if a player has a suspicious package on him or her
---@return nil
local checkPackage = function()
    if not hasPackage then
        -- Animation
        local ped = cache.ped
        local pos = GetEntityCoords(ped, true)

        lib.playAnim(ped, 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)

        -- Package
        lib.requestModel(Config.PackageProp)
        local object = CreateObject(Config.PackageProp, pos.x, pos.y, pos.z, true, true, true)
        SetModelAsNoLongerNeeded(Config.PackageProp)

        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 57005), 0.1, 0.1, -0.25, 300.0, 250.0, 15.0, true, true, false, true, 1, true)
        package = object
        hasPackage = true
        
        -- Walk
        CreateThread(function()
            while hasPackage do
                Wait(0)
                SetPlayerSprint(cache.playerId, false)
                DisableControlAction(0, 21, true)
                DisableControlAction(0, 22, true)

                if not IsEntityPlayingAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3) then
                    lib.playAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
                end
            end
        end)
    end
end

--- Creates a drop off blip at a given coordinate
---@param coords vector4 - Coordinates of a location
local createDropOffBlip = function(coords)
	dropOffBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(dropOffBlip, 140)
    SetBlipColour(dropOffBlip, 25)
    SetBlipAsShortRange(dropOffBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Locales['weedrun_delivery_blip'])
    EndTextCommandSetBlipName(dropOffBlip)
end

--- Creates a drop off ped at a given coordinate
---@param coords vector4 - Coordinates of a location
---@return nil
local createDropOffPed = function(coords)
	if deliveryPed then return end
	local model = Config.DropOffPeds[math.random(#Config.DropOffPeds)]
	local hash = joaat(model)

    lib.requestModel(hash)
    deliveryPed = CreatePed(5, hash, coords.x, coords.y, coords.z - 1.0, coords.w, true, true)
	while not DoesEntityExist(deliveryPed) do Wait(0) end
    SetModelAsNoLongerNeeded(hash)

	ClearPedTasks(deliveryPed)
    ClearPedSecondaryTask(deliveryPed)
    TaskSetBlockingOfNonTemporaryEvents(deliveryPed, true)
    SetPedFleeAttributes(deliveryPed, 0, 0)
    SetPedCombatAttributes(deliveryPed, 17, 1)
    SetPedSeeingRange(deliveryPed, 0.0)
    SetPedHearingRange(deliveryPed, 0.0)
    SetPedAlertness(deliveryPed, 0)
    SetPedKeepTask(deliveryPed, true)
	FreezeEntityPosition(deliveryPed, true)

    if Config.Target == 'ox_target' then
        exports['ox_target']:addLocalEntity(deliveryPed, {
            {
                name = 'weedrun_deliver',
                event = 'weedplanting:client:DeliverWeed',
                icon = 'fas fa-cannabis',
                label = Locales['deliver_package'],
                distance = 2.0,
            },
        })
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:AddTargetEntity(deliveryPed, {
            options = {
                {
                    type = 'client',
                    event = 'weedplanting:client:DeliverWeed',
                    icon = 'fas fa-cannabis',
                    label = Locales['deliver_package'],
                }
            },
            distance = 2.0
        })
    end
end

--- Deletes the oxy ped
---@return nil
local deleteDeliveryPed = function()
	local ped = deliveryPed
	FreezeEntityPosition(ped, false)
	SetPedKeepTask(ped, false)
	TaskSetBlockingOfNonTemporaryEvents(ped, false)
	ClearPedTasks(ped)
	TaskWanderStandard(ped, 10.0, 10)
	SetPedAsNoLongerNeeded(ped)
	Wait(20000)
	DeletePed(ped)
	deliveryPed = nil
end

--- Method to create a drop-off location for delivering the weedrun packages
---@return nil
local createNewDropOff = function()
    if hasDropOff then return end
    hasDropOff = true

    utils.phoneNotification(Locales['weedrun_delivery_title'], Locales['weedrun_delivery_godropoff'], 'fas fa-cannabis', '#00FF00', 8000)
    
    local randomLoc = Config.DropOffLocations[math.random(#Config.DropOffLocations)]
    createDropOffBlip(randomLoc)

    dropOffArea = lib.zones.sphere({
        coords = randomLoc.xyz,
        radius = 85,
        debug = false,
        onEnter = function()
            if not deliveryPed then
				utils.phoneNotification(Locales['weedrun_delivery_title'], Locales['weedrun_delivery_makedropoff'], 'fas fa-cannabis', '#00FF00', 8000)
				createDropOffPed(randomLoc)
			end
        end,
        onExit = function()
			if deliveryPed then
				deleteDeliveryPed()
			end
		end
    })
end

--- Method to clear current weed run
---@return nil
clearWeedRun = function()
    -- Deliveries
    delivering = false
    hasDropOff = false
    RemoveBlip(dropOffBlip)
    
    if dropOffArea then
        dropOffArea:remove()
        DeletePed(deliveryPed)
	    deliveryPed = nil
    end

    -- Package
    if package then
        DetachEntity(package, true, true)
        DeleteObject(package)
        StopAnimTask(cache.ped, 'anim@heists@box_carry@', 'idle', 1.0)
        
        package = nil
        hasPackage = false
    end
end

--- Events

--- OxInventory: when inventory is updated, this eventhandler will check if the player still has suspicious packages

AddEventHandler('ox_inventory:itemCount', function(name, count)
    if name ~= Config.SusPackageItem then return end

    if count > 0 then
        checkPackage()
    elseif hasPackage then
        DetachEntity(package, true, true)
        DeleteObject(package)
        StopAnimTask(cache.ped, 'anim@heists@box_carry@', 'idle', 1.0)
        package = nil
        hasPackage = false
    end
end)


--- QBCore: when the inventory is changed this event will be triggered

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    Wait(250) -- May have to increase this to 500 or 1000 so the core/invent can catch up, you also may want to throw out qb-inventory and just get ox_inventory...

    if client.hasItems(Config.SusPackageItem, 1) then
        checkPackage()
    end
end)

RegisterNetEvent('weedplanting:client:StartPackage', function(data)
    if waitingForPackage then return end

    if not client.hasItems(Config.PackedWeedItem, 1) then
        return utils.notify(Locales['notify_title_run'], Locales['dont_have_anything'], 'error', 3000)
    end

    local ped = cache.ped
    FreezeEntityPosition(ped, true)
    TaskTurnPedToFaceEntity(ped, data.entity, 1.0)
    Wait(1500)
    
    PlayAmbientSpeech1(ped, 'Generic_Hi', 'Speech_Params_Force')
    Wait(1000)

    lib.playAnim(ped, 'mp_safehouselost@', 'package_dropoff', 8.0, 1.0, -1, 16, 0, 0, 0, 0)

    if lib.progressBar({
        duration = 4000,
        label = Locales['handing_over_weed'],
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false },
    }) then
        FreezeEntityPosition(ped, false)

        local result = lib.callback.await('weedplanting:server:PackageGoods', 200)

        if not result then return end
        waitingForPackage = true

        utils.notify(Locales['notify_title_run'], Locales['wait_closeby'], 'inform', 3000)

        packageZone = lib.zones.sphere({
            coords = Config.WeedRunStart.xyz,
            radius = 10.0,
            debug = false,
            onExit = function(self)
                self:remove()
                packageZone = nil

                if waitingForPackage then
                    TriggerServerEvent('weedplanting:server:DestroyWaitForPackage')
                    waitingForPackage = false
                end
            end
        })

    else
        utils.notify(Locales['notify_title_planting'], Locales['canceled'], 'error', 3000)

        FreezeEntityPosition(ped, false)
    end
end)

RegisterNetEvent('weedplanting:client:PackageGoodsReceived', function()
    if waitingForPackage then
        packageZone:remove()
        waitingForPackage = false
    end
end)

RegisterNetEvent('weedplanting:client:ClockIn', function()
    if delivering then return end
    delivering = true

    utils.phoneNotification(Locales['weedrun_delivery_title'], Locales['weedrun_delivery_waitfornew'], 'fas fa-cannabis', '#00FF00', 8000)
    Wait(math.random(Config.DeliveryWaitTime[1], Config.DeliveryWaitTime[2]))

    createNewDropOff()
end)

RegisterNetEvent('weedplanting:client:ClockOut', function()
    if not delivering then return end
    delivering = false
    hasDropOff = false

    RemoveBlip(dropOffBlip)

    if dropOffArea then
        dropOffArea:remove()
        DeletePed(deliveryPed)
	    deliveryPed = nil
    end
    
    utils.notify(Locales['notify_title_run'], Locales['weedrun_clockout'], 'inform', 3000)
end)

RegisterNetEvent('weedplanting:client:DeliverWeed', function()
    if madeDeal then return end

    if not hasPackage then
        return utils.notify(Locales['notify_title_run'], Locales['weedrun_hasnopackage'], 'error', 3000)
    end

	local ped = cache.ped
	if cache.vehicle then return end

	if #(GetEntityCoords(ped) - GetEntityCoords(deliveryPed)) < 5.0 then
		madeDeal = true

        if Config.Target == 'ox_target' then
            exports['ox_target']:removeLocalEntity(deliveryPed, 'weedrun_deliver')
        elseif Config.Target == 'qb-target' then
            exports['qb-target']:RemoveTargetEntity(deliveryPed)
        end

		-- Alert Cops
		if math.random(100) <= Config.CallCopsChance then
            utils.alertPolice()
        end
        
        -- Face each other
        FreezeEntityPosition(ped, true)
		TaskTurnPedToFaceEntity(deliveryPed, ped, 1.0)
		TaskTurnPedToFaceEntity(ped, deliveryPed, 1.0)
        PlayAmbientSpeech1(ped, 'Generic_Hi', 'Speech_Params_Force')
		Wait(1500)
		PlayAmbientSpeech1(deliveryPed, 'Generic_Hi', 'Speech_Params_Force')
		Wait(1000)
		TriggerServerEvent('weedplanting:server:WeedrunDelivery')
		
		-- deliveryPed animation
		PlayAmbientSpeech1(deliveryPed, 'Chat_State', 'Speech_Params_Force')
		Wait(500)

		
        lib.playAnim(deliveryPed, 'mp_safehouselost@', 'package_dropoff', 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
		Wait(3000)

        RemoveAnimDict('mp_safehouselost@')

		-- Finishing up
        FreezeEntityPosition(ped, false)

		RemoveBlip(dropOffBlip)
		dropOffBlip = nil

		dropOffArea:remove()
		Wait(2000)

		utils.phoneNotification(Locales['weedrun_delivery_title'], Locales['weedrun_delivery_success'], 'fas fa-cannabis', '#00FF00', 20000)
        
        ClearPedTasks(ped)
		
        -- Delete Delivery Ped
        deleteDeliveryPed()
		hasDropOff = false
		madeDeal = false

        Wait(math.random(Config.DeliveryWaitTime[1], Config.DeliveryWaitTime[2]))
        createNewDropOff()
	end
end)

--- Points

local onEnterPoint = function(point)
	local pedModel = Config.PedModel
    lib.requestModel(pedModel)
    local ped = CreatePed(0, pedModel, Config.WeedRunStart.x, Config.WeedRunStart.y, Config.WeedRunStart.z - 1.0, Config.WeedRunStart.w, false, false)
    SetModelAsNoLongerNeeded(pedModel)
    
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Target
    if Config.Target == 'ox_target' then
        exports['ox_target']:addLocalEntity(ped, {
            {
                name = 'weedrun_startpackage',
                event = 'weedplanting:client:StartPackage',
                icon = 'fas fa-circle-chevron-right',
                label = Locales['package_goods'],
                canInteract = function()
                    return not waitingForPackage
                end,
                distance = 1.0,
            },
            {
                name = 'weedrun_collectpackage',
                serverEvent = 'weedplanting:server:CollectPackageGoods',
                icon = 'fas fa-circle-chevron-right',
                label = Locales['grab_packaged_goods'],
                canInteract = function()
                    return waitingForPackage
                end
            },
            {
                name = 'weedrun_start_deliver',
                event = 'weedplanting:client:ClockIn',
                icon = 'fas fa-stopwatch',
                label = Locales['start_delivering'],
                canInteract = function()
                    return not delivering
                end
            },
            {
                name = 'weedrun_stop_deliver',
                event = 'weedplanting:client:ClockOut',
                icon = 'fas fa-stopwatch',
                label = Locales['stop_delivering'],
                canInteract = function()
                    return delivering
                end
            }
        })
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                { -- Create Package
                    type = 'client',
                    event = 'weedplanting:client:StartPackage',
                    icon = 'fas fa-circle-chevron-right',
                    label = Locales['package_goods'],
                    canInteract = function()
                        return not waitingForPackage
                    end
                },
                { -- Receive Package
                    type = 'server',
                    event = 'weedplanting:server:CollectPackageGoods',
                    icon = 'fas fa-circle-chevron-right',
                    label = Locales['grab_packaged_goods'],
                    canInteract = function()
                        return waitingForPackage
                    end
                },
                { -- Clock In for deliveries
                    type = 'client',
                    event = 'weedplanting:client:ClockIn',
                    icon = 'fas fa-stopwatch',
                    label = Locales['start_delivering'],
                    canInteract = function()
                        return not delivering
                    end
                },
                { -- Clock out for deliveries
                    type = 'client',
                    event = 'weedplanting:client:ClockOut',
                    icon = 'fas fa-stopwatch',
                    label = Locales['stop_delivering'],
                    canInteract = function()
                        return delivering
                    end
                }
            },
            distance = 1.0
        })
    end

    point.entity = ped
end

local onExitPoint = function(point)
	local entity = point.entity

	if not entity then return end

    if Config.Target == 'ox_target' then
        exports['ox_target']:removeLocalEntity(entity)
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(entity)
    end

    SetEntityAsMissionEntity(entity, false, true)
    DeleteEntity(entity)

	point.entity = nil
end

local point = lib.points.new({
    coords = Config.WeedRunStart.xyz,
    distance = 60,
    onEnter = onEnterPoint,
    onExit = onExitPoint,
    heading = Config.WeedRunStart.w
})
