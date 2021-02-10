ESX.RegisterCommand({'tp', 'setcoords'}, 'admin', function(xPlayer, args, showError)
	xPlayer.setCoords({x = args.x, y = args.y, z = args.z})
end, false, {help = _U('command_setcoords'), validate = true, arguments = {
	{name = 'x', help = _U('command_setcoords_x'), type = 'number'},
	{name = 'y', help = _U('command_setcoords_y'), type = 'number'},
	{name = 'z', help = _U('command_setcoords_z'), type = 'number'}
}})

ESX.RegisterCommand('setjob', 'admin', function(xPlayer, args, showError)
	if ESX.DoesJobExist(args.job, args.grade) then
		args.playerId.setJob(args.job, args.grade)
	else
		showError(_U('command_setjob_invalid'))
	end
end, true, {help = _U('command_setjob'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'job', help = _U('command_setjob_job'), type = 'string'},
	{name = 'grade', help = _U('command_setjob_grade'), type = 'number'}
}})

ESX.RegisterCommand('car', 'superadmin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx:spawnVehicle', args.car)
end, false, {help = _U('command_car'), validate = false, arguments = {
	{name = 'car', help = _U('command_car_car'), type = 'any'}
}})

ESX.RegisterCommand('dv', 'admin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx:deleteVehicle')
end, false, {help = _U('command_cardel'), validate = false, arguments = {
	{name = 'radius', help = _U('command_cardel_radius'), type = 'any'}
}})

ESX.RegisterCommand({'dvr', 'dvradius'}, 'admin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('esx:deleteVehicle', args.radius)
end, false, {help = _U('command_cardel'), validate = false, arguments = {
	{name = 'radius', help = _U('command_cardel_radius'), type = 'any'}
}})

