--[[
    Utils - Funções Utilitárias
    
    Funções auxiliares utilizadas em todo o script.
]]

--- Arredonda número para 2 casas decimais
---@param number number Número a arredondar
---@return number rounded Número arredondado
function RoundNumber(number)
    return math.ceil(number * 100) / 100
end

--- Desenha texto 3D no mundo
---@param coords table Coordenadas onde desenhar o texto
---@param text string Texto a ser exibido
function Draw3DText(coords, text)
    local x, y, z = coords.x, coords.y, coords.z + 1.0
    local onScreen, screenX, screenY = World3dToScreen2d(x, y, z - 0.3)

    if not onScreen then return end
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(screenX, screenY)

    local factor = (string.len(text)) / 370
    DrawRect(screenX, screenY + 0.0125, 0.01 + factor, 0.04, 0, 0, 0, 80)
end