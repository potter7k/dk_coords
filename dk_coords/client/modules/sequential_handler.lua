--[[
    SequentialHandler - Manipulador de Sequência
    
    Handler base para coleta sequencial de coordenadas usando checkpoints nativos do GTA.
    Os checkpoints apontam para o próximo ponto da sequência.
    
    Parâmetros (handlerParams):
        - defaultCheckPointModel: number - Modelo do checkpoint padrão (padrão: 3)
        - lastCheckpointModel: number - Modelo do último checkpoint (padrão: 5)
]]

SequentialHandler = {}
SequentialHandler.__index = SequentialHandler
local sequenceConfig = Config.Sequences["sequential"] or {
    defaultCheckPointModel = 3,
    lastCheckpointModel = 5,
}

--- Cria uma nova instância do SequentialHandler
---@param params table Parâmetros de configuração
---@return table obj Instância do SequentialHandler
function SequentialHandler:new(params)
    local obj = setmetatable({}, SequentialHandler)
    obj.blipHandler = BlipHandler:new()
    obj.checkpoints = {}

    obj.defaultCheckPointModel = params.defaultCheckPointModel or sequenceConfig.defaultCheckPointModel
    obj.lastCheckpointModel = params.lastCheckpointModel or sequenceConfig.lastCheckpointModel

    obj.mode = "sequential"
    return obj
end

--- Adiciona um novo marcador/checkpoint na lista
---@param markers table Lista de marcadores coletados
function SequentialHandler:add(markers)
    local maxIndex = #markers
    local currentMarker = markers[maxIndex]
    local previousMarker = markers[maxIndex - 1]

    if previousMarker then
        self:removeCheckpoint(maxIndex - 1)
        self.checkpoints[maxIndex - 1] = self:_createCheckpoint(
            self.defaultCheckPointModel,
            previousMarker.x, previousMarker.y, previousMarker.z - 1,
            currentMarker.x, currentMarker.y, currentMarker.z - 1,
            Config.Visual.colors.primary
        )
    end

    self.checkpoints[maxIndex] = self:_createCheckpoint(
        self.lastCheckpointModel,
        currentMarker.x, currentMarker.y, currentMarker.z - 1,
        nil, nil, nil,
        Config.Visual.colors.secondary
    )

    self.blipHandler:create(maxIndex, vector2(currentMarker.x, currentMarker.y))
end

--- Remove um marcador pelo ID
---@param _ any Não utilizado (compatibilidade)
---@param id number ID do marcador a remover
function SequentialHandler:remove(_, id)
    self:removeCheckpoint(id)
    self.blipHandler:remove(id)
end

--- Substitui o último marcador pela nova posição
---@param markers table Lista de marcadores
function SequentialHandler:replace(markers)
    local index = #markers
    local marker = markers[index]

    self:removeCheckpoint(index)
    self.checkpoints[index] = self:_createCheckpoint(
        3,
        marker.x, marker.y, marker.z - 1,
        nil, nil, nil,
        Config.Visual.colors.secondary
    )

    self.blipHandler:create(index, vector2(marker.x, marker.y))
end

--- Deleta todos os checkpoints e limpa os dados
function SequentialHandler:delete()
    self.blipHandler:clear()
    for id, _ in pairs(self.checkpoints) do
        self:removeCheckpoint(id)
    end
end

--- Cria um checkpoint nativo do GTA
---@param model number Modelo do checkpoint
---@param x number Posição X
---@param y number Posição Y
---@param z number Posição Z
---@param targetX number|nil Posição X do alvo
---@param targetY number|nil Posição Y do alvo
---@param targetZ number|nil Posição Z do alvo
---@param color table Cor RGB do checkpoint
---@return number checkpoint Handle do checkpoint
function SequentialHandler:_createCheckpoint(model, x, y, z, targetX, targetY, targetZ, color)
    return CreateCheckpoint(
        model, x, y, z,
        targetX or 0, targetY or 0, targetZ or 0,
        5.0,
        color[1], color[2], color[3], 200, 1
    )
end

--- Remove um checkpoint específico pelo ID
---@param id number ID do checkpoint a remover
function SequentialHandler:removeCheckpoint(id)
    if self.checkpoints[id] then
        DeleteCheckpoint(self.checkpoints[id])
        self.checkpoints[id] = nil
    end
end