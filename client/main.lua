QBCore = exports['qb-core']:GetCoreObject()


Config = {}

-- BELOVE IS YOUR SETTINGS, CHANGE THEM TO WHATEVER YOU'D LIKE & MORE SETTINGS WILL COME IN THE FUTURE! --
local useBilling = true -- OPTIONS: (true/false)
local useCameraSound = true -- OPTIONS: (true/false)
local useFlashingScreen = true -- OPTIONS: (true/false)
local useBlips = true -- OPTIONS: (true/false)
local alertPolice = true -- OPTIONS: (true/false)
local alertSpeed = 150 -- OPTIONS: (1-5000 KMH)

local defaultPrice60 = 100 -- THIS IS THE DEFAULT PRICE WITHOUT EXTRA COST FOR 60 ZONES
local defaultPrice80 = 300 -- THIS IS THE DEFAULT PRICE WITHOUT EXTRA COST FOR 80 ZONES
local defaultPrice120 = 500 -- THIS IS THE DEFAULT PRICE WITHOUT EXTRA COST FOR 120 ZONES

local extraZonePrice10 = 100 -- THIS IS THE EXTRA COST IF 10 KM/H ABOVE LIMIT (REQUIRES "useBilling" to be set to true)
local extraZonePrice20 = 500 -- THIS IS THE EXTRA COST IF 20 KM/H ABOVE LIMIT (REQUIRES "useBilling" to be set to true)
local extraZonePrice30 = 1000 -- THIS IS THE EXTRA COST IF 30 KM/H ABOVE LIMIT (REQUIRES "useBilling" to be set to true)
-- ABOVE IS YOUR SETTINGS, CHANGE THEM TO WHATEVER YOU'D LIKE & MORE SETTINGS WILL COME IN THE FUTURE!  --

local hasBeenCaught = false
local finalBillingPrice = 0;

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local blips = {
	-- 60KM/H ZONES
	{title="Speedcamera (60KM/H)", colour=1, id=1, x = -524.2645, y = -1776.3569, z = 21.3384}, -- 60KM/H ZONE
	
	-- 80KM/H ZONES
	{title="Speedcamera (80KM/H)", colour=1, id=1, x = 2506.0671, y = 4145.2431, z = 38.1054}, -- 80KM/H ZONE
	{title="Speedcamera (80KM/H)", colour=1, id=1, x = 1258.2006, y = 789.4199, z = 104.2190}, -- 80KM/H ZONE
	{title="Speedcamera (80KM/H)", colour=1, id=1, x = 980.9982, y = 407.4164, z = 92.2374}, -- 80KM/H ZONE
	
	-- 120KM/H ZONES
	{title="Speedcamera (120KM/H)", colour=1, id=1, x = 1584.9281, y = -993.4557, z = 59.3923}, -- 120KM/H ZONE
	{title="Speedcamera (120KM/H)", colour=1, id=1, x = 2442.2006, y = -134.6004, z = 88.7765}, -- 120KM/H ZONE
	{title="Speedcamera (120KM/H)", colour=1, id=1, x = 2871.7951, y = 3540.5795, z = 53.0930} -- 120KM/H ZONE
}

-- AREAS
local Speedcamera60Zone = {
    {x = -524.2645,y = -1776.3569,z = 21.3384}
}

local Speedcamera80Zone = {
    {x = 2506.0671,y = 4145.2431,z = 38.1054},
    {x = 1258.2006,y = 789.4199,z = 103.2190},
    {x = 980.9982,y = 407.4164,z = 92.2374}
}

local Speedcamera120Zone = {
    {x = 1584.9281,y = -993.4557,z = 59.3923},
    {x = 2442.2006,y = -134.6004,z = 88.7765},
    {x = 2871.7951,y = 3540.5795,z = 53.0930}
}

