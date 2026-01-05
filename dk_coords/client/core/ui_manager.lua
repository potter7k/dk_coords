--[[
    UIManager - Gerenciador de Interface
    
    Responsável por controlar a interface NUI (HTML/CSS/JS).
    Gerencia a abertura/fechamento da UI e comunicação com o frontend.
]]

UIManager = {}
UIManager.__index = UIManager

--- Cria uma nova instância do UIManager
---@return table obj Instância do UIManager
function UIManager:new()
    local obj = setmetatable({}, UIManager)
    obj.isOpen = false
    return obj
end

--- Alterna o estado da UI (abrir/fechar)
---@param state boolean true para abrir, false para fechar
function UIManager:toggle(state)
    self.isOpen = state
    SetNuiFocus(state, state)
    self:send({
        openStatus = (state and "open") or "close"
    })
end

--- Envia dados para a interface NUI
---@param data table Dados a enviar
---@param focus boolean|nil Define o foco da NUI (opcional)
function UIManager:send(data, focus)
    SendNUIMessage(data)
    if focus ~= nil then
        SetNuiFocus(focus, focus)
    end
end

--- Atualiza o título e descrição exibidos na UI
---@param title string Título
---@param description string Descrição (suporta HTML)
function UIManager:updateDescription(title, description)
    self:send({
        updateDescription = {
            title = title,
            description = description,
        }
    })
end

--- Exibe a seleção de presets na UI
function UIManager:showPresetSelection()
    self:send({selectPreset = true}, true)
end

--- Exibe os controles na UI
function UIManager:showControls()
    self:send({displayControls = true}, false)
end

--- Configura os controles na UI
---@param controls table Tabela de controles
function UIManager:setupControls(controls)
    self:send({setupControls = controls})
end
