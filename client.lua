ESX = nil
local PlayerData = {}
local invOpen, isDead, isCuffed, currentWeapon = false, false, false, nil
local vehStorage = {}
function setVehicleTable()
	local vehicleTable = {['adder']=1, ['osiris']=0, ['pfister811']=0, ['penetrator']=0, ['autarch']=0, ['bullet']=0, ['cheetah']=0, ['cyclone']=0, ['voltic']=0, ['reaper']=1, ['entityxf']=0, ['t20']=0, ['taipan']=0, ['tempesta']=2, ['tezeract']=0, ['torero']=1, ['turismor']=0, ['fmj']=0, ['gp1']=2, ['infernus ']=0, ['italigtb']=1, ['italigtb2']=1, ['nero']=2, ['nero2']=0, ['vacca']=1, ['vagner']=0, ['visione']=0, ['prototipo']=0, ['xa21']=2, ['zentorno']=0}
	--[[
		0 = vehicle has no storage
		1 = vehicle storage is in bonnet/hood
	]]
	for k, v in pairs(vehicleTable) do
	getHash = GetHashKey(k)
	vehStorage[getHash] = v
	end
end
setVehicleTable()

-- hsn inventory Hasan.#7803
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
    SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

local Drops = {}
local currentDrop = nil
local curweaponSlot = nil
local keys = {
    157, 158, 160, 164, 165
}

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('esx:onPlayerSpawn', function(spawn)
	isDead = false
end)

RegisterNetEvent('esx_policejob:handcuff')
AddEventHandler('esx_policejob:handcuff', function()
	isCuffed = not isCuffed
end)

RegisterNetEvent('esx_policejob:unrestrain')
AddEventHandler('esx_policejob:unrestrain', function()
	isCuffed = false
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3)
        DisableControlAction(0, 37, true)
        DisableControlAction(0, 157, true) -- 1
        DisableControlAction(0, 158, true) -- 2
        DisableControlAction(0, 160, true) -- 3
        DisableControlAction(0, 164, true) -- 4
        DisableControlAction(0, 165, true) -- 5
        DisableControlAction(0, 289, true) -- F2
        for i = 19, 20 do 
            HideHudComponentThisFrame(i) -- remove tab etc.
        end

        if not invOpen then
            for k, v in pairs(keys) do
                if IsDisabledControlJustReleased(0, v) and not dead and not isCuffed then
                    TriggerServerEvent("hsn-inventory:server:useItemfromSlot",k)
                end
            end

            if swappingWeapon then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 257, true)
            elseif currentWeapon then
                if IsPedShooting(PlayerPedId()) then
                    if curweaponSlot ~= nil then
                        TriggerServerEvent("hsn-inventory:server:decreasedurability",curweaponSlot)
                    end
                end
            end
        end
    end
end)

