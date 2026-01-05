--[[
    BlipHandler - Manipulador de Blips
    
    Responsável por criar, remover e gerenciar blips no mapa.
    Utilizado por todos os handlers para exibir os pontos coletados.
]]

BlipHandler = {}
BlipHandler.__index = BlipHandler

--- Cria uma nova instância do BlipHandler
---@return table obj Instância do BlipHandler
function BlipHandler:new()
    local obj = setmetatable({}, BlipHandler)
    obj.blips = {}
    return obj
end

--- Cria um blip no mapa
---@param id number ID do blip
---@param coords table Coordenadas do blip
function BlipHandler:create(id, coords)
    self:remove(id)

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z or 0.0)
    SetBlipSprite(blip, 270)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, Config.Visual.colors.blip)
    SetBlipScale(blip, 0.5)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("SEQUÊNCIA DE BLIPS | BLIP " .. id)
    EndTextCommandSetBlipName(blip)

    self.blips[id] = blip
    Wait(10)
end

--- Remove um blip pelo ID
---@param id number ID do blip a remover
function BlipHandler:remove(id)
    if self.blips[id] then
        RemoveBlip(self.blips[id])
        self.blips[id] = nil
    end
end

--- Remove todos os blips
function BlipHandler:clear()
    for id, _ in pairs(self.blips) do
        self:remove(id)
    end
end