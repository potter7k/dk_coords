--[[
    PolyzoneHandler - Manipulador de PolyZone
    
    Responsável por criar zonas poligonais usando a biblioteca PolyZone.
    Ideal para delimitar áreas como garagens, lojas, zonas de segurança, etc.
    
    Parâmetros (handlerParams):
        - wallsColor: table - Cor RGB das paredes {r, g, b} (padrão: Config.Visual.colors.primary)
    
    Dependência:
        - Requer o script PolyZone instalado e ativo
]]

PolyzoneHandler = {}
PolyzoneHandler.__index = PolyzoneHandler
local sequenceConfig = Config.Sequences["polyzone"] or {
    wallsColor = Config.Visual.colors.primary,
}

--- Cria uma nova instância do PolyzoneHandler
---@param params table Parâmetros de configuração
---@return table obj Instância do PolyzoneHandler
function PolyzoneHandler:new(params)
    local obj = setmetatable({}, PolyzoneHandler)
    obj.blipHandler = BlipHandler:new()
    obj.polyMarker = nil
    obj.mode = "polyzone"
    obj.wallsColor = params.wallsColor or sequenceConfig.wallsColor
    return obj
end

--- Atualiza a visualização da PolyZone com os marcadores atuais
---@param markers table Lista de marcadores coletados
function PolyzoneHandler:_refresh(markers)
    local blipsList = {}

    self.blipHandler:clear()

    for index, marker in pairs(markers) do
        table.insert(blipsList, vector2(marker.x, marker.y))
        self.blipHandler:create(index, vector2(marker.x, marker.y))
    end

    if self.polyMarker then
        self.polyMarker:destroy()
    end

    if #blipsList > 0 then
        self.polyMarker = PolyZone:Create(blipsList, {
            name = "dk_coords_blips",
            debugColors = {walls = self.wallsColor},
            debugPoly = true
        })
    end
end

--- Adiciona um novo marcador e atualiza a PolyZone
---@param markers table Lista de marcadores coletados
function PolyzoneHandler:add(markers)
    self:_refresh(markers)
end

--- Remove um marcador e atualiza a PolyZone
---@param markers table Lista de marcadores
---@param id number ID do marcador a remover
function PolyzoneHandler:remove(markers, id)
    self:_refresh(markers)
    self.blipHandler:remove(id)
end

--- Substitui um marcador e atualiza a PolyZone
---@param markers table Lista de marcadores
function PolyzoneHandler:replace(markers)
    self:_refresh(markers)
end

--- Deleta a PolyZone e limpa os dados
function PolyzoneHandler:delete()
    self.blipHandler:clear()
    if self.polyMarker then
        self.polyMarker:destroy()
        self.polyMarker = nil
    end
end
