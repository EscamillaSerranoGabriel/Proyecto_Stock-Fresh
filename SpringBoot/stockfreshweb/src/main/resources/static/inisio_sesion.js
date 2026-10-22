document.addEventListener('submit', async function (e) {

    const id = document.getElementById('idLocatario').value.trim();
    const contrasena = document.getElementById('inputPassword').value;

    try {
        const respuesta = await fetch('/api/locatarios/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ idLocatario: id, contrasena: contrasena })
        });

        if (respuesta.ok) {
            const locatario = await respuesta.json();
            alert('¡Bienvenido ' + locatario.nombre + '!');

            localStorage.setItem('idLocatario', locatario.idLocatario);
            window.location.href = '/InicioSesion.html';
        } else if (respuesta.status === 401) {
            alert('ID o contraseña incorrectos.');
        } else {
            alert('Error del servidor (' + respuesta.status + ').');
        }
    } catch (error) {
        console.error(error);
        alert('No se pudo conectar con el servidor.');
    }
});