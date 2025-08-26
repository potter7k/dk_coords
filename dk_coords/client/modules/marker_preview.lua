MarkerPreview = {}
MarkerPreview.__index = MarkerPreview

function MarkerPreview:new()
    local obj = setmetatable({}, MarkerPreview)
    obj.isActive = false
    obj.lastMarkerData = {}
    return obj
end

function MarkerPreview:startAddPreview()
    if self.isActive then return end

    self.isActive = true

    CreateThread(function()
        local ped = PlayerPedId()

        while self.isActive do
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)

            if coords.x then
                Draw3DText(coords, "HEADING ~b~" .. tostring(RoundNumber(heading)))
                self:drawMarker(coords)
            end

            Wait(1)
        end
    end)
end

function MarkerPreview:startMovePreview(action, coords)
    if self.isActive then return end

    self.isActive = true
    self.lastMarkerData = {x = coords.x, y = coords.y, z = coords.z}

    CreateThread(function()
        while self.isActive do
            if self.lastMarkerData.x then
                if action == "up" then
                    self.lastMarkerData.z = self.lastMarkerData.z + 0.01
                else
                    self.lastMarkerData.z = self.lastMarkerData.z - 0.01
                end

                self:drawMarker(vector3(
                    self.lastMarkerData.x,
                    self.lastMarkerData.y,
                    self.lastMarkerData.z
                ))
            end

            Wait(1)
        end
    end)
end

function MarkerPreview:stop()
    self.isActive = false
end

function MarkerPreview:drawMarker(coords)
    local config = Config.Visual.markers
    DrawMarker(
        config.type,
        coords,
        0.0, 0.0, 0.0,
        config.rotation[1], config.rotation[2], config.rotation[3],
        config.size[1], config.size[2], config.size[3],
        config.color[1], config.color[2], config.color[3], config.color[4],
        false, true, 2, nil, nil, false
    )
end

function MarkerPreview:getLastMarkerData()
    return self.lastMarkerData
end

function MarkerPreview:clearLastMarkerData()
    self.lastMarkerData = {}
end