RegisterCommand('vehinv', function()
    if invOpen then return end
    local playerPed = PlayerPedId()
    if not isDead and not isCuffed and not IsPedInAnyVehicle(playerPed, false) then
        local vehicle = ESX.Game.GetClosestVehicle()
        local coords = GetEntityCoords(playerPed)
        if not IsPedInAnyVehicle(PlayerPedId()) then
            if GetVehicleDoorLockStatus(vehicle) ~= 2 then
                local vehHash = GetEntityModel(vehicle)
                local checkVehicle = vehStorage[vehHash]
                if checkVehicle == 1 then open, vehBone = 4, GetEntityBoneIndexByName(vehicle, 'bonnet')
                elseif checkVehicle == nil then open, vehBone = 5, GetEntityBoneIndexByName(vehicle, 'boot') elseif checkVehicle == 2 then open, vehBone = 5, GetEntityBoneIndexByName(vehicle, 'boot') else --[[no vehicle nearby]] return end
                local vehiclePos = GetWorldPositionOfEntityBone(vehicle, vehBone)
                local pedDistance = #(coords - vehiclePos)
				if (open == 5 and checkVehicle == nil) then if pedDistance < 3.0 then CloseToVehicle = true end elseif (open == 5 and checkVehicle == 2) then if pedDistance < 3.0 then CloseToVehicle = true end elseif open == 4 then if pedDistance < 3.0 then CloseToVehicle = true end end	
                if CloseToVehicle then
                    local plate = GetVehicleNumberPlateText(vehicle)
                    SetVehicleDoorOpen(vehicle, open, false, false)
                    OpenTrunk(plate)
                    TaskTurnPedToFaceEntity(PlayerPedId(), vehicle, -1)
                    Citizen.Wait(500)
                    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                    while true do
                        while not invOpen do Citizen.Wait(50) end
                        Citizen.Wait(100)
                        if CloseToVehicle and invOpen and not isCuffed and not isDead then
                            local playerPed = GetPlayerPed(-1)
                            coords = GetEntityCoords(playerPed)
                            if checkVehicle == 1 then open, vehBone = 4, GetEntityBoneIndexByName(vehicle, 'bonnet')
                            elseif checkVehicle == nil then open, vehBone = 5, GetEntityBoneIndexByName(vehicle, 'boot') elseif checkVehicle == 2 then open, vehBone = 5, GetEntityBoneIndexByName(vehicle, 'boot') else return end
                            
                            local vehiclePos = GetWorldPositionOfEntityBone(vehicle, vehBone)
                            local pedDistance = #(coords - vehiclePos)
                    
                            local isClose = false
                            if (open == 5 and checkVehicle == nil) then if pedDistance < 3.0 then isClose = true end elseif (open == 5 and checkVehicle == 2) then if pedDistance < 3.0 then isClose = true end elseif open == 4 then if pedDistance < 3.0 then isClose = true end end
                            if DoesEntityExist(vehicle) and isClose then
                                CloseToVehicle = true
                            else
                                CloseToVehicle = false
                                lastVehicle = nil
                                TriggerEvent("hsn-inventory:client:closeInventory")
                                invOpen = false
                                ClearPedTasks(PlayerPedId())
                                Citizen.Wait(1200)
                                SetVehicleDoorShut(vehicle, open, false)
                                return
                            end
                        elseif not invOpen then
                            CloseToVehicle = false
                            lastVehicle = nil
                            TriggerEvent("hsn-inventory:client:closeInventory")
                            invOpen = false
                            ClearPedTasks(PlayerPedId())
                            Citizen.Wait(1200)
                            SetVehicleDoorShut(vehicle, open, false)
                            return
                        end
                    end
                end
            else
                TriggerEvent('hsn-inventory:notification','Vehicle is locked',2)
            end
        end
    elseif not isDead and not isCuffed and IsPedInAnyVehicle(playerPed, false) then -- [G]lovebox
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local plate = GetVehicleNumberPlateText(vehicle)
        OpenGloveBox(plate)
    end
end,false)
    
RegisterCommand('inventory', function()
    local playerPed = PlayerPedId()
    if not isDead and not isCuffed and not invOpen then
        TriggerEvent("randPickupAnim")
        TriggerServerEvent("hsn-inventory:server:openInventory",{type = 'drop',id = currentDrop})
        TriggerServerEvent('inventory:isShopOpen', false)
    end
end, false)
        
RegisterKeyMapping('inventory', 'Inv: Inventory Open', 'keyboard', 'F2')
RegisterKeyMapping('vehinv', 'Inv: Vehicle Inventory', 'keyboard', 'F3')

OpenGloveBox = function(gloveboxid)
    TriggerServerEvent("hsn-inventory:server:openInventory",{type = 'glovebox',id = 'glovebox-'..gloveboxid})
    TriggerServerEvent('inventory:isShopOpen', false)
end
OpenTrunk = function(trunkid)
    TriggerServerEvent("hsn-inventory:server:openInventory",{type = 'trunk',id = 'trunk-'..trunkid})
    TriggerServerEvent('inventory:isShopOpen', false)
end
RegisterNetEvent("hsn-inventory:client:openInventory")
AddEventHandler("hsn-inventory:client:openInventory",function(inventory,other)
    invOpen = true
    -- some players dupe while taskbar on screen
    -- local check = exports["progressBars"]:onScreen()
    -- if check then
    --     return
    -- end
    local playerID = GetPlayerServerId(PlayerId())
    SendNUIMessage({
        message = 'openinventory',
        inventory = inventory,
        slots = Config.PlayerSlot,
        name = GetPlayerName(PlayerId())..' ['.. playerID ..']',
        maxweight = ESX.GetConfig().MaxWeight,
        rightinventory = other
    })
    TriggerServerEvent("hsn-inventory:setcurrentInventory",other)
    if other == nil then movement = true else movement = false end
    SetNuiFocusAdvanced(true, true, movement)
end)



