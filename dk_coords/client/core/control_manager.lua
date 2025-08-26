ControlManager = {}
ControlManager.__index = ControlManager

function ControlManager:new(coordinateCollector)
    local obj = setmetatable({}, ControlManager)
    obj.collector = coordinateCollector
    obj.registered = false
    obj.controlTimer = GetGameTimer()
    obj.cooldownTime = 500
    return obj
end

function ControlManager:register()
    if self.registered then return end

    self.registered = true

    for action, data in pairs(Config.Controls) do
        self:registerAction(action, data)
    end
end

function ControlManager:registerAction(action, data)
    local keyName = "+dk_coords/" .. action
    local keyDesc = "Coordenadas: " .. data.desc

    RegisterKeyMapping(keyName, keyDesc, "keyboard", data.control)

    RegisterCommand(keyName, function()
        if not self:canExecuteAction() then return end
        self.collector:onControlPressed(action)
    end)

    RegisterCommand("-dk_coords/" .. action, function()
        if not self.collector.ui.isOpen then return end
        self.collector:onControlReleased(action)
    end)
end

function ControlManager:canExecuteAction()
    if GetGameTimer() < self.controlTimer then return false end
    if not self.collector.ui.isOpen then return false end

    self.controlTimer = GetGameTimer() + self.cooldownTime
    return true
end