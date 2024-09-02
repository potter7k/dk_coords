RegisterCommand("coords",function(source,args,rawCommand)
	if config.usePermissions and not IsPlayerAceAllowed(source, "admin") then
		return
	end

    TriggerClientEvent("dk_coords/toggleNui", source)
end)

print("dk_coords -> Script GRATUITO e OPEN SOURCE desenvolvido por DK Development")