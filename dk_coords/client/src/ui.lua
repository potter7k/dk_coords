Ui = {}
Ui.opened = false

-- SEND NUI

function Ui:ToggleUi(bool)
    Ui.opened = bool
    SetNuiFocus(bool, bool)
    Ui:Send({
        openStatus = (bool and "open") or "close"
    })
end

function Ui:Send(tbl, focus)
    SendNUIMessage(tbl)
    if focus ~= nil then
        SetNuiFocus(focus, focus)
    end
end

-- CALLBACKS

RegisterNUICallback("close",function(data,cb)
    Main:closeAll()
end)

RegisterNUICallback("collectCoords",function(data,callback)
    callback(Markers)
end)

RegisterNUICallback("selectOption",function(data,cb)
    if not data or not data.option then return end
    if GetResourceState('PolyZone') == 'missing' then return print("Erro, script PolyZone desativado.") end
    Main.collectingBlips = data.option

    Markers = {}

    UpdateDescription("Coleta de Blips", "Você começou a <strong>coletar blips</strong> no modo <strong>"..Main.collectingBlips.."</strong>. Primeiro, escolha o local do seu <strong>primeiro blip</strong>. Vá até o local desejado e pressione a tecla <strong>"..config.controls["add"].title.."</strong>.")
    Ui:Send({displayControls = true}, false)
end)