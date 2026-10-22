function cargarMain() {
    // Opción A: Recarga la página principal del proyecto
    window.location.href = "index.html";
   
}
function cargarRegistroSesi(){
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
function cargarLogin() {
    fetch('InicioSesion.html')
        .then(response => {
            if (!response.ok) {
                throw new Error('No se pudo cargar la vista de inicio de sesión');
            }
            return response.text();
        })
        .then(html => {
            document.querySelector('.principal').innerHTML = html;
        })
        .catch(error => {
            console.error('Error:', error);
        });
}