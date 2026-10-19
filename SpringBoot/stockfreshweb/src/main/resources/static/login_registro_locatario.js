function cargarMain() {
    // Opción A: Recarga la página principal del proyecto
    window.location.href = "index.html";
   
}

function cargarLogin() {
    // 'login.html' es la ruta de tu archivo con el formulario de inicio de sesión
    fetch('InicioSesion.html')
        .then(response => {
            if (!response.ok) {
                throw new Error('No se pudo cargar la vista de login');
            }
            return response.text();
        })
        .then(html => {
            // Inserta el HTML del login dentro del <main>
            document.querySelector('.principal').innerHTML = html;
        })
        .catch(error => {
            console.error('Error:', error);
        });
}
    function cargarRegistro(){
    fetch('Registro.html')
        .then(response => {
            if (!response.ok) {
                throw new Error('No se pudo cargar la vista de login');
            }
            return response.text();
        })
        .then(html => {
            // Inserta el HTML del login dentro del <main>
            document.querySelector('.principal').innerHTML = html;
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }

function verPerfil() {
    // 'login.html' es la ruta de tu archivo con el formulario de inicio de sesión
    fetch('PerfilsinLocal.html')
        .then(response => {
            if (!response.ok) {
                throw new Error('No se pudo cargar la vista de login');
            }
            return response.text();
        })
        .then(html => {
            // Inserta el HTML del login dentro del <main>
            document.querySelector('.principal').innerHTML = html;
        })
        .catch(error => {
            console.error('Error:', error);
        });
}

function AgregarLocal() {
    // 'login.html' es la ruta de tu archivo con el formulario de inicio de sesión
    fetch('AgregarLocal.html')
        .then(response => {
            if (!response.ok) {
                throw new Error('No se pudo cargar la vista de login');
            }
            return response.text();
        })
        .then(html => {
            // Inserta el HTML del login dentro del <main>
            document.querySelector('.principal').innerHTML = html;
        })
        .catch(error => {
            console.error('Error:', error);
        });
}

function PerfilListo() {
    // 'login.html' es la ruta de tu archivo con el formulario de inicio de sesión
    fetch('Perfil.html')
        .then(response => {
            if (!response.ok) {
                throw new Error('No se pudo cargar la vista de login');
            }
            return response.text();
        })
        .then(html => {
            // Inserta el HTML del login dentro del <main>
            document.querySelector('.principal').innerHTML = html;
        })
        .catch(error => {
            console.error('Error:', error);
        });
}