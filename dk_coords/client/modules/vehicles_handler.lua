--[[
    VehiclesHandler - Manipulador de Veículos
    
    Responsável por criar veículos de preview durante a coleta de coordenadas.
    Ideal para posicionar veículos em linhas de largada de corridas.
    
    Parâmetros (handlerParams):
        - defaultCheckPointModel: string - Modelo do veículo (padrão: "sultan")
        - defaultCheckpointColor: table - Cor do veículo {r, g} (padrão: Config.Visual.colors.secondary)
        - debug: boolean - Ativa linhas de alinhamento (padrão: false)
        - debugLineLength: number - Comprimento das linhas de debug (padrão: 10.0)
        - debugLineColor: table - Cor RGBA das linhas {r, g, b, a} (padrão: {255, 0, 0, 255})
]]

VehiclesHandler = setmetatable({}, SequentialHandler)
VehiclesHandler.__index = VehiclesHandler
local sequenceConfig = Config.Sequences["vehicles"] or {
    defaultCheckPointModel = "sultan",
    defaultCheckpointColor = Config.Visual.colors.secondary,
}

--- Cria uma nova instância do VehiclesHandler
---@param params table Parâmetros de configuração do handler
---@return table obj Instância do VehiclesHandler
---@diagnostic disable-next-line: duplicate-set-field
function VehiclesHandler:new(params)
    local obj = setmetatable({}, VehiclesHandler)
    obj.blipHandler = BlipHandler:new()
    obj.checkpoints = {}
    obj.debugLines = {}

    obj.defaultCheckPointModel = params.defaultCheckPointModel or sequenceConfig.defaultCheckPointModel
    obj.defaultCheckpointColor = params.defaultCheckpointColor or sequenceConfig.defaultCheckpointColor

    obj.debug = params.debug or false
    obj.debugLineLength = params.debugLineLength or 10.0
    obj.debugLineColor = params.debugLineColor or {255, 0, 0, 255}
    obj.debugLineActive = false

    obj.mode = "vehicles"
    return obj
end

--- Calcula os pontos das linhas frontal e lateral baseado na posição e direção do veículo
---@param x number Posição X do veículo
---@param y number Posição Y do veículo
---@param z number Posição Z do veículo
---@param heading number Direção do veículo em graus
---@param lineLength number Comprimento da linha
---@return table lineData {front = {left, right}, side = {front, back}} Dados das linhas
function VehiclesHandler:_calculateDebugLine(x, y, z, heading, lineLength)
    local perpRad = math.rad(heading + 90)
    local frontRad = math.rad(heading)

    local halfLength = lineLength / 2
    local frontOffset = 2.5
    local sideOffset = 2.0

    local frontX = x + math.cos(frontRad) * frontOffset
    local frontY = y + math.sin(frontRad) * frontOffset

    local frontLeft = vector3(
        frontX + math.cos(perpRad) * halfLength,
        frontY + math.sin(perpRad) * halfLength,
        z + 0.1
    )
    local frontRight = vector3(
        frontX - math.cos(perpRad) * halfLength,
        frontY - math.sin(perpRad) * halfLength,
        z + 0.1
    )

    local sideX = x + math.cos(perpRad) * sideOffset
    local sideY = y + math.sin(perpRad) * sideOffset
    local sideFront = vector3(
        sideX + math.cos(frontRad) * halfLength,
        sideY + math.sin(frontRad) * halfLength,
        z + 0.1
    )
    local sideBack = vector3(
        sideX - math.cos(frontRad) * halfLength,
        sideY - math.sin(frontRad) * halfLength,
        z + 0.1
    )

    return {
        front = { left = frontLeft, right = frontRight },
        side = { front = sideFront, back = sideBack }
    }
end

