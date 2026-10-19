package com.stockfresh.stockfreshweb.repository;

import com.stockfresh.stockfreshweb.model.Locatario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LocatarioRepository extends JpaRepository<Locatario, String> {
  
}