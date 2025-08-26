VehiclesHandler = setmetatable({}, SequentialHandler) -- Inherit from SequentialHandler
VehiclesHandler.__index = VehiclesHandler

---@diagnostic disable-next-line: duplicate-set-field
function VehiclesHandler:new(params)
    local obj = setmetatable({}, VehiclesHandler)
    obj.blipHandler = BlipHandler:new()
    obj.checkpoints = {}

    obj.defaultCheckPointModel = params.defaultCheckPointModel or "sultan"

    obj.mode = "vehicles"
    return obj
end

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

---@diagnostic disable-next-line: duplicate-set-field
function VehiclesHandler:add(markers)
    local ped = PlayerPedId()
    local maxIndex = #markers
    local currentMarker = markers[maxIndex]

    self.checkpoints[maxIndex] = self:_createCheckpoint(
        self.defaultCheckPointModel,
        currentMarker.x, currentMarker.y, currentMarker.z - 1,
        GetEntityHeading(ped),
        Config.Visual.colors.secondary
    )

    self.blipHandler:create(maxIndex, vector2(currentMarker.x, currentMarker.y))
end

---@diagnostic disable-next-line: duplicate-set-field
function VehiclesHandler:removeCheckpoint(id)
    if self.checkpoints[id] then
        DeleteEntity(self.checkpoints[id])
        self.checkpoints[id] = nil
    end
end