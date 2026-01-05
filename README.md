# 🗺️ Coletor de Coordenadas para FiveM

Este script **gratuito** facilita a coleta de coordenadas pela equipe do servidor. Com ele, é possível:

- 🟢 **Coletar múltiplas coordenadas** com um preview em tempo real.
- 🟢 **Gerar código automaticamente** para ser colado no arquivo do script.
- 🟢 **Compatibilidade** com Polyzone.
- 🟢 **Criar blips em outros scripts** com o export de criação de blips.
- 🟢 **Múltiplos modos de coleta**: Sequential, PolyZone, Vehicles, Racepoints.
- 🟢 **API via exports** para integração com outros scripts.

## 🚀 Implementação

1. **Baixe o Script**: [🔗 Link de Download](https://github.com/potter7k/dk_coords/releases/latest)
2. **Adicione ao Servidor**: Extraia o arquivo dk_coords para dentro da pasta do seu servidor.
3. **Inicie o Script**: Start o script no servidor com o comando abaixo.

## 📦 Dependências

| Script | Obrigatório | Descrição |
|--------|-------------|-----------|
| [PolyZone](https://github.com/mkafrin/PolyZone) | ✅ Sim | Necessário para o modo PolyZone |

## 💻 Comando

- O comando padrão para utilizar o script é:  
  ```
  /coords
  ```

## ⌨️ Controles Padrão

| Tecla | Ação |
|-------|------|
| `E` | Adicionar marcador |
| `BACKSPACE` | Remover último marcador |
| `PGUP` | Subir altura (Z) do marcador |
| `PGDN` | Descer altura (Z) do marcador |
| `ENTER` | Finalizar coleta |
| `END` | Cancelar coleta |

## 🎮 Modos de Coleta

### 1. Sequential (Sequencial)
Coleta pontos em sequência usando checkpoints nativos do GTA. Ideal para rotas de entrega, corridas, etc.

### 2. PolyZone
Cria zonas poligonais usando a biblioteca PolyZone. Ideal para delimitar áreas como garagens, lojas, zonas de segurança.

### 3. Vehicles (Veículos)
Posiciona veículos de preview nos pontos coletados. Ideal para linhas de largada de corridas.
- Suporta **modo debug** com linhas de alinhamento.

### 4. Racepoints (Checkpoints de Corrida)
Cria checkpoints de corrida com props (ex: pneus) posicionados à esquerda e direita, formando um "portal".

## 📡 API (Exports)

### Uso Básico

```lua
exports.dk_coords:collect(modo, configsColeta, configsHandler):next(function(coords)
    print(json.encode(coords, {indent = true}))
end, function(err)
    print("Erro: " .. tostring(err))
end)
```

### Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `modo` | string | Modo de coleta: `"sequential"`, `"polyzone"`, `"vehicles"`, `"racepoints"` |
| `configsColeta` | table | Configurações da coleta `{minMarkers, maxMarkers}` |
| `configsHandler` | table | Configurações específicas do handler |

### Exemplos

#### Modo Sequential
```lua
exports.dk_coords:collect("sequential", {
    minMarkers = 2,
    maxMarkers = 10
}, {}):next(function(coords)
    print("Rota coletada:", json.encode(coords))
end)
```

#### Modo Vehicles (com debug)
```lua
exports.dk_coords:collect("vehicles", {
    minMarkers = 4,
    maxMarkers = 8
}, {
    defaultCheckPointModel = "sultan",
    debug = true,
    debugLineLength = 10.0,
    debugLineColor = {255, 0, 0, 255}
}):next(function(coords)
    print("Posições de largada:", json.encode(coords))
end)
```

#### Modo Racepoints
```lua
exports.dk_coords:collect("racepoints", {
    minMarkers = 5,
    maxMarkers = 20
}, {
    propModel = "prop_offroad_tyres02",
    offset = 3.0,
    blipSprite = 315,
    blipColor = 5
}):next(function(coords)
    print("Checkpoints de corrida:", json.encode(coords))
end)
```

## ⚙️ Configuração

Os arquivos configuráveis estão nos seguintes diretórios:

- `📂 shared/config.lua` - Controles, cores, configurações visuais e de cada modo
- `📂 web/presets.json` - Presets de exportação de código

## 🔧 Formato de Saída

As coordenadas coletadas são retornadas no seguinte formato:

```lua
{
    { x = 123.45, y = 678.90, z = 12.34, h = 180.00 },
    { x = 234.56, y = 789.01, z = 23.45, h = 90.00 },
}
```

| Campo | Descrição |
|-------|-----------|
| `x` | Posição X |
| `y` | Posição Y |
| `z` | Posição Z (altura) |
| `h` | Heading (direção) |

## 🎥 Tutorial em Vídeo

Para ajudar você a começar a usar o dk_coords, confira este tutorial em vídeo:

<a href="https://www.youtube.com/watch?v=C-wEFgV1bqo" target="_blank">![SCRIPT GRATUITO de COLETA de COORDENADAS para FIVEM | INSTALAÇÃO e DEMONSTRAÇÃO](https://img.youtube.com/vi/C-wEFgV1bqo/hqdefault.jpg)</a>

### 🔒 Verificação de Permissão

Por padrão, o script **não** inclui verificação de permissão. Caso deseje adicionar, faça isso em:

- `server/main.lua`

## 🤝 Contribuição

Contribuições são **bem-vindas**! Aceitamos **Pull Requests** e sugestões de melhorias.

## 🛠️ Suporte

Se precisar de suporte, não hesite em entrar em contato conosco através do nosso Discord.

**DK Development** - https://discord.gg/NJjUn8Ad3P