CreateThread(function()
	for _, info in pairs(blips) do
		if useBlips == true then
			info.blip = AddBlipForCoord(info.x, info.y, info.z)
			SetBlipSprite(info.blip, info.id)
			SetBlipDisplay(info.blip, 4)
			SetBlipScale(info.blip, 0.5)
			SetBlipColour(info.blip, info.colour)
			SetBlipAsShortRange(info.blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(info.title)
			EndTextCommandSetBlipName(info.blip)
		end
	end
end)

-- ZONES
CreateThread(function()
    while true do
        Wait(10)

		-- 60 zone
        for k in pairs(Speedcamera60Zone) do
            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Speedcamera60Zone[k].x, Speedcamera60Zone[k].y, Speedcamera60Zone[k].z)

            if dist <= 20.0 then
				local playerPed = PlayerPedId()
				local playerCar = GetVehiclePedIsIn(playerPed, false)
				local veh = GetVehiclePedIsIn(playerPed)
				local SpeedKM = GetEntitySpeed(playerPed)*3.6
				local maxSpeed = 60.0 -- THIS IS THE MAX SPEED IN KM/H
				
				if SpeedKM > maxSpeed then
					if IsPedInAnyVehicle(playerPed, false) then
						if (GetPedInVehicleSeat(playerCar, -1) == playerPed) then
							if hasBeenCaught == false then
								if GetDisplayNameFromVehicleModel(GetEntityModel(veh)) == Config.PoliceVehicle then -- BLACKLISTED VEHICLE
								-- VEHICLES ABOVE ARE BLACKLISTED
								else
									-- ALERT POLICE (START)
									if alertPolice == true then
										if SpeedKM > alertSpeed then
											local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), false))
											TriggerServerEvent('qb-phone:server:sendNewMail', {
												sender = "911/Police",
												subject = "Over Speeding",
												message = 'Someone passed the speed camera, above ' .. alertSpeed.. ' KMH',
											})
										end
									end
									-- ALERT POLICE (END)								
								
									-- FLASHING EFFECT (START)
									if useFlashingScreen == true then
										TriggerServerEvent('qb-speedcamera:openGUI')
									end
									
									if useCameraSound == true then
										TriggerServerEvent("InteractSound_SV:PlayOnSource", "speedcamera", 0.5)
									end
									
									if useFlashingScreen == true then
										Wait(600)
										TriggerServerEvent('qb-speedcamera:closeGUI')
									end
									-- FLASHING EFFECT (END)								
									QBCore.Functions.Notify("You've been fined by the speedcamera in a 60 zone! Your speed: " .. math.floor(SpeedKM) .. " KM/H", 'primary', 7500)
									
									if useBilling == true then
										if SpeedKM >= maxSpeed + 30 then
											finalBillingPrice = defaultPrice60 + extraZonePrice30
										elseif SpeedKM >= maxSpeed + 20 then
											finalBillingPrice = defaultPrice60 + extraZonePrice20
										elseif SpeedKM >= maxSpeed + 10 then
											finalBillingPrice = defaultPrice60 + extraZonePrice10
										else
											finalBillingPrice = defaultPrice60
										end
										
										TriggerServerEvent('qb-speedcamera:PayBill60Zone')
									else
										TriggerServerEvent('qb-speedcamera:PayBill60Zone')
									end
										
									hasBeenCaught = true
									Wait(5000) -- This is here to make sure the player won't get fined over and over again by the same camera!
								end
							end
						end
					end
					
					hasBeenCaught = false
				end
            end
        end
		
		-- 80 zone
		for k in pairs(Speedcamera80Zone) do
            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Speedcamera80Zone[k].x, Speedcamera80Zone[k].y, Speedcamera80Zone[k].z)

            if dist <= 20.0 then
				local playerPed = PlayerPedId()
				local playerCar = GetVehiclePedIsIn(playerPed, false)
				local veh = GetVehiclePedIsIn(playerPed)
				local SpeedKM = GetEntitySpeed(playerPed)*3.6
				local maxSpeed = 80.0 -- THIS IS THE MAX SPEED IN KM/H
				
				if SpeedKM > maxSpeed then
					if IsPedInAnyVehicle(playerPed, false) then
						if (GetPedInVehicleSeat(playerCar, -1) == playerPed) then					
							if hasBeenCaught == false then
								if GetDisplayNameFromVehicleModel(GetEntityModel(veh)) == Config.PoliceVehicle then -- BLACKLISTED VEHICLE
								else
									-- ALERT POLICE (START)
									if alertPolice == true then
										if SpeedKM > alertSpeed then
											local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), false))
											TriggerServerEvent('qb-phone:server:sendNewMail', {
												sender = "911/Police",
												subject = "Over Speeding",
												message = 'Someone passed the speed camera, above ' .. alertSpeed.. ' KMH',
											})
										end
									end
									-- ALERT POLICE (END)								
								
									-- FLASHING EFFECT (START)
									if useFlashingScreen == true then
										TriggerServerEvent('qb-speedcamera:openGUI')
									end
									
									if useCameraSound == true then
										TriggerServerEvent("InteractSound_SV:PlayOnSource", "speedcamera", 0.5)
									end
									
									if useFlashingScreen == true then
										Wait(600)
										TriggerServerEvent('qb-speedcamera:closeGUI')
									end
									-- FLASHING EFFECT (END)								
									QBCore.Functions.Notify("You've been fined by the speedcamera in a 80 zone! Your speed: " .. math.floor(SpeedKM) .. " KM/H", 'error', 7500)
									
									if useBilling == true then
										if SpeedKM >= maxSpeed + 30 then
											finalBillingPrice = defaultPrice80 + extraZonePrice30
										elseif SpeedKM >= maxSpeed + 20 then
											finalBillingPrice = defaultPrice80 + extraZonePrice20
										elseif SpeedKM >= maxSpeed + 10 then
											finalBillingPrice = defaultPrice80 + extraZonePrice10
										else
											finalBillingPrice = defaultPrice80
										end
									
										TriggerServerEvent('qb-speedcamera:PayBill80Zone')
									else
										TriggerServerEvent('qb-speedcamera:PayBill80Zone')
									end
										
									hasBeenCaught = true
									Wait(5000) -- This is here to make sure the player won't get fined over and over again by the same camera!
								end
							end
						end
					end
					
					hasBeenCaught = false
				end
            end
        end
		
		-- 120 zone
		for k in pairs(Speedcamera120Zone) do
            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Speedcamera120Zone[k].x, Speedcamera120Zone[k].y, Speedcamera120Zone[k].z)

            if dist <= 20.0 then
				local playerPed = PlayerPedId()
				local playerCar = GetVehiclePedIsIn(playerPed, false)
				local veh = GetVehiclePedIsIn(playerPed)
				local SpeedKM = GetEntitySpeed(playerPed)*3.6
				local maxSpeed = 120.0 -- THIS IS THE MAX SPEED IN KM/H
				
				if SpeedKM > maxSpeed then
					if IsPedInAnyVehicle(playerPed, false) then
						if (GetPedInVehicleSeat(playerCar, -1) == playerPed) then 
							if hasBeenCaught == false then
								if GetDisplayNameFromVehicleModel(GetEntityModel(veh)) == Config.PoliceVehicle then -- BLACKLISTED VEHICLE
								else
									-- ALERT POLICE (START)
									if alertPolice == true then
										if SpeedKM > alertSpeed then
											local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), false))
											TriggerServerEvent('qb-phone:server:sendNewMail', {
												sender = "911/Police",
												subject = "Over Speeding",
												message = 'Someone passed the speed camera, above ' .. alertSpeed.. ' KMH',
											})
										end
									end
									-- ALERT POLICE (END)
								
									-- FLASHING EFFECT (START)
									if useFlashingScreen == true then
										TriggerServerEvent('qb-speedcamera:openGUI')
									end
									
									if useCameraSound == true then
										TriggerServerEvent("InteractSound_SV:PlayOnSource", "speedcamera", 0.5)
									end
									
									if useFlashingScreen == true then
										Wait(600)
										TriggerServerEvent('qb-speedcamera:closeGUI')
									end
									-- FLASHING EFFECT (END)
									QBCore.Functions.Notify("You've been fined by the speedcamera in a 120 zone! Your speed: " .. math.floor(SpeedKM) .. " KM/H", 'error', 7500)
									
									
									if useBilling == true then
										if SpeedKM >= maxSpeed + 30 then
											finalBillingPrice = defaultPrice120 + extraZonePrice30
										elseif SpeedKM >= maxSpeed + 20 then
											finalBillingPrice = defaultPrice120 + extraZonePrice20
										elseif SpeedKM >= maxSpeed + 10 then
											finalBillingPrice = defaultPrice120 + extraZonePrice10
										else
											finalBillingPrice = defaultPrice120
										end
									
										TriggerServerEvent('qb-speedcamera:PayBill120Zone')
									else
										TriggerServerEvent('qb-speedcamera:PayBill120Zone')
									end
										
									hasBeenCaught = true
									Wait(5000) -- This is here to make sure the player won't get fined over and over again by the same camera!
								end
							end
						end
					end
					
					hasBeenCaught = false
				end
            end
        end
    end
end)

RegisterNetEvent('qb-speedcamera:openGUI', function()
    SetNuiFocus(false,false)
    SendNUIMessage({type = 'openSpeedcamera'})
end)   

RegisterNetEvent('qb-speedcamera:closeGUI', function()
    SendNUIMessage({type = 'closeSpeedcamera'})
end)
