package com.stockfresh.stockfreshweb.controller;

import com.stockfresh.stockfreshweb.model.Locatario;
import com.stockfresh.stockfreshweb.repository.LocatarioRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/locatarios")
public class LocatarioController {
    
    public record RegistroRequest(String idLocatario, String nombre, String correoElectronico,
                                String contrasena, String numeroCelular) {}

    public record LoginRequest(String idLocatario, String contrasena) {}

    @Autowired
    private LocatarioRepository locatarioRepository;

    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@RequestBody RegistroRequest datos) {
        if (vacio(datos.idLocatario()) || vacio(datos.nombre())
                || vacio(datos.correoElectronico()) || vacio(datos.contrasena())) {
            return ResponseEntity.badRequest().body("Completa todos los campos obligatorios");
        }

        String id = datos.idLocatario().trim();
        if (locatarioRepository.existsById(id)) {
            return ResponseEntity.status(409).body("El ID ya existe");
        }

        Locatario nuevo = new Locatario();
        nuevo.setIdLocatario(id);
        nuevo.setNombre(datos.nombre().trim());
        nuevo.setCorreoElectronico(datos.correoElectronico().trim());
        nuevo.setNumeroCelular(datos.numeroCelular());
        nuevo.setContrasena(datos.contrasena()); 
        nuevo.setRol("Locatario");                                        

        try {
            locatarioRepository.save(nuevo);
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(409).body("Ese correo ya está registrado");
        }
        return ResponseEntity.ok(Map.of("mensaje", "Registro exitoso"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest datos, HttpServletRequest request) {
        if (vacio(datos.idLocatario()) || vacio(datos.contrasena())) {
            return ResponseEntity.status(401).body("Credenciales incorrectas");
        }

        Optional<Locatario> opt = locatarioRepository.findById(datos.idLocatario().trim());
        

        if (opt.isEmpty() || !datos.contrasena().equals(opt.get().getContrasena())) {
            return ResponseEntity.status(401).body("Credenciales incorrectas");
        }

        Locatario l = opt.get();
        
        HttpSession vieja = request.getSession(false);
        if (vieja != null) {
            vieja.invalidate();
        }
        HttpSession sesion = request.getSession(true);
        sesion.setAttribute("id", l.getIdLocatario());
        sesion.setAttribute("nombre", l.getNombre());
        sesion.setAttribute("rol", l.getRol());

        return ResponseEntity.ok(Map.of(
                "idLocatario", l.getIdLocatario(),
                "nombre", l.getNombre(),
                "rol", l.getRol()));
    }
    
    @GetMapping("/me")
    public Map<String, Object> me(HttpSession sesion) {
        return Map.of(
                "idLocatario", sesion.getAttribute("id"),
                "nombre", sesion.getAttribute("nombre"),
                "rol", sesion.getAttribute("rol"));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpSession sesion) {
        sesion.invalidate();
        return ResponseEntity.ok(Map.of("mensaje", "Sesión cerrada"));
    }

    private boolean vacio(String texto) {
        return texto == null || texto.isBlank();
    }
}