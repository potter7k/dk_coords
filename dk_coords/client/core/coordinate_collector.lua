CoordinateCollector = {}
CoordinateCollector.__index = CoordinateCollector

function CoordinateCollector:new()
    local obj = setmetatable({}, CoordinateCollector)

    obj.ui = UIManager:new()
    obj.controlManager = ControlManager:new(obj)
    obj.markerPreview = MarkerPreview:new()

    obj.markers = {}

    obj.sequenceHandler = nil
    obj.finishPromise = nil
    obj.isCollecting = false

    obj:resetConfigs()
    obj:setupCallbacks()

    obj.controlManager:register()

    return obj
end

function CoordinateCollector:resetConfigs()
    self.configs = {
        minMarkers = 1,
        maxMarkers = nil
    }
end

function CoordinateCollector:markersLimit(min, max)
    self.configs.minMarkers = min or 1
    self.configs.maxMarkers = max
end

function CoordinateCollector:setupCallbacks()
    RegisterNUICallback("close", function(data, cb)
        self:closeAll()
    end)

    RegisterNUICallback("collectCoords", function(data, callback)
        callback(self.markers)
    end)

    RegisterNUICallback("selectOption", function(data, cb)
        if not data or not data.option then return end
        if GetResourceState('PolyZone') == 'missing' then
            return print("Erro, script PolyZone desativado.")
        end

        self:startCollecting(data.option, {
            minMarkers = 1,
            maxMarkers = nil
        }, {})
    end)
end

function CoordinateCollector:toggle()
    if not self.ui.isOpen then
        self:open()
    else
        self:closeAll()
    end
end

function CoordinateCollector:open()
    self.ui:updateDescription(
        "Tipo de blip",
        "Escolha o <strong>tipo de blip</strong> que você quer começar a <strong>coletar</strong>."
    )
    self.ui:toggle(true)
end

function CoordinateCollector:closeAll()
    self.ui:toggle(false)
    self.isCollecting = false
    self.markers = {}
    self.finishPromise = nil
    self.markerPreview:stop()
    self.markerPreview:clearLastMarkerData()
    self.sequenceHandler:delete()
end

function CoordinateCollector:collectingMode(mode, handlerParams)
    if mode == "sequential" then
        self.sequenceHandler = SequentialHandler:new(handlerParams)
    elseif mode == "polyzone" then
        self.sequenceHandler = PolyzoneHandler:new(handlerParams)
    elseif mode == "vehicles" then
        self.sequenceHandler = VehiclesHandler:new(handlerParams)
    elseif mode == "racepoints" then
        self.sequenceHandler = RacepointHandler:new(handlerParams)
    else
        print("Modo de sequência inválido: " .. tostring(mode))
        return
    end
end

function CoordinateCollector:startCollecting(mode, collectorConfigs, handlerParams, finishPromise)
    self:markersLimit(collectorConfigs.minMarkers, collectorConfigs.maxMarkers)
    self:collectingMode(mode, handlerParams)
    self.markers = {}
    self.isCollecting = true

    self.finishPromise = finishPromise
    self.ui.isOpen = true

    self.ui:setupControls(Config.Controls)
    self:updateMarkersDisplay()
    self.ui:showControls()
end

function CoordinateCollector:updateMarkersDisplay()
    if not self.isCollecting then return end

    local count = #self.markers
    local addKey = Config.Controls.add.title
    local finishKey = Config.Controls.finish.title
    local cancelKey = Config.Controls.cancel.title
    local configs = self.configs
    local maxMarkersText = configs.maxMarkers and "/" .. configs.maxMarkers or ""
    if count == 0 then
        self.ui:updateDescription(
            "Coleta de Blips",
            string.format(
                "Você começou a <strong>coletar blips</strong> no modo <strong>%s</strong>. " ..
                "Primeiro, escolha o local do seu <strong>primeiro blip</strong>. " ..
                "Vá até o local desejado e pressione a tecla <strong>%s</strong>.",
                self.sequenceHandler.mode, addKey
            )
        )
    elseif count == 1 then
        self.ui:updateDescription(
            "Coleta de Blips (" .. count .. ""..maxMarkersText.. ")",
            string.format(
                "Você coletou o <strong>primeiro blip</strong>. " ..
                "Vá ao local desejado e pressione a tecla <strong>%s</strong> para prosseguir coletando novos blips.",
                addKey
            )
        )
    else
        self.ui:updateDescription(
            "Coleta de Blips (" .. count .. ""..maxMarkersText.. ")",
            string.format(
                "Continue <strong>coletando blips</strong> (min.: %s) e aperte a tecla <strong>%s</strong> para finalizar " ..
                "ou <strong>%s</strong> para cancelar.",
                configs.minMarkers, finishKey, cancelKey
            )
        )
    end
end

function CoordinateCollector:onControlPressed(action)
    if not self.isCollecting then return end

    if action == "cancel" then
        self:closeAll()
    elseif action == "add" then
        local configs = self.configs
        if configs.maxMarkers and #self.markers >= configs.maxMarkers then
            print("Número máximo de blips atingido ("..configs.maxMarkers..").")
            return
        end
        self.markerPreview:startAddPreview()
    elseif action == "back" then
        self:removeLastMarker()
    elseif action == "up" or action == "down" then
        self:startMovePreview(action)
    elseif action == "finish" then
        self:finishCollecting()
    end
end

function CoordinateCollector:onControlReleased(action)
    if action == "add" then
        self:addMarker()
    elseif action == "up" or action == "down" then
        self:finalizeMovePreview()
    end
end

function CoordinateCollector:addMarker()
    if not self.markerPreview.isActive then return end

    self.markerPreview:stop()

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local marker = {
        x = RoundNumber(coords.x),
        y = RoundNumber(coords.y),
        z = RoundNumber(coords.z),
        h = RoundNumber(heading)
    }

    table.insert(self.markers, marker)

    self.sequenceHandler:add(self.markers)

    self:updateMarkersDisplay()
end

function CoordinateCollector:removeLastMarker()
    if #self.markers < 1 then return end

    local id = #self.markers
    table.remove(self.markers, id)

    self.sequenceHandler:remove(self.markers, id)

    self:updateMarkersDisplay()
end

function CoordinateCollector:startMovePreview(action)
    if #self.markers < 1 or self.sequenceHandler.mode == "polyzone" then return end

    local lastMarker = self.markers[#self.markers]
    self.markerPreview:startMovePreview(action, lastMarker)
end

function CoordinateCollector:finalizeMovePreview()
    if not self.markerPreview.isActive then return end

    self.markerPreview:stop()

    local newData = self.markerPreview:getLastMarkerData()
    if newData.x then
        self.markers[#self.markers] = newData
        self.markerPreview:clearLastMarkerData()

        self.sequenceHandler:replace(self.markers)

        self:updateMarkersDisplay()
    end
end

function CoordinateCollector:finishCollecting()
    local configs = self.configs
    if #self.markers < configs.minMarkers then
        print("Número mínimo de blips não atendido ("..configs.minMarkers..").")
        return
    end
    if configs.maxMarkers and #self.markers > configs.maxMarkers then
        print("Número máximo de blips excedido ("..configs.maxMarkers..").")
        return
    end

    if self.finishPromise then
        self.finishPromise:resolve(self.markers)
        self:closeAll()
        return
    end

    self.ui:updateDescription("Selecionar preset", "Selecione o preset desejado de coordenadas.")
    self.ui:showPresetSelection()
end
