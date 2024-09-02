Controls = {}
local registeredControls = false
local controlTimer = GetGameTimer()

function Controls:Register()
    if registeredControls then return end
    registeredControls = true
    table.sort(config.controls)
    Ui:Send({setupControls = config.controls})
    for action,data in pairs(config.controls) do
        RegisterKeyMapping("+dk_coords/"..action,"Coordenadas: "..data.desc,"keyboard",data.control)
        RegisterCommand("+dk_coords/"..action,function(source,args,rawCommand)
            if GetGameTimer() < controlTimer then return end
            controlTimer = GetGameTimer() + 500
            if not Ui.opened then return end
            Main:ControlPressedIn(action)
        end)
        RegisterCommand("-dk_coords/"..action,function(source,args,rawCommand)
            if not Ui.opened then return end
            Main:ControlPressedOut(action)
        end)
    end
end