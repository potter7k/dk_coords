BlipHandler = {}
BlipHandler.__index = BlipHandler

function BlipHandler:new()
    local obj = setmetatable({}, BlipHandler)
    obj.blips = {}
    return obj
end

function BlipHandler:create(id, coords)
    self:remove(id)

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z or 0.0)
    SetBlipSprite(blip, 270)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, Config.Visual.colors.blip)
    SetBlipScale(blip, 0.5)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("SEQUENCIA DE BLIPS | BLIP " .. id)
    EndTextCommandSetBlipName(blip)

    self.blips[id] = blip
    Wait(10)
end

function BlipHandler:remove(id)
    if self.blips[id] then
        RemoveBlip(self.blips[id])
        self.blips[id] = nil
    end
end

function BlipHandler:clear()
    for id, _ in pairs(self.blips) do
        self:remove(id)
    end
end