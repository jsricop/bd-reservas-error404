# Base de datos · Reserva de equipos de laboratorio

Datos del proyecto de **Gestión de Proyectos de Software · UAN · 2026-II**.
Repositorio del equipo **Error 404**.

| | |
|---|---|
| Recursos | 15 |
| Franjas horarias | 7110 |
| Reservas semilla | 570 |
| Usuarios | 40 |
| Periodo cubierto | 7 de septiembre a 31 de diciembre de 2026, días hábiles |

Del 5 de octubre en adelante los datos vienen en `datos_complemento.sql`. Ver `README_COMPLEMENTO.md`.

Hay reservas en fechas pasadas y futuras, en estado `activa`, `completada` y `cancelada`, para que puedan probar los tres casos.

---

## Qué hay aquí

```
esquema/
  esquema_postgres.sql   Estructura de tablas para PostgreSQL y Supabase
  esquema_mysql.sql      Estructura de tablas para MySQL y MariaDB
  modelo.dbml            Diagrama entidad-relación (pegar en dbdiagram.io)

datos.sql                Todos los INSERT de su dominio

csv/
  usuarios.csv
  recursos.csv
  franjas.csv
  reservas.csv
```

---

## Las cuatro tablas

**`usuarios`** — 40 estudiantes precargados. **No hay autenticación en este proyecto:** el usuario se identifica eligiendo su nombre de esta lista.

**`recursos`** — lo que se reserva: un osciloscopio, una impresora 3D o un kit de Arduino. Los campos `capacidad` y `atributos` describen cada uno.

**`franjas`** — los bloques horarios disponibles de cada recurso, por día. Una franja está libre si no tiene ninguna reserva en estado `activa`.

**`reservas`** — quién reservó qué franja y en qué estado.

`reservas` repite `recurso_id`, `fecha`, `hora_inicio` y `hora_fin` aunque ya estén en `franjas`. Es redundancia deliberada: así la consulta de «mis reservas» se resuelve sin joins.

---

## Cómo cargarla

### Supabase o PostgreSQL

1. En el panel de Supabase, abrir **SQL Editor**.
2. Pegar y ejecutar `esquema/esquema_postgres.sql`.
3. Pegar y ejecutar `datos.sql`.

Si el archivo es muy grande para el editor web, usar la terminal:

```bash
psql "$DATABASE_URL" -f esquema/esquema_postgres.sql
psql "$DATABASE_URL" -f datos.sql
```

### MySQL o MariaDB

```bash
mysql -u usuario -p nombre_bd < esquema/esquema_mysql.sql
mysql -u usuario -p nombre_bd < datos.sql
```

### Sin base de datos, solo archivos

Los CSV sirven para cargar en memoria o importar a Google Sheets. Tienen encabezado en la primera fila y están en UTF-8.

---

## Consultas para empezar

**Catálogo de recursos activos**

```sql
SELECT id, nombre, tipo, ubicacion, capacidad, atributos
FROM recursos
WHERE activo = 1
ORDER BY tipo, nombre;
```

**Franjas libres de un recurso en una fecha**

```sql
SELECT f.id, f.hora_inicio, f.hora_fin
FROM franjas f
WHERE f.recurso_id = 3
  AND f.fecha = '2026-09-18'
  AND NOT EXISTS (
    SELECT 1 FROM reservas r
    WHERE r.franja_id = f.id AND r.estado = 'activa'
  )
ORDER BY f.hora_inicio;
```

**Mis reservas**

```sql
SELECT r.id, rc.nombre AS recurso, r.fecha, r.hora_inicio, r.hora_fin, r.estado
FROM reservas r
JOIN recursos rc ON rc.id = r.recurso_id
WHERE r.usuario_id = 7
ORDER BY r.fecha DESC, r.hora_inicio DESC;
```

---

## Las validaciones son suyas

La base de datos **no impide** reservar dos veces la misma franja ni reservar en el pasado. Esas reglas son parte del alcance que se comprometieron a construir, y son justamente lo que se revisa en la Sprint Review.

**Regla propia de su dominio:** Todo equipo prestado debe devolverse antes de la hora tope indicada en el campo `atributos` del recurso.

---

## Casos de prueba

Para probar el rechazo por franja ocupada, busquen una franja que ya tenga reserva activa:

```sql
SELECT franja_id, COUNT(*) FROM reservas
WHERE estado = 'activa' GROUP BY franja_id;
```

Para probar el rechazo por franja pasada, cualquier fecha anterior a hoy sirve: hay franjas desde el 7 de septiembre.
