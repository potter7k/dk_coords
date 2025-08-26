PolyzoneHandler = {}
PolyzoneHandler.__index = PolyzoneHandler

function PolyzoneHandler:new(params)
    local obj = setmetatable({}, PolyzoneHandler)
    obj.blipHandler = BlipHandler:new()
    obj.polyMarker = nil
    obj.mode = "polyzone"
    return obj
end

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
            debugColors = {walls = Config.Visual.colors.primary},
            debugPoly = true
        })
    end
end

function PolyzoneHandler:add(markers)
    self:_refresh(markers)
end

function PolyzoneHandler:remove(markers, id)
    self:_refresh(markers)
    self.blipHandler:remove(id)
end

function PolyzoneHandler:replace(markers)
    self:_refresh(markers)
end

function PolyzoneHandler:delete()
    self.blipHandler:clear()
    if self.polyMarker then
        self.polyMarker:destroy()
        self.polyMarker = nil
    end
end
