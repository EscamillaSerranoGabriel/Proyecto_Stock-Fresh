package com.stockfresh.stockfreshweb.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler)
            throws Exception {

        HttpSession sesion = req.getSession(false);
        String rol = (sesion == null) ? null : (String) sesion.getAttribute("rol");
        if (rol == null) {
            return rechazar(res, 401, "Falta iniciar sesión");
        }
        String ruta = req.getRequestURI();
        if (ruta.startsWith("/api/admin/") && !rol.equals("Administrador")) {
            return rechazar(res, 403, "Tu rol no tiene permiso para esta sección");
        }

        return true;
    }

    private boolean rechazar(HttpServletResponse res, int codigo, String mensaje) throws Exception {
        res.setStatus(codigo);
        res.setContentType(MediaType.APPLICATION_JSON_VALUE);
        res.setCharacterEncoding("UTF-8");
        res.getWriter().write("{\"error\":\"" + mensaje + "\"}");
        return false;
    }
}