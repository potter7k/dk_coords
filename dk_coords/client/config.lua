config = {}

--[[
    Lista de teclas.
    control (string): tecla que realizará determinada ação. https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
    title (string): titulo relacionado ao botão que aparecerá na UI, alterar conforme sua preferência.
    desc (string): Descrição do botão, que aparece na UI.
]]

config.controls = { 
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

--[[
    Cores dos blips e markers.
    rgb_1 (table): Cores secundárias, em RGB, dos markers.
    rgb_2 (table): Cores primárias, em RGB, dos markers.
    blip (number): Cor dos blips. https://docs.fivem.net/docs/game-references/blips/
]]

config.colors = {
    rgb_1 = {82, 72, 156},
    rgb_2 = {64, 98, 187},
    blip = 26,
}