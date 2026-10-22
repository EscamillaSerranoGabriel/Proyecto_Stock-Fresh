package com.stockfresh.stockfreshweb.model;

import jakarta.persistence.*;

@Entity
@Table(name = "LOCATARIO")
public class Locatario {

    @Id
@Column(name = "idLocatario", nullable = false, length = 50)
private String idLocatario;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    @Column(name = "correoElectronico", nullable = false, unique = true, length = 100)
    private String correoElectronico;

    @Column(name = "contrasena", nullable = false, length = 255)
    private String contrasena;
    
    @Column(name = "numeroCelular", nullable = true, length = 15)
    private String numeroCelular;
    
    @Column(name = "rol", nullable = false, length = 20)
    private String rol = "Locatario";

    // Constructor vacío obligatorio para JPA
    public Locatario() {}

    // Getters y Setters...
    public String getIdLocatario() { return idLocatario; }
    public void setIdLocatario(String idLocatario) { this.idLocatario = idLocatario; }
    
    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getCorreoElectronico() { return correoElectronico; }

    public void setCorreoElectronico(String correoElectronico) {
        this.correoElectronico = correoElectronico;
    }

    public String getNumeroCelular() {
        return numeroCelular;
    }

    public void setNumeroCelular(String numeroCelular) {
        this.numeroCelular = numeroCelular;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }
}