ESX.RegisterCommand('setmoney', 'jefe', function(xPlayer, args, showError)

	if args.account == 'drs' then
		args.account = 'dragon_coins'
	elseif args.account == 'cash' then
		args.account = 'money'
	elseif args.account == 'black' or args.account == 'dark' or args.account == 'dirty' or args.account == 'dirty_money' or args.account == 'dark_money' then
		args.account = 'black_money'
	end
	local oldAcc = args.playerId.getAccount(args.account)
	local oldMoney = oldAcc.money
	local difference = args.amount - oldMoney
	if oldAcc then
		args.playerId.setAccountMoney(args.account, args.amount)
	else
		showError(_U('command_giveaccountmoney_invalid'))
	end
	if difference >= 0 then
		difference = "^2+" .. tostring(difference) .. "$^3"
	else
		difference = "^1" .. tostring(difference) .. "$^3"
	end
	print('es_extended: ' .. xPlayer.name .. ' just set $' .. args.amount .. ' (' .. args.account .. ') to ' .. args.playerId.name .. '. ^3CANTIDAD ANTERIOR: ^2$' .. oldMoney .. '^3 (' .. difference .. ').^0' )
end, true, {help = _U('command_setaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_setaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveaccountmoney', 'coord', function(xPlayer, args, showError)
	if args.account == 'drs' then
		args.account = 'dragon_coins'
	elseif args.account == 'cash' then
		args.account = 'money'
	elseif args.account == 'black' or args.account == 'dark' or args.account == 'dirty' or args.account == 'dirty_money' or args.account == 'dark_money' then
		args.account = 'black_money'
	end
	if args.playerId.getAccount(args.account) then
		args.playerId.addAccountMoney(args.account, args.amount)
		if args.account == 'dragon_coins' then args.account = 'drs' end
		MySQL.Async.execute('INSERT INTO transfer (Sender, Type, Amount, Receiver) VALUES (@Sender, @Type, @Amount, @Receiver) ', {
			['@Sender']   = xPlayer.name,
			['@Type']   = 'giveaccountmoney_'..args.account,
			['@Amount']    = args.amount,
			['@Receiver']    = args.playerId.name
		})
	else
		showError(_U('command_giveaccountmoney_invalid'))
	end
end, true, {help = _U('command_giveaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_giveaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('quitardrs', 'coord', function(xPlayer, args, showError)
	if args.playerId.getAccount("dragon_coins") then
		if args.amount <= args.playerId.getAccount("dragon_coins").money then
			args.playerId.removeAccountMoney("dragon_coins", args.amount)
			loguearMySQL(xPlayer.name, xPlayer.identifier, 'quitar_drs', args.amount, nil, args.playerId.name, args.playerId.identifier)
			showError(" " .. args.amount .. " créditos eliminados al usuario " .. xPlayer.name .. " [ID:" .. xPlayer.playerId .. "]." )
		else
			showError("Créditos insuficientes")
		end
	else
		showError("Créditos insuficientes u otro error")
	end
end, true, {help = "quita cierta cantidad de créditos de importación al usuario", validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'amount', help = _U('command_giveaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveitem', 'superadmin', function(xPlayer, args, showError)
	args.playerId.addInventoryItem(args.item, args.count)
end, true, {help = _U('command_giveitem'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'item', help = _U('command_giveitem_item'), type = 'item'},
	{name = 'count', help = _U('command_giveitem_count'), type = 'number'}
}})

ESX.RegisterCommand('giveweapon', 'superadmin', function(xPlayer, args, showError)
	if args.playerId.hasWeapon(args.weapon) then
		showError(_U('command_giveweapon_hasalready'))
	--else
		--xPlayer.addWeapon(args.weapon, args.ammo)
	end
	args.playerId.addWeapon(args.weapon, args.ammo)
end, true, {help = _U('command_giveweapon'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'weapon', help = _U('command_giveweapon_weapon'), type = 'weapon'},
	{name = 'ammo', help = _U('command_giveweapon_ammo'), type = 'number'}
}})

ESX.RegisterCommand('giveweaponcomponent', 'superadmin', function(xPlayer, args, showError)
	if args.playerId.hasWeapon(args.weaponName) then
		local component = ESX.GetWeaponComponent(args.weaponName, args.componentName)

		if component then
			if args.playerId.hasWeaponComponent(args.weaponName, args.componentName) then
				showError(_U('command_giveweaponcomponent_hasalready'))
			else
				args.playerId.addWeaponComponent(args.weaponName, args.componentName)
			end
		else
			showError(_U('command_giveweaponcomponent_invalid'))
		end
	else
		showError(_U('command_giveweaponcomponent_missingweapon'))
	end
end, true, {help = _U('command_giveweaponcomponent'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'weaponName', help = _U('command_giveweapon_weapon'), type = 'weapon'},
	{name = 'componentName', help = _U('command_giveweaponcomponent_component'), type = 'string'}
}})

ESX.RegisterCommand('setweapontint', 'superadmin', function(xPlayer, args, showError)
	if args.playerId.hasWeapon(args.weaponName) then
		local tints = ESX.GetWeaponTints(args.weaponName)
		if tints[tonumber(args.tintIndex)] then
			args.playerId.setWeaponTint(args.weaponName, tonumber(args.tintIndex))
		else
			showError("Que podamos saber, no existe una variante con ese índice")
		end
	else
		showError(_U('command_giveweaponcomponent_missingweapon'))
	end
end, true, {help = _U('command_giveweaponcomponent'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'weaponName', help = _U('command_giveweapon_weapon'), type = 'weapon'},
	{name = 'tintIndex', help = "Índice de variante", type = 'string'}
}})

ESX.RegisterCommand({'clear', 'cls'}, 'user', function(xPlayer, args, showError)
	xPlayer.triggerEvent('chat:clear')
end, false, {help = _U('command_clear')})

ESX.RegisterCommand({'clearall', 'clsall'}, 'superadmin', function(xPlayer, args, showError)
	TriggerClientEvent('chat:clear', -1)
end, false, {help = _U('command_clearall')})

ESX.RegisterCommand('clearinventory', 'superadmin', function(xPlayer, args, showError)
	if args.playerId then
		for k,v in ipairs(args.playerId.inventory) do
			if v.count > 0 then
				args.playerId.setInventoryItem(v.name, 0)
			end
		end
	else
		for k,v in ipairs(xPlayer.inventory) do
			if v.count > 0 then
				xPlayer.setInventoryItem(v.name, 0)
			end
		end
	end
end, true, {help = _U('command_clearinventory'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('clearloadout', 'superadmin', function(xPlayer, args, showError)
	if args.playerId then
		for k,v in ipairs(args.playerId.loadout) do
			args.playerId.removeWeapon(v.name)
		end
		args.playerId.triggerEvent("RemoveAllPedWeapons")
	else
		for k,v in ipairs(xPlayer.loadout) do
			xPlayer.removeWeapon(v.name)
		end
		xPlayer.triggerEvent("RemoveAllPedWeapons")
	end
end, true, {help = _U('command_clearloadout'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('setgroup', 'jefe', function(xPlayer, args, showError)
	args.playerId.setGroup(args.group)
end, true, {help = _U('command_setgroup'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'group', help = _U('command_setgroup_group'), type = 'string'},
}})

ESX.RegisterCommand('save', 'admin', function(xPlayer, args, showError)
	print(('[ExtendedMode] [^2INFO^7] Manual player data save triggered for "%s"'):format(args.playerId.name))
	ESX.SavePlayer(args.playerId, function(rowsChanged)
		if rowsChanged ~= 0 then
			print(('[ExtendedMode] [^2INFO^7] Saved player data for "%s"'):format(args.playerId.name))
		else
			print(('[ExtendedMode] [^3WARNING^7] Failed to save player data for "%s"! This may be caused by an internal error on the MySQL server.'):format(args.playerId.name))
		end
	end)
end, true, {help = _U('command_save'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('saveall', 'coord', function(xPlayer, args, showError)
	print('[ExtendedMode] [^2INFO^7] Manual player data save triggered')
	ESX.SavePlayers(function(result)
		if result then
			print('[ExtendedMode] [^2INFO^7] Saved all player data')
		else
			print('[ExtendedMode] [^3WARNING^7] Failed to save player data! This may be caused by an internal error on the MySQL server.')
		end
	end)
end, true, {help = _U('command_saveall')})
