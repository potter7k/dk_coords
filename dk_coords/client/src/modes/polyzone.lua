Poly = {}
local polyMarker

function Poly:Delete()
    if not polyMarker then return end 
    polyMarker:destroy()
end

function Poly:Refresh()
    local maxIndex = #Markers
    local blipsList = {}
    Blips:Clear()
    for index,blip in pairs(Markers) do
        table.insert(blipsList,vector2(blip.x, blip.y))

        Blips:Create(index, vector2(blip.x, blip.y), index == maxIndex)
    end
    if polyMarker then 
        polyMarker:destroy()
    end
    polyMarker = PolyZone:Create(blipsList, {name = "dk_coords_blips", debugColors = {walls = config.colors.rgb_2}, debugPoly = true})
end