Sequencial = {}
local checkpoints = {}

function Sequencial:Remove(id)
    if not id then return end
    DeleteCheckpoint(checkpoints[id])
    checkpoints[id] = nil
end

function Sequencial:Delete()
    for id,_ in pairs(checkpoints) do
        Sequencial:Remove(id)
    end
end

local function createCheckpoint(model, x, y, z, tx, ty, tz, r, g, b)
    return CreateCheckpoint(model, x,y,z, tx, ty, tz, 5.0, r, g, b, 200, 1)
end

function Sequencial:Replace()
    local index = #Markers
    local blip = Markers[index]
    Sequencial:Remove(index)
    checkpoints[index] = createCheckpoint(3, blip.x, blip.y, blip.z - 1, nil, nil, nil, config.colors.rgb_1[1], config.colors.rgb_1[2], config.colors.rgb_1[3])
    Blips:Create(index, vector2(blip.x, blip.y))
end

function Sequencial:Add()
    local maxIndex = #Markers
    local blipNow = Markers[maxIndex]
    local blipBefore = Markers[maxIndex - 1]
    if blipBefore then
        Sequencial:Remove(maxIndex - 1)
        checkpoints[maxIndex - 1] = createCheckpoint(1, blipBefore.x, blipBefore.y, blipBefore.z - 1, blipNow.x, blipNow.y, blipNow.z - 1, config.colors.rgb_2[1], config.colors.rgb_2[2], config.colors.rgb_2[3])
    end

    checkpoints[maxIndex] = createCheckpoint(3, blipNow.x, blipNow.y, blipNow.z - 1, nil, nil, nil, config.colors.rgb_1[1], config.colors.rgb_1[2], config.colors.rgb_1[3])
    Blips:Create(maxIndex, vector2(blipNow.x, blipNow.y))
end
