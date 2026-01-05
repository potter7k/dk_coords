RegisterCommand("coords", function(source, args, rawCommand)
    if Config.Permissions.usePermissions and not IsPlayerAceAllowed(source, Config.Permissions.adminAce) then
        return
    end

    TriggerClientEvent("dk_coords/toggleNui", source)
end)

print("dk_coords -> Script GRATUITO e OPEN SOURCE desenvolvido por DK Development - v" .. GetResourceMetadata(GetCurrentResourceName(), "version"))