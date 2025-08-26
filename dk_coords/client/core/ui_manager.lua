UIManager = {}
UIManager.__index = UIManager

function UIManager:new()
    local obj = setmetatable({}, UIManager)
    obj.isOpen = false
    return obj
end

function UIManager:toggle(state)
    self.isOpen = state
    SetNuiFocus(state, state)
    self:send({
        openStatus = (state and "open") or "close"
    })
end

function UIManager:send(data, focus)
    SendNUIMessage(data)
    if focus ~= nil then
        SetNuiFocus(focus, focus)
    end
end

function UIManager:updateDescription(title, description)
    self:send({
        updateDescription = {
            title = title,
            description = description,
        }
    })
end

function UIManager:showPresetSelection()
    self:send({selectPreset = true}, true)
end

function UIManager:showControls()
    self:send({displayControls = true}, false)
end

function UIManager:setupControls(controls)
    self:send({setupControls = controls})
end
