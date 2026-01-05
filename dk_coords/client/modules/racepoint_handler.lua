--[[
    RacepointHandler - Manipulador de Checkpoints de Corrida
    
    Responsável por criar checkpoints de corrida com props (ex: pneus) posicionados
    à esquerda e direita do jogador, formando um "portal" de checkpoint.
    
    Parâmetros (handlerParams):
        - propModel: string - Modelo do prop (padrão: "prop_offroad_tyres02")
        - offset: number - Distância do centro para esquerda/direita (padrão: 3.0)
        - solo: boolean - Se true, spawna apenas o prop esquerdo (padrão: false)
        - blipSprite: number - Sprite do blip no mapa (padrão: 315 - bandeira de corrida)
        - blipColor: number - Cor do blip (padrão: 5 - amarelo)
        - blipScale: number - Escala do blip (padrão: 0.8)
]]

RacepointHandler = setmetatable({}, SequentialHandler)
RacepointHandler.__index = RacepointHandler
local sequenceConfig = Config.Sequences["racepoints"] or {
    defaultPropModel = "prop_offroad_tyres02",
    defaultOffset = 3.0,
    blipSprite = 315,
    blipColor = 5,
    blipScale = 0.8,
}

---@class RacepointProps
---@field left number|nil Handle da entidade do prop esquerdo
---@field right number|nil Handle da entidade do prop direito

---@class RacepointHandlerParams
---@field propModel string|nil Modelo do prop para checkpoints (padrão: "prop_offroad_tyres02")
---@field offset number|nil Distância do centro para esquerda/direita (padrão: 3.0)
---@field solo boolean|nil Se true, spawna apenas o prop esquerdo (padrão: false)
---@field blipSprite number|nil Sprite customizado do blip (padrão: 315 - bandeira de corrida)
---@field blipColor number|nil Cor customizada do blip (padrão: 5 - amarelo)
---@field blipScale number|nil Escala customizada do blip (padrão: 0.8)

--- Cria uma nova instância do RacepointHandler
---@param params RacepointHandlerParams Parâmetros de configuração
---@return table obj Instância do RacepointHandler
function RacepointHandler:new(params)
    local obj = setmetatable({}, RacepointHandler)
    obj.blipHandler = BlipHandler:new()
    obj.checkpoints = {}


    obj.propModel = params.propModel or sequenceConfig.defaultPropModel
    obj.offset = params.offset or sequenceConfig.defaultOffset
    obj.solo = params.solo or false

    obj.blipSprite = params.blipSprite or sequenceConfig.blipSprite
    obj.blipColor = params.blipColor or sequenceConfig.blipColor
    obj.blipScale = params.blipScale or sequenceConfig.blipScale

    obj.mode = "racepoints"
    return obj
end

--- Calcula as posições de offset esquerda e direita baseado na direção do jogador
---@param coords table Coordenadas do centro
---@param heading number Direção do jogador em graus
---@param offsetDistance number Distância do centro
---@return table offsets {left = vector3, right = vector3} Posições calculadas
function RacepointHandler:_calculateOffsets(coords, heading, offsetDistance)
    local rad = math.rad(heading)

    local leftOffset = vector3(
        coords.x + math.cos(rad) * offsetDistance,
        coords.y + math.sin(rad) * offsetDistance,
        coords.z + 0.0
    )

    local rightOffset = vector3(
        coords.x - math.cos(rad) * offsetDistance,
        coords.y - math.sin(rad) * offsetDistance,
        coords.z + 0.0
    )

    return {
        left = leftOffset,
        right = rightOffset
    }
end

