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

-- Configurações de Race Checkpoints
Config.Sequences = {
    ["racepoints"] = {
        defaultPropModel = "prop_offroad_tyres02", -- Modelo de prop para checkpoints
        defaultOffset = 3.0, -- Distância do centro para esquerda/direita
        blipSprite = 315, -- Sprite do blip (315 = bandeira de corrida)
        blipColor = 5, -- Cor do blip (5 = amarelo)
        blipScale = 0.8, -- Escala do blip
    },
    ["sequential"] = {
        defaultCheckPointModel = 1, -- Modelo do checkpoint padrão
        lastCheckpointModel = 3, -- Modelo do último checkpoint
    },
    ["polyzone"] = {
        wallsColor = Config.Visual.colors.primary, -- Cor das paredes do Polyzone
    },
    ["vehicles"] = {
        defaultCheckPointModel = "sultan", -- Modelo do veículo padrão
        defaultCheckpointColor = Config.Visual.colors.secondary, -- Cor do veículo padrão
    },
}
