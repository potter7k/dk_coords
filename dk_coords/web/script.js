let presetsList = [];

function hideDivs() {
    $(".container").fadeOut(400);
    $(".controls").fadeOut(400);
    $(".coordsOptions").fadeOut(400);
    $(".descriptionContainer").fadeOut(400);
}

function emitClient(name, data) {
	$.post(`http://dk_coords/${name}`, JSON.stringify(data), function(datab) {
	});
}

function selectOption(opt) {
    if (!opt) return;

    emitClient("selectOption", {
        option: opt 
    });
}

function presetUi() {
    $(".controls").fadeOut(400);
    $(".coordsOptions").fadeIn(1000);
}

async function displayCoords(template) {
    await $.post(`http://dk_coords/collectCoords`, JSON.stringify({}), async (markers) => {
        let indexStart = 1
        if (template.includes('$s')) {
            const { value: inicial } = await Swal.fire({
                title: "Valor inicial",
                input: "text",
                inputValue: "1",
                inputLabel: "Digite abaixo o valor inicial de $s:",
                inputPlaceholder: ""
            });
            if (inicial) {
                indexStart = parseInt(inicial);
            }
        }
        let list = markers.map((marker, index) => {
        const adjustedIndex = indexStart + index;
        return template
            .replace(/\$s/g, adjustedIndex)
            .replace(/\$x/g, marker.x)
            .replace(/\$y/g, marker.y)
            .replace(/\$z/g, marker.z)
            .replace(/\$h/g, marker.h);
        }).join('\n');

        await Swal.fire({
            input: "textarea",
            inputValue: list,
            inputLabel: "Copie as coordenadas abaixo",
            inputPlaceholder: "",
            width: 800,
            inputAttributes: {
                "aria-label": ""
            },
            showCancelButton: true
        });
	});
}

function copyCoords(preset) {
    if (!presetsList[preset]) return;
    displayCoords(presetsList[preset]);
}

async function customPreset() {
    const { value: code } = await Swal.fire({
        title: "Código personalizado",
        input: "text",
        inputLabel: "Digíte o código abaixo:",
        inputPlaceholder: "[$s] = { $x, $y, $z, $h },"
    });
    if (code) {
        if (!presetsList.includes(code)) {
            presetsList.push(code);
            $(".coordsOptions").append(`
            <div onclick="copyCoords('${presetsList.length - 1}')" class="opt">
                <h1>${code}</h1>
            </div>
            `);
        }
        displayCoords(code);
    }
}

async function loadPresets() {
    try {
        const response = await fetch('presets.json'); 
        const data = await response.json();

        $(".coordsOptions").html(`
            <div onclick="customPreset()" class="opt">
                <h1>Personalizado</h1>
            </div>
        `);
        data.presets.forEach((preset, index) => {
            presetsList[index] = preset;
            $(".coordsOptions").append(`
            <div onclick="copyCoords('${index}')" class="opt">
                <h1>${preset}</h1>
            </div>
            `);
        });
    } catch (error) {
        console.error('Erro ao carregar o arquivo JSON:', error);
    }
}

$(document).on( "keydown", function( event ) {
    if ( event.which == 27 ) {
        emitClient("close", {});
    }
} );

$(document).ready(function(){
	window.addEventListener("message",function(event){
        let data = event.data;
        if (data.openStatus) {
            if (data.openStatus == "open") {
                $(".container").fadeIn(400);
                $(".descriptionContainer").fadeIn(1000);
            } else {
                hideDivs();
                return;
            }
        }

        if (data.updateDescription) {
            let updateDescription = data.updateDescription;
            $(".descriptionContainer h1").html(updateDescription.title);
            $(".descriptionContainer p").html(updateDescription.description);
            return;
        }

        if (data.selectPreset) {
            presetUi();
            return;
        }

        if (data.displayControls) {
            $(".container").fadeOut(400);
            $(".controls").fadeIn(400);
            return;
        }

        if (data.setupControls) {
            loadPresets();
            $(".controls").html("");
            const setupControls = data.setupControls;
            for (const control in setupControls) {
                $(".controls").append(`
                <li>
                    <div class="button">${setupControls[control].title}</div>
                    <div class="action">${setupControls[control].desc}</div>
                </li>
                `);
            }
            return;
        }
    });
});