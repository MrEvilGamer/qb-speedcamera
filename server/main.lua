QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-speedcamera:PayBill60Zone', function()
	local Player = QBCore.Functions.GetPlayer(source)
	Player.Functions.RemoveMoney('bank', 100)
	exports['qb-management']:AddMoney("police", 100)
end)

RegisterServerEvent('qb-speedcamera:PayBill80Zone', function()
	local Player = QBCore.Functions.GetPlayer(source)

	Player.Functions.RemoveMoney('bank', 300)
	exports['qb-management']:AddMoney("police", 300)
end)

RegisterServerEvent('qb-speedcamera:PayBill120Zone', function()
	local Player = QBCore.Functions.GetPlayer(source)
		
	Player.Functions.RemoveMoney('bank', 500)
	exports['qb-management']:AddMoney("police", 500)
end)

-- FLASHING EFFECT (START)
RegisterServerEvent('qb-speedcamera:openGUI', function()
	TriggerClientEvent('qb-speedcamera:openGUI', source)
end)

RegisterServerEvent('qb-speedcamera:closeGUI', function()
	TriggerClientEvent('qb-speedcamera:closeGUI', source)
end)
-- FLASHING EFFECT (END)
