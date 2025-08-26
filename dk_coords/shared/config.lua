Config = {}

-- Configurações de controles
Config.Controls = {
    add = {
        control = "E",
        title = "E",
        desc = "Adicionar",
    },
    back = {
        control = "BACK",
        title = "BACKSPACE",
        desc = "Voltar",
    },
    up = {
        control = "PAGEUP",
        title = "PGUP",
        desc = "Subir",
    },
    down = {
        control = "PAGEDOWN",
        title = "PGDN",
        desc = "Descer",
    },
    finish = {
        control = "RETURN",
        title = "ENTER",
        desc = "Finalizar",
    },
    cancel = {
        control = "END",
        title = "END",
        desc = "Cancelar",
    },
}

-- Configurações visuais
Config.Visual = {
    colors = {
        primary = {64, 98, 187},
        secondary = {82, 72, 156},
        blip = 26,
    },
    markers = {
        type = 2,
        size = {2.0, 2.0, 2.0},
        rotation = {0.0, 180.0, 0.0},
        color = {255, 255, 255, 150},
    }
}

-- Configurações de permissão
Config.Permissions = {
    usePermissions = false,
    adminAce = "commands"
}
