-- Esquema del sistema de reserva de recursos · MySQL 8 / MariaDB
-- Gestión de Proyectos de Software · UAN · 2026-II
--
-- Equivalente al esquema de PostgreSQL. Los archivos datos.sql funcionan
-- sin cambios en ambos motores.

SET NAMES utf8mb4;

DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS franjas;
DROP TABLE IF EXISTS recursos;
DROP TABLE IF EXISTS usuarios;

CREATE TABLE usuarios (
  id        INT          NOT NULL,
  nombre    VARCHAR(120) NOT NULL,
  codigo    VARCHAR(20)  NOT NULL,
  programa  VARCHAR(80)  NOT NULL,
  correo    VARCHAR(120) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_codigo (codigo),
  UNIQUE KEY uq_usuarios_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE recursos (
  id         INT          NOT NULL,
  nombre     VARCHAR(120) NOT NULL,
  tipo       VARCHAR(60)  NOT NULL,
  ubicacion  VARCHAR(80)  NOT NULL,
  capacidad  INT          NOT NULL DEFAULT 1,
  atributos  VARCHAR(200) NULL,
  activo     SMALLINT     NOT NULL DEFAULT 1,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE franjas (
  id          INT  NOT NULL,
  recurso_id  INT  NOT NULL,
  fecha       DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin    TIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_franjas_recurso_fecha (recurso_id, fecha),
  CONSTRAINT fk_franjas_recurso FOREIGN KEY (recurso_id) REFERENCES recursos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reservas (
  id          INT         NOT NULL,
  franja_id   INT         NOT NULL,
  recurso_id  INT         NOT NULL,
  usuario_id  INT         NOT NULL,
  fecha       DATE        NOT NULL,
  hora_inicio TIME        NOT NULL,
  hora_fin    TIME        NOT NULL,
  estado      VARCHAR(15) NOT NULL,
  creada_en   DATETIME    NOT NULL,
  PRIMARY KEY (id),
  KEY idx_reservas_usuario (usuario_id, estado),
  KEY idx_reservas_franja  (franja_id, estado),
  CONSTRAINT fk_reservas_franja  FOREIGN KEY (franja_id)  REFERENCES franjas(id),
  CONSTRAINT fk_reservas_recurso FOREIGN KEY (recurso_id) REFERENCES recursos(id),
  CONSTRAINT fk_reservas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
