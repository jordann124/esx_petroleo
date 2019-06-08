ESX 						   = nil
local CopsConnected       	   = 0
local PlayersHarvestingKoda    = {}
local PlayersTransformingKoda  = {}
local PlayersSellingKoda       = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()
	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1500, CountCops)
end

CountCops()

--kodeina
local function HarvestKoda(source)

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local koda = xPlayer.getInventoryItem('petroleo')

			if koda.limit ~= -1 and koda.count >= koda.limit then
				TriggerClientEvent('esx:showNotification', source, _U('mochila_full'))
			else
				xPlayer.addInventoryItem('petroleo', 1)
				HarvestKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_petroleo:startHarvestKoda')
AddEventHandler('esx_petroleo:startHarvestKoda', function()
	local _source = source

	if not PlayersHarvestingKoda[_source] then
		PlayersHarvestingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('pegar_petroleobruto'))
		HarvestKoda(_source)
	else
		print(('esx_petroleo: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_petroleo:stopHarvestKoda')
AddEventHandler('esx_petroleo:stopHarvestKoda', function()
	local _source = source

	PlayersHarvestingKoda[_source] = false
end)

local function TransformKoda(source)

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local kodaQuantity = xPlayer.getInventoryItem('petroleo').count
			local pooch = xPlayer.getInventoryItem('petroleobruto')

			if pooch.limit ~= -1 and pooch.count >= pooch.limit then
				TriggerClientEvent('esx:showNotification', source, _U('nao_tens_petroleo_suficientes'))
			elseif kodaQuantity < 5 then
				TriggerClientEvent('esx:showNotification', source, _U('nao_tens_mais_petroleo'))
			else
				xPlayer.removeInventoryItem('petroleo', 2)
				xPlayer.addInventoryItem('petroleobruto', 1)

				TransformKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_petroleo:startTransformKoda')
AddEventHandler('esx_petroleo:startTransformKoda', function()
	local _source = source

	if not PlayersTransformingKoda[_source] then
		PlayersTransformingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('producao_de_petroleobruto'))
		TransformKoda(_source)
	else
		print(('esx_petroleo: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_petroleo:stopTransformKoda')
AddEventHandler('esx_petroleo:stopTransformKoda', function()
	local _source = source

	PlayersTransformingKoda[_source] = false
end)

local function SellKoda(source)

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingKoda[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local poochQuantity = xPlayer.getInventoryItem('petroleobruto').count

			if poochQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('nao_tens_petroleobruto'))
			else
				xPlayer.removeInventoryItem('petroleobruto', 1)
				if CopsConnected == 0 then
					xPlayer.addAccountMoney('bank', 15)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_petroleo'))
				elseif CopsConnected == 1 then
					xPlayer.addAccountMoney('bank', 15)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_petroleo'))
				elseif CopsConnected == 2 then
					xPlayer.addAccountMoney('bank', 15)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_petroleo'))
				elseif CopsConnected == 3 then
					xPlayer.addAccountMoney('bank', 15)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_petroleo'))
				elseif CopsConnected == 4 then
					xPlayer.addAccountMoney('bank', 15)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_petroleo'))
				elseif CopsConnected >= 5 then
					xPlayer.addAccountMoney('bank', 15)
					TriggerClientEvent('esx:showNotification', source, _U('vendeste_petroleo'))
				end

				SellKoda(source)
			end
		end
	end)
end

RegisterServerEvent('esx_petroleo:startSellKoda')
AddEventHandler('esx_petroleo:startSellKoda', function()
	local _source = source

	if not PlayersSellingKoda[_source] then
		PlayersSellingKoda[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('venda_do_petroleo'))
		SellKoda(_source)
	else
		print(('esx_petroleo: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
	end
end)

RegisterServerEvent('esx_petroleo:stopSellKoda')
AddEventHandler('esx_petroleo:stopSellKoda', function()
	local _source = source

	PlayersSellingKoda[_source] = false
end)

RegisterServerEvent('esx_petroleo:GetUserInventory')
AddEventHandler('esx_petroleo:GetUserInventory', function(currentZone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('esx_petroleo:ReturnInventory',
		_source,
		xPlayer.getInventoryItem('petroleo').count,
		xPlayer.getInventoryItem('petroleobruto').count,
		xPlayer.job.name,
		currentZone
	)
end)

ESX.RegisterUsableItem('petroleo', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('petroleo', 1)

	TriggerClientEvent('esx_petroleo:onPot', _source)
	TriggerClientEvent('esx:showNotification', _source, _U('used_one_koda'))
end)