RegisterNetEvent("hsn-inventory:client:closeInventory")
AddEventHandler("hsn-inventory:client:closeInventory",function(id)
    invOpen = false
    SendNUIMessage({
        message = 'close',
    })
    SetNuiFocusAdvanced(false,false)
    TriggerServerEvent("hsn-inventory:removecurrentInventory",id)
    TriggerServerEvent('inventory:isShopOpen', false)
end)

--[[RegisterCommand("teststash",function()
     TriggerServerEvent("hsn-inventory:server:openStash", {name = 'Hasqaws',slots = 15, type = 'stash'})
end)]]

RegisterNetEvent("hsn-inventory:client:refreshInventory")
AddEventHandler("hsn-inventory:client:refreshInventory",function(inventory)
    local playerID = GetPlayerServerId(PlayerId())
    SendNUIMessage({
        message = 'refresh',
        inventory = inventory,
        slots = Config.PlayerSlot,
        name = GetPlayerName(PlayerId())..' ['.. playerID ..']',
        maxweight = ESX.GetConfig().MaxWeight,
    })
end)


RegisterNUICallback("exit",function(data)
    invOpen = false
    SetNuiFocusAdvanced(false,false)
    TriggerServerEvent('hsn-inventory:server:saveInventory',data)
    TriggerServerEvent("hsn-inventory:removecurrentInventory",data.invid)
end)
--- thread
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        for k,v in pairs(Drops) do
            distance = #(GetEntityCoords(PlayerPedId()) - vector3(v.coords.x,v.coords.y,v.coords.z))
            if distance <= 10.0 then
                wait = 1
                DrawMarker(2, v.coords.x,v.coords.y,v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 150, 30, 30, 222, false, false, false, true, false, false, false)
                if distance <= 1.0 then
                    currentDrop = v.dropid
                else
                    currentDrop = nil
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

RegisterNetEvent("hsn-inventory:client:addItemNotify")
AddEventHandler("hsn-inventory:client:addItemNotify",function(item,text)
    SendNUIMessage({
        message = 'notify',
        item = item,
        text = text
    })
    TriggerServerEvent('hsn-inventory:server:refreshInventory')
end)


function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
	ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do
        while not PlayerData.job do Citizen.Wait(0) end
        local wait = 100
        for i = 1, #Config.Shops do
            distance = #(GetEntityCoords(PlayerPedId()) - Config.Shops[i].coords)
            if distance <= 2.5 and (not Config.Shops[i].job or Config.Shops[i].job == PlayerData.job.name) then
                DrawText3Ds(Config.Shops[i].coords.x,Config.Shops[i].coords.y,Config.Shops[i].coords.z, '[E] Access Shop')
                DrawMarker(2, Config.Shops[i].coords.x,Config.Shops[i].coords.y,Config.Shops[i].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.15, 0.2, 30, 150, 30, 100, false, false, false, true, false, false, false)
                if IsControlJustPressed(1,38) and distance <= 1 and not dead and not isCuffed then
                    OpenShop(Config.Shops[i])
                end
                wait = 2
            end
        end

        for i = 1, #Config.Stashes do
            distance = #(GetEntityCoords(PlayerPedId()) - Config.Stashes[i].coords)
            if distance <= 2.5 and (not Config.Stashes[i].job or Config.Stashes[i].job == PlayerData.job.name) then
                DrawText3Ds(Config.Stashes[i].coords.x, Config.Stashes[i].coords.y, Config.Stashes[i].coords.z, '[E] Access Stash')
                DrawMarker(2, Config.Stashes[i].coords.x,Config.Stashes[i].coords.y,Config.Stashes[i].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.15, 0.2, 30, 30, 150, 100, false, false, false, true, false, false, false)
                if IsControlJustPressed(1,38) and distance <= 1 and not dead and not isCuffed then
                    OpenStash(Config.Stashes[i])
                end
                wait = 2
            end
        end

        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    while not PlayerData.job do Citizen.Wait(0) end
    for k,v in pairs(Config.Shops) do
        if (not Config.Shops[k].job or Config.Shops[k].job == PlayerData.job.name) then
            local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(blip, v.blip.id or 1)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, v.blip.scale or 0.5)
            SetBlipColour(blip, v.blip.color or 1)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blip.name or 'Shop')
            EndTextCommandSetBlipName(blip)
        end
    end
