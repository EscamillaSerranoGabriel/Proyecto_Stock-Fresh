package com.stockfresh.stockfreshweb.controller;

import com.stockfresh.stockfreshweb.model.Locatario;
import com.stockfresh.stockfreshweb.repository.LocatarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/locatarios")
public class LocatarioController {

    @Autowired
    private LocatarioRepository locatarioRepository;
    
        @PostMapping("/registro")
            public ResponseEntity<?> registrar(@RequestBody Locatario locatario) {
                if (locatarioRepository.existsById(locatario.getIdLocatario())) {
                    return ResponseEntity.status(409).body("El ID ya existe");
                }
                return ResponseEntity.ok(locatarioRepository.save(locatario));
            }

        @PostMapping("/login")
        public ResponseEntity<?> login(@RequestBody Locatario loginData) {
            Optional<Locatario> opt = locatarioRepository.findById(loginData.getIdLocatario());
            if (opt.isPresent() && opt.get().getContrasena().equals(loginData.getContrasena())) {
                return ResponseEntity.ok(opt.get());
            }
            return ResponseEntity.status(401).body("Credenciales incorrectas");
        }
        
}