--- Spawna um prop na posição especificada
---@param model string Nome do modelo do prop
---@param coords table Coordenadas de spawn
---@param heading number Direção do prop
---@return number entity Handle da entidade
function RacepointHandler:_spawnProp(model, coords, heading)
    local propHash = GetHashKey(model)

    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Wait(1)
    end

    local prop = CreateObject(propHash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(prop, heading)
    PlaceObjectOnGroundProperly(prop)
    SetEntityCollision(prop, false, false)
    SetEntityAlpha(prop, 200, false)
    FreezeEntityPosition(prop, true)
    SetEntityAsMissionEntity(prop, true, true)

    SetModelAsNoLongerNeeded(propHash)

    return prop
end

--- Cria um checkpoint de corrida com prop esquerdo e opcionalmente direito
---@param model string Modelo do prop
---@param centerCoords table Coordenadas do centro
---@param heading number Direção do jogador
---@param offsetDistance number Distância do offset
---@param isSolo boolean Se true, spawna apenas o prop esquerdo
---@return RacepointProps Props criados {left, right}
function RacepointHandler:_createCheckpoint(model, centerCoords, heading, offsetDistance, isSolo)
    local offsets = self:_calculateOffsets(centerCoords, heading, offsetDistance)

    local leftProp = self:_spawnProp(model, offsets.left, heading)
    local rightProp = nil

    if not isSolo then
        rightProp = self:_spawnProp(model, offsets.right, heading)
    end

    return {
        left = leftProp,
        right = rightProp
    }
end

--- Cria um blip customizado para checkpoints de corrida
---@param id number ID do blip
---@param coords table Coordenadas do blip
function RacepointHandler:_createBlip(id, coords)
    self.blipHandler:remove(id)

    local blip = AddBlipForCoord(coords.x, coords.y, 0.0)
    SetBlipSprite(blip, self.blipSprite)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, self.blipColor)
    SetBlipScale(blip, self.blipScale)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("CHECKPOINT DE CORRIDA | #" .. id)
    EndTextCommandSetBlipName(blip)

    self.blipHandler.blips[id] = blip
end

--- Adiciona um novo marcador/checkpoint na lista
---@param markers table Lista de marcadores coletados
---@diagnostic disable-next-line: duplicate-set-field
function RacepointHandler:add(markers)
    local ped = PlayerPedId()
    local maxIndex = #markers
    local currentMarker = markers[maxIndex]
    local heading = GetEntityHeading(ped)

    self.checkpoints[maxIndex] = self:_createCheckpoint(
        self.propModel,
        vector3(currentMarker.x, currentMarker.y, currentMarker.z),
        heading,
        self.offset,
        self.solo
    )

    self:_createBlip(maxIndex, vector2(currentMarker.x, currentMarker.y))
end

--- Remove um marcador pelo ID
---@param _ any Não utilizado (compatibilidade)
---@param id number ID do marcador a remover
---@diagnostic disable-next-line: duplicate-set-field
function RacepointHandler:remove(_, id)
    self:removeCheckpoint(id)
    self.blipHandler:remove(id)
end

--- Substitui o último marcador pela nova posição
---@param markers table Lista de marcadores
---@diagnostic disable-next-line: duplicate-set-field
function RacepointHandler:replace(markers)
    local ped = PlayerPedId()
    local index = #markers
    local marker = markers[index]
    local heading = GetEntityHeading(ped)

    self:removeCheckpoint(index)
    self.checkpoints[index] = self:_createCheckpoint(
        self.propModel,
        vector3(marker.x, marker.y, marker.z),
        heading,
        self.offset,
        self.solo
    )

    self:_createBlip(index, vector2(marker.x, marker.y))
end

--- Remove um checkpoint específico pelo ID
---@param id number ID do checkpoint a remover
---@diagnostic disable-next-line: duplicate-set-field
function RacepointHandler:removeCheckpoint(id)
    if self.checkpoints[id] then
        local checkpoint = self.checkpoints[id]

        if checkpoint.left then
            DeleteEntity(checkpoint.left)
        end

        if checkpoint.right then
            DeleteEntity(checkpoint.right)
        end

        self.checkpoints[id] = nil
    end
end

--- Deleta todos os checkpoints e limpa os dados
---@diagnostic disable-next-line: duplicate-set-field
function RacepointHandler:delete()
    self.blipHandler:clear()
    for id, _ in pairs(self.checkpoints) do
        self:removeCheckpoint(id)
    end
end