end)




OpenShop = function(id)
    TriggerServerEvent("hsn-inventory:server:openInventory",{type = 'shop',id = id})
    TriggerServerEvent('inventory:isShopOpen', true)
end

OpenStash = function(id)
    TriggerServerEvent("hsn-inventory:server:openStash", {id = id, slots = id.slots, type = 'stash'})
    TriggerServerEvent('inventory:isShopOpen', false)
end

RegisterNetEvent("hsn-inventory:Client:addnewDrop")
AddEventHandler("hsn-inventory:Client:addnewDrop",function(coords,drop)
    Drops[drop] = {
        dropid = drop,
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z - 0.6,
        },
    }
end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

RegisterNetEvent('randPickupAnim')
AddEventHandler('randPickupAnim', function()
    loadAnimDict('pickup_object')
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'putdown_low',5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
end)


RegisterNetEvent("hsn-inventory:client:removeDrop")
AddEventHandler("hsn-inventory:client:removeDrop",function(dropid)
    Drops[dropid] = nil
    currentDrop = nil
end)

RegisterNUICallback("UseItem", function(data, cb)
    if data.inv ~= "Playerinv" then
        return
    end
    TriggerServerEvent("hsn-inventory:server:useItem",data.item)
end)

RegisterNUICallback("saveinventorydata",function(data)
    TriggerServerEvent('hsn-inventory:server:saveInventoryData',data)
end)

RegisterNUICallback("notification", function(data)
    TriggerEvent('hsn-inventory:notification',data.message,data.type)
end)

RegisterNetEvent('hsn-inventory:weapondraw')
AddEventHandler('hsn-inventory:weapondraw', function(item)
    local playerPed = PlayerPedId()
    loadAnimDict('reaction@intimidation@1h')
    TaskPlayAnimAdvanced(playerPed, "reaction@intimidation@1h", "intro", GetEntityCoords(playerPed, true), 0, 0, GetEntityHeading(playerPed), 8.0, 3.0, -1, 50, 0, 0, 0)
    Citizen.Wait(800)
    RemoveWeaponFromPed(PlayerPedId(), GetHashKey(item.name))
    SetCurrentPedWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
    Citizen.Wait(800)
    ClearPedSecondaryTask(PlayerPedId())
end)

RegisterNetEvent('hsn-inventory:weaponaway')
AddEventHandler('hsn-inventory:weaponaway', function()
    local playerPed = PlayerPedId()
    loadAnimDict('reaction@intimidation@1h')
    TaskPlayAnimAdvanced(playerPed, "reaction@intimidation@1h", "outro", GetEntityCoords(playerPed, true), 0, 0, GetEntityHeading(playerPed), 8.0, 3.0, -1, 50, 0, 0, 0)
    Citizen.Wait(1600)
    ClearPedSecondaryTask(PlayerPedId())
    if IsPedUsingActionMode(playerPed) then
        SetPedUsingActionMode(playerPed, -1, -1, 1)
    end
end)

