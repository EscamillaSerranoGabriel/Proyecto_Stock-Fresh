let datosPaso1 = {};

document.addEventListener('submit', async function (e) {
    if (e.target.id === 'formPaso1') {
        e.preventDefault();
        datosPaso1 = {
            nombre: document.getElementById('nombreLocatario').value.trim(),
            correo: document.getElementById('correoLoc').value.trim(),
            celular: document.getElementById('numLoc').value.trim()
        };
        document.getElementById('formPaso1').style.display = 'none';
        document.getElementById('formPaso2').style.display = 'block';
    }

    if (e.target.id === 'formPaso2') {
        e.preventDefault();
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
                alert('Registro exitoso');
                window.location.href = '/login.html';
            } else {
                alert('Error ' + respuesta.status + ': ' + await respuesta.text());
            }
        } catch (err) {
            console.error(err);
            alert('No se pudo conectar con el servidor.');
        }
    }
});