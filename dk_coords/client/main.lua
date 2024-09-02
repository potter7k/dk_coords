local inPreview

local lastMarkerData = {}

Markers = {}
Main = {}

RegisterNetEvent("dk_coords/toggleNui")
AddEventHandler("dk_coords/toggleNui",function()
    if not Ui.opened then
        Controls:Register()
        UpdateDescription("Tipo de blip", "Escolha o <strong>tipo de blip</strong> que você quer começar a <strong>coletar</strong>.")
        Ui:ToggleUi(true)
    else
        Main:closeAll()
    end
end)

function Main:closeAll()
    Ui:ToggleUi(false)
    Main.collectingBlips = nil
    inPreview = nil
    lastMarkerData = {}
    Sequencial:Delete()
    Poly:Delete()
    Blips:Clear()
end

local function updateMarkersDisplay()
    if not Main.collectingBlips then return end
    local maxIndex = #Markers
    if maxIndex == 0 then
        UpdateDescription(
            "Coleta de Blips",
            "Você começou a <strong>coletar blips</strong> no modo <strong>" .. Main.collectingBlips .. "</strong>. " ..
            "Primeiro, escolha o local do seu <strong>primeiro blip</strong>. " ..
            "Vá até o local desejado e pressione a tecla <strong>" .. config.controls["add"].title .. "</strong>."
        )
    elseif maxIndex == 1 then
        UpdateDescription(
            "Coleta de Blips (1)",
            "Você coletou o <strong>primeiro blip</strong>. " ..
            "Vá ao local desejado e pressione a tecla <strong>" .. config.controls["add"].title .. "</strong> para prosseguir coletando novos blips."
        )
    else
        UpdateDescription(
            "Coleta de Blips (" .. maxIndex .. ")",
            "Continue <strong>coletando blips</strong> e aperte a tecla <strong>" .. config.controls["finish"].title .. "</strong> para finalizar " ..
            "ou <strong>" .. config.controls["cancel"].title .. "</strong> para cancelar."
        )
    end
    
    if Main.collectingBlips == "polyzone" then  
        Poly:Refresh()
    end
end

-- PREVIEW THREAD
local function draw3DTxt(coords,text)
    local x,y,z = coords.x, coords.y, coords.z + 1.0
    local percentage = 1
    local onScreen,_x,_y = World3dToScreen2d(x,y,z-0.3)
    SetTextFont(4)
    SetTextScale(0.35,0.35)
    SetTextColour(255,255,255,150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text))/370
    DrawRect(_x,_y+0.0125,0.01+factor,0.04,0,0,0,80)
end

local function drawPreview(coords)
    DrawMarker(2, coords, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 255, 255, 255, 150, false, true, 2, nil, nil, false)
end

local function addPreviewThread()
    if inPreview then return end
    inPreview = true
    local ped = PlayerPedId()
    while inPreview do
        local coords = GetEntityCoords(ped)
        if coords.x then
            draw3DTxt(coords,"HEADING ~b~"..tostring(MathLegth(GetEntityHeading(ped))))
            drawPreview(coords)
        end
        Wait(1)
    end
end

local function upDownPreviewThread(action,coords)
    if inPreview then return end
    inPreview = true
    local targetCoords = {x = coords.x, y = coords.y, z = coords.z}
    while inPreview do
        if targetCoords.x then
            if action == "up" then
                targetCoords.z = targetCoords.z + 0.01
            else
                targetCoords.z = targetCoords.z - 0.01
            end
            lastMarkerData = targetCoords
            drawPreview(vector3(targetCoords.x, targetCoords.y, targetCoords.z))
        end
        Wait(1)
    end
end
-- 

-- CONTROL PRESS
function Main:ControlPressedIn(action)
    if not Main.collectingBlips then return end
    if action == "cancel" then
        Main:closeAll()
    elseif action == "add" then
        addPreviewThread()
    elseif action == "back" then
        if #Markers < 1 then return end
        local id = #Markers
        table.remove(Markers,id)
        Blips:Remove(id)
        if Main.collectingBlips == "sequencial" then
            Sequencial:Remove(id)
        end
        updateMarkersDisplay()
    elseif action == "up" or action == "down" then 
        if #Markers < 1 or Main.collectingBlips == "polyzone" then return end
        upDownPreviewThread(action, Markers[#Markers])
    elseif action == "finish" then
        if #Markers < 1 then print("Necessário ao menos 1 blip.") return end
        UpdateDescription("Selecionar preset", "Selecione o preset desejado de coordenadas.")
        Ui:Send({selectPreset = true}, true)
    end
end

function Main:ControlPressedOut(action)
    if action == "add" then
        if not inPreview then return end
        inPreview = false
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        table.insert(Markers, {x = MathLegth(coords.x), y = MathLegth(coords.y), z = MathLegth(coords.z), h = MathLegth(heading)})
        if Main.collectingBlips == "sequencial" then
            Sequencial:Add()
        end
        updateMarkersDisplay()
    elseif action == "up" or action == "down" then 
        if not inPreview then return end
        inPreview = false
        Markers[#Markers] = lastMarkerData
        lastMarkerData = {}
        if Main.collectingBlips == "sequencial" then
            Sequencial:Replace()
        end
        updateMarkersDisplay()
    end
end
-- 