RegisterNetEvent("hsn-inventory:client:weapon")
AddEventHandler("hsn-inventory:client:weapon",function(item)
    if swappingWeapon then return end
    TriggerEvent("hsn-inventory:client:closeInventory")
    local playerPed = PlayerPedId()
    local newWeapon = item.metadata.weaponlicense
    local found, wepHash = GetCurrentPedWeapon(playerPed, true)
    if wepHash == -1569615261 then currentWeapon = nil end
    wepHash = GetHashKey(item.name)
    swappingWeapon = true
    if currentWeapon == newWeapon then
        TriggerEvent("hsn-inventory:weaponaway")
        Citizen.Wait(1600)
        RemoveWeaponFromPed(playerPed, wepHash)
        SetCurrentPedWeapon(playerPed, "WEAPON_UNARMED", true)
        curweaponSlot = nil
        currentWeapon = nil
        TriggerEvent("hsn-inventory:client:addItemNotify",item,'Holstered')
    else
        TriggerEvent("hsn-inventory:weapondraw",item)
        Citizen.Wait(1600)
        curweaponSlot = item.slot
        GiveWeaponToPed(playerPed, wepHash, item.metadata.ammo, false, false)
        SetCurrentPedWeapon(playerPed, wepHash, true)
        if item.metadata.weapontint then SetPedWeaponTintIndex(playerPed, item.name, item.metadata.weapontint) end
        if item.metadata.components then
            for k,v in pairs(item.metadata.components) do
                local componentHash = ESX.GetWeaponComponent(item.name, v).hash
                if componentHash then GiveWeaponComponentToPed(playerPed, wepHash, componentHash) end
            end
        end
        SetPedAmmo(playerPed, wepHash, item.metadata.ammo)
        currentWeapon = item.metadata.weaponlicense
        TriggerEvent("hsn-inventory:client:addItemNotify",item,'Equipped')
    end
    TriggerEvent('hsn-inventory:currentWeapon', item) -- using for another resource
    Citizen.Wait(100)
    swappingWeapon = nil
end)

RegisterNetEvent("hsn-inventory:addAmmo")
AddEventHandler("hsn-inventory:addAmmo",function(item, name)
    local playerPed = PlayerPedId()
    local weapon
    local found, currentWeapon = GetCurrentPedWeapon(playerPed, true) -- thanks https://github.com/DiscworldZA/gta-resources/blob/master/disc-ammo/client/main.lua
    if found then
        for _, v in pairs(item.weapons) do
            if currentWeapon == v then
                weapon = v
                break
            end
        end
        if weapon ~= nil then
            local pedAmmo = GetAmmoInPedWeapon(playerPed, weapon)
            local newAmmo = pedAmmo + item.count
            ClearPedTasks(playerPed)
            local found, maxAmmo = GetMaxAmmo(playerPed, weapon)
            if newAmmo < maxAmmo then
                TriggerServerEvent("hsn-inventory:server:addweaponAmmo",curweaponSlot,item.count)
                TaskReloadWeapon(playerPed)
                SetPedAmmo(playerPed, weapon, newAmmo)
                TriggerEvent("hsn-inventory:notification","Reloaded")
                TriggerServerEvent("hsn-inventory:client:removeItem",name,1)		
            else TriggerEvent("hsn-inventory:notification","Max Ammo")
            end
        end
    end
end)


RegisterNetEvent("hsn-inventory:client:checkweapon")
AddEventHandler("hsn-inventory:client:checkweapon",function(item)
    local curweapon = GetSelectedPedWeapon(PlayerPedId())
    if curweapon ==  GetHashKey(item.name) then
        RemoveWeaponFromPed(PlayerPedId(), GetHashKey(item.name))
        SetCurrentPedWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
        curweaponSlot = nil
    end
end)

RegisterCommand("steal",function()
    local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped, true) and not isDead and not isCuffed then	 
		openTargetInventory()
	end
end)

function openTargetInventory()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 2.0 then
        local searchPlayerPed = GetPlayerPed(closestPlayer)
        if IsEntityPlayingAnim(searchPlayerPed, 'random@mugging3', 'handsup_standing_base', 3) or IsEntityPlayingAnim(searchPlayerPed, 'missminuteman_1ig_2', 'handsup_base', 3) or IsEntityPlayingAnim(searchPlayerPed, 'dead', 'dead_a', 3) or IsEntityPlayingAnim(searchPlayerPed, 'mp_arresting', 'idle') then
            TriggerServerEvent("hsn-inventory:server:openTargetInventory", GetPlayerServerId(closestPlayer))
        end
    else
        TriggerEvent("hsn-inventory:notification",'There is nobody nearby')
    end
end