--- Inicia a thread de renderização das linhas de debug
--- Desenha linhas frontal (perpendicular) e lateral (paralela) para alinhamento
function VehiclesHandler:_startDebugThread()
    if self.debugLineActive then return end
    self.debugLineActive = true

    CreateThread(function()
        while self.debugLineActive do
            for id, lineData in pairs(self.debugLines) do
                if lineData then
                    DrawLine(
                        lineData.front.left.x, lineData.front.left.y, lineData.front.left.z,
                        lineData.front.right.x, lineData.front.right.y, lineData.front.right.z,
                        self.debugLineColor[1], self.debugLineColor[2],
                        self.debugLineColor[3], self.debugLineColor[4]
                    )
                    DrawLine(
                        lineData.side.front.x, lineData.side.front.y, lineData.side.front.z,
                        lineData.side.back.x, lineData.side.back.y, lineData.side.back.z,
                        self.debugLineColor[1], self.debugLineColor[2],
                        self.debugLineColor[3], self.debugLineColor[4]
                    )
                end
            end
            Wait(0)
        end
    end)
end

--- Para a thread de renderização das linhas de debug
function VehiclesHandler:_stopDebugThread()
    self.debugLineActive = false
    self.debugLines = {}
end

--- Cria um veículo de checkpoint na posição especificada
---@param model string Modelo do veículo
---@param x number Posição X
---@param y number Posição Y
---@param z number Posição Z
---@param heading number Direção do veículo
---@param color table Cores do veículo {primária, secundária}
---@return number vehicle Handle da entidade do veículo
---@diagnostic disable-next-line: duplicate-set-field
function VehiclesHandler:_createCheckpoint(model, x, y, z, heading, color)
    local vehHash = GetHashKey(model)

    RequestModel(vehHash)
    while not HasModelLoaded(vehHash) do
        Wait(1)
    end

    local vehicle = CreateVehicle(vehHash, x, y, z + 1, heading, false, false)
    SetEntityCollision(vehicle, false, false)
    SetEntityAlpha(vehicle, 150, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleDoorsLocked(vehicle, 2)
    SetVehicleColours(vehicle, color[1], color[2])
    SetVehicleExtraColours(vehicle, 0, 0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleNumberPlateText(vehicle, "DKCOORDS")
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityInvincible(vehicle, true)
    FreezeEntityPosition(vehicle, true)
    SetVehicleTyresCanBurst(vehicle, false)
    return vehicle
end

--- Adiciona um novo marcador/veículo na lista
---@param markers table Lista de marcadores coletados
---@diagnostic disable-next-line: duplicate-set-field
function VehiclesHandler:add(markers)
    local ped = PlayerPedId()
    local maxIndex = #markers
    local currentMarker = markers[maxIndex]
    local heading = GetEntityHeading(ped)

    self.checkpoints[maxIndex] = self:_createCheckpoint(
        self.defaultCheckPointModel,
        currentMarker.x, currentMarker.y, currentMarker.z - 1,
        heading,
        self.defaultCheckpointColor
    )

    if self.debug then
        self.debugLines[maxIndex] = self:_calculateDebugLine(
            currentMarker.x, currentMarker.y, currentMarker.z,
            heading,
            self.debugLineLength
        )
        self:_startDebugThread()
    end

    self.blipHandler:create(maxIndex, vector2(currentMarker.x, currentMarker.y))
end

--- Remove um checkpoint específico pelo ID
---@param id number ID do checkpoint a remover
---@diagnostic disable-next-line: duplicate-set-field
function VehiclesHandler:removeCheckpoint(id)
    if self.checkpoints[id] then
        DeleteEntity(self.checkpoints[id])
        self.checkpoints[id] = nil
    end
    if self.debugLines[id] then
        self.debugLines[id] = nil
    end
end

--- Deleta todos os checkpoints e limpa os dados
---@diagnostic disable-next-line: duplicate-set-field
function VehiclesHandler:delete()
    self:_stopDebugThread()
    self.blipHandler:clear()
    for id, _ in pairs(self.checkpoints) do
        self:removeCheckpoint(id)
    end
end