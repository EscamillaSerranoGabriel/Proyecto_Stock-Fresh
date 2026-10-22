    
let datosPaso1 = {};

document.addEventListener('submit', async function (e) {
    const formId = e.target.id;

    if (formId === 'formPaso1' || formId === 'formPaso2') {
        e.preventDefault();
    } else {
        return; 
    }

   
    if (formId === 'formPaso1') {
        datosPaso1 = {
            nombre: document.getElementById('nombreLocatario').value.trim(),
            correo: document.getElementById('correoLoc').value.trim(),
            celular: document.getElementById('numLoc').value.trim()
        };

        document.getElementById('formPaso1').style.display = 'none';
        document.getElementById('formPaso2').style.display = 'block';
        console.log("Datos del paso 1 guardados. Pasando al paso 2.");
    }

   
    if (formId === 'formPaso2') {
        try {
            const respuesta = await fetch('/api/locatarios/registro', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    idLocatario: document.getElementById('idLocatario').value.trim(),
                    nombre: datosPaso1.nombre,
                    correoElectronico: datosPaso1.correo,
                    contrasena: document.getElementById('password').value,
                    numeroCelular: datosPaso1.celular
                })
            });

            if (respuesta.ok) {
                alert('¡Registro exitoso en Stock & Fresh!');
                cargarDatosRegistro();

            } else {
                const mensajeError = await respuesta.text();
                alert('Error al registrar (' + respuesta.status + '): ' + mensajeError);
            }
        } catch (err) {
            console.error("Error en la petición Fetch:", err);
            alert('No se pudo conectar con el servidor backend.');
        }
    }
});