local nui_focus = {false, false}
function SetNuiFocusAdvanced(hasFocus, hasCursor, allowMovement)
    SetNuiFocus(hasFocus, hasCursor)
    SetNuiFocusKeepInput(hasFocus)
    nui_focus = {hasFocus, hasCursor}
    TriggerEvent("nui:focus", hasFocus, hasCursor)

    if nui_focus[1] then
        if Config.EnableBlur then TriggerScreenblurFadeIn(0) end
        Citizen.CreateThread(function()
            local ticks = 0
            while true do
                Citizen.Wait(0)
                DisableAllControlActions(0)
                if not nui_focus[2] then
                    EnableControlAction(0, 1, true)
                    EnableControlAction(0, 2, true)
                end
                EnableControlAction(0, 249, true) -- N for PTT
                EnableControlAction(0, 20, true) -- Z for proximity
                if allowMovement then
                    EnableControlAction(0, 30, true) -- movement
                    EnableControlAction(0, 31, true) -- movement
                end
                if not nui_focus[1] then
                    ticks = ticks + 1
                    if (IsDisabledControlJustReleased(0, 200, true) or ticks > 20) then
                        invOpen = false
                        if Config.EnableBlur then TriggerScreenblurFadeOut(0) end
                        break
                    end
                end
            end
        end)
    end
end

RegisterNetEvent("hsn-inventory:notification")
AddEventHandler("hsn-inventory:notification",function(message, mtype)
    if mtype == 1 then mtype = { ['background-color'] = 'rgba(55,55,175)', ['color'] = 'white' }
    elseif not mtype or mtype == 2 then mtype = { ['background-color'] = 'rgba(175,55,55)', ['color'] = 'white' }
    end
    TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = message, length = 2500,style = mtype})
end)

RegisterCommand('-nui', function()
        TriggerEvent("hsn-inventory:client:closeInventory")
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        TriggerScreenblurFadeOut(0)
        SetNuiFocusAdvanced(false, false)
    end
end)


RegisterNetEvent("hsn-inventory:useItem")
AddEventHandler("hsn-inventory:useItem",function(item)
    if item.name then item = item.name end
    ESX.TriggerServerCallback("hsn-inventory:getItem",function(xItem)
        local data = Config.ItemList[xItem.name]
        if not data or not next(data) then return end
        if xItem.closeonuse then TriggerEvent("hsn-inventory:client:closeInventory") end
        if xItem.count > 0 then
            if data.consume then TriggerServerEvent('hsn-inventory:client:removeItem', item, data.consume) end
            if not data.animDict then data.animDict = 'pickup_object' end
            if not data.anim then data.anim = 'putdown_low' end
            if not data.flags then data.flags = 48 end

            -- Trigger effects before the progress bar

            if data.item == 'lockpick' then
                TriggerEvent('esx_lockpick:onUse')
            end


            ------------------------------------------------------------------------------------------------
            exports['mythic_progbar']:Progress({
                name = "useitem",
                duration = data.useTime,
                label = "Using "..xItem.name,
                useWhileDead = false,
                canCancel = false,
                controlDisables = { disableMovement = data.disableMove, disableCarMovement = false, disableMouse = false, disableCombat = true },
                animation = { animDict = data.animDict, anim = data.anim, flags = data.flags },
                prop = { model = data.model, coords = data.coords, rotation = data.rotation }
            }, function()
                -- Restore player status
                if data.hunger then
                    if data.hunger > 0 then TriggerEvent('esx_status:add', 'hunger', data.hunger)
                    else TriggerEvent('esx_status:remove', 'hunger', data.hunger) end
                end
                if data.thirst then
                    if data.thirst > 0 then TriggerEvent('esx_status:add', 'thirst', data.thirst)
                    else TriggerEvent('esx_status:remove', 'thirst', data.thirst) end
                end
                ------------------------------------------------------------------------------------------------
                

                if data.item == 'bandage' then
                    local maxHealth = 200
                    local health = GetEntityHealth(PlayerPedId())
                    local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 16))
                    SetEntityHealth(PlayerPedId(), newHealth)
                    TriggerEvent('mythic_hospital:client:FieldTreatBleed')
                    TriggerEvent('mythic_hospital:client:ReduceBleed')
                end


                ------------------------------------------------------------------------------------------------
            end)
        end
    end, item)
end)
