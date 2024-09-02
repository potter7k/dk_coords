Blips = {}
local blipsList = {}

function Blips:Clear()
    for _,blip in pairs(blipsList) do
        RemoveBlip(blip)
    end
    blipsList = {}
end

function Blips:Remove(id)
    if not id or not blipsList[id] then return end
    RemoveBlip(blipsList[id])
    blipsList[id] = nil
end

function Blips:Create(id, coords)
    Blips:Remove(id)
    blipsList[id] = AddBlipForCoord(coords)
    SetBlipSprite(blipsList[id],270)

    SetBlipAsShortRange(blipsList[id],true)
    SetBlipColour(blipsList[id], config.colors.blip)
    SetBlipScale(blipsList[id],0.5)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("SEQUENCIA DE BLIPS | BLIP "..id)
    EndTextCommandSetBlipName(blipsList[id])

    Wait(10)
end