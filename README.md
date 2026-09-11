# Base de datos · Sistema de reserva de equipos de laboratorio

Datos del proyecto de **Gestión de Proyectos de Software · UAN · 2026-II**.

Repositorio del equipo **Error 404**. El esquema es el mismo para los tres equipos; lo que cambia son los datos. Este repositorio trae únicamente el dominio de equipos de laboratorio. Los otros dos equipos —MindSoft (cupos de asesoría) y Quantum Stack (salas de estudio)— tienen el suyo.

| Equipo | Dominio | Recursos | Franjas | Reservas |
|---|---|---|---|---|
| Error 404 | Equipos de laboratorio | 15 | 1.800 | 216 |

Las franjas cubren **20 días hábiles, del 7 de septiembre al 2 de octubre de 2026**. Hay reservas en fechas pasadas y futuras, activas, completadas y canceladas, para que puedan probar los tres casos.

---

## Qué hay en el repositorio

```
esquema/
  esquema_postgres.sql   Estructura de tablas para PostgreSQL y Supabase
  esquema_mysql.sql      Estructura de tablas para MySQL y MariaDB
  modelo.dbml            Diagrama entidad-relación (pegar en dbdiagram.io)

laboratorio/
  datos.sql              Todos los INSERT del dominio
  csv/usuarios.csv
  csv/recursos.csv
  csv/franjas.csv
  csv/reservas.csv
```

---

## Las cuatro tablas

**`usuarios`** — 40 estudiantes precargados. **No hay autenticación en este proyecto:** el usuario se identifica eligiendo su nombre de esta lista.

**`recursos`** — lo que se reserva. Cada equipo trae su `hora tope` dentro de `atributos` (por ejemplo `2 canales · 50 MHz · hora tope 20:00`). Hay franjas que terminan a las 20:00, así que el caso de rechazo es reproducible con los datos tal como vienen.

**`franjas`** — los bloques horarios disponibles de cada recurso, por día. Una franja está libre si no tiene una reserva en estado `activa`.

**`reservas`** — quién reservó qué franja y en qué estado: `activa`, `completada` o `cancelada`.

`reservas` repite `recurso_id`, `fecha`, `hora_inicio` y `hora_fin` a propósito, aunque ya estén en `franjas`. Así la consulta de «mis reservas» se resuelve sin joins.

---

## Cómo cargarla

### Supabase o PostgreSQL

1. En el panel de Supabase, abrir **SQL Editor**.
2. Pegar y ejecutar `esquema/esquema_postgres.sql`.
3. Pegar y ejecutar `laboratorio/datos.sql`.

Si el archivo es muy grande para el editor, usar la terminal:

```bash
psql "$DATABASE_URL" -f esquema/esquema_postgres.sql
psql "$DATABASE_URL" -f laboratorio/datos.sql
```

### MySQL o MariaDB

```bash
mysql -u usuario -p nombre_bd < esquema/esquema_mysql.sql
mysql -u usuario -p nombre_bd < laboratorio/datos.sql
```

El mismo `datos.sql` sirve para los dos motores: no tiene sintaxis específica de ninguno.

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

Hoy los 15 recursos están activos, así que el filtro no descarta ninguno. Está ahí para cuando den uno de baja.

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

La base de datos **no impide** reservar dos veces la misma franja ni reservar en el pasado. Esas reglas son parte del alcance que se comprometieron a construir, y son lo que se revisa en la Sprint Review.

Y además, la regla propia de este dominio:

> Todo equipo debe devolverse antes de la hora tope indicada en `atributos` del recurso.

---

## Datos para el arranque

Si necesitan un caso de prueba con conflicto, busquen una franja que ya tenga una reserva activa e intenten reservarla de nuevo:

```sql
SELECT franja_id, COUNT(*) FROM reservas
WHERE estado = 'activa' GROUP BY franja_id;
```

Y para probar el rechazo por franja pasada, cualquier fecha anterior al día de hoy sirve: hay franjas desde el 7 de septiembre.
