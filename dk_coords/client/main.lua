local collector = CoordinateCollector:new()

RegisterNetEvent("dk_coords/toggleNui")
AddEventHandler("dk_coords/toggleNui", function()
    collector:resetConfigs()
    collector:toggle()
end)

exports("collect", function(collectingMode, collectorConfigs, handlerParams)
    if collector.isCollecting then
        return print("Já está coletando coordenadas.")
    end
    collector:resetConfigs()

    local collectPromise = promise.new()
    collector:startCollecting(collectingMode, collectorConfigs, handlerParams or {}, collectPromise)

    return collectPromise
end)

-- RegisterCommand("collectInit", function() -- Exemplo de uso do export
--     exports.dk_coords:collect("sequential", {minMarkers = 2, maxMarkers = 5}, {}):next(function(coords)
--         print("Coleta finalizada. Coordenadas coletadas:")
--         print(json.encode(coords, {indent = true}))
--     end, function(err)
--         print("Coleta falhou: " .. tostring(err))
--     end, false)
-- end)