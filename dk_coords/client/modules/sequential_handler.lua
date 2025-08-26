SequentialHandler = {}
SequentialHandler.__index = SequentialHandler

function SequentialHandler:new(params)
    local obj = setmetatable({}, SequentialHandler)
    obj.blipHandler = BlipHandler:new()
    obj.checkpoints = {}

    obj.defaultCheckPointModel = params.defaultCheckPointModel or 1
    obj.lastCheckpointModel = params.lastCheckpointModel or 3

    obj.mode = "sequential"
    return obj
end

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

function SequentialHandler:remove(_, id)
    self:removeCheckpoint(id)
    self.blipHandler:remove(id)
end

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

function SequentialHandler:delete()
    self.blipHandler:clear()
    for id, _ in pairs(self.checkpoints) do
        self:removeCheckpoint(id)
    end
end

function SequentialHandler:_createCheckpoint(model, x, y, z, targetX, targetY, targetZ, color)
    return CreateCheckpoint(
        model, x, y, z,
        targetX or 0, targetY or 0, targetZ or 0,
        5.0,
        color[1], color[2], color[3], 200, 1
    )
end

function SequentialHandler:removeCheckpoint(id)
    if self.checkpoints[id] then
        DeleteCheckpoint(self.checkpoints[id])
        self.checkpoints[id] = nil
    end
end