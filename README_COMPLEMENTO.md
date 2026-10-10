# Complemento de datos · del 5 de octubre al 31 de diciembre

Repositorio del equipo **Error 404** · Equipos de laboratorio
Gestión de Proyectos de Software · UAN · 2026-II

> **Por qué existe este archivo.** La carga inicial cubría del 7 de septiembre al
> **2 de octubre**. A partir del 5 de octubre no había ninguna franja cargada, así que
> cualquier prueba sobre fechas actuales o futuras devolvía vacío. Este complemento
> extiende los datos hasta el 31 de diciembre.

| | Antes | Ahora |
|---|---|---|
| Periodo | 7 sep – 2 oct | 7 sep – **31 dic** |
| Días hábiles | 20 | **79** |
| Franjas | 1800 | **7110** |
| Reservas | 216 | **570** |

Lo que agrega este complemento: **5310 franjas** (ids 1801 a 7110) y
**354 reservas** (ids 217 a 570).

---

## Cómo cargarlo

Es **aditivo**. No borra ni modifica nada de lo que ya tienen cargado.

### Si ya cargaron `datos.sql`

Solo ejecuten el complemento:

```bash
psql "$DATABASE_URL" -f datos_complemento.sql     # PostgreSQL o Supabase
mysql -u usuario -p nombre_bd < datos_complemento.sql   # MySQL o MariaDB
```

En Supabase, también sirve pegarlo en el **SQL Editor**. Si el editor web se queda
corto por el tamaño, usen la terminal.

### Si están empezando de cero

```bash
psql "$DATABASE_URL" -f esquema/esquema_postgres.sql
psql "$DATABASE_URL" -f datos.sql
psql "$DATABASE_URL" -f datos_complemento.sql
```

El orden importa: primero el esquema, después los datos base, al final el complemento.

### Si trabajan con CSV

`csv/franjas_complemento.csv` y `csv/reservas_complemento.csv` tienen las mismas
columnas y el mismo orden que los originales. Se concatenan sin ajustar nada.

---

## Qué NO cambia

Los **15 recursos** y los **40 usuarios** son los mismos. Este complemento no
agrega ni modifica filas en esas dos tablas, así que cualquier referencia que ya
tuvieran en su código sigue siendo válida.

Los bloques horarios también son los mismos: 07:00–09:00 · 09:00–11:00 · 11:00–13:00 · 14:00–16:00 · 16:00–18:00 · 18:00–20:00.

---

## Lo que deben saber de estos datos

**Los días hábiles están completos.** Lunes a viernes, sin huecos, con las
15 × 6 = **90 franjas diarias** de siempre.

**Los festivos no tienen franjas.** El sistema no opera esos días, así que no se
generaron. Si consultan una de estas fechas y no ven nada, no es un error de su
código:

| Fecha | Día | Festivo |
|---|---|---|
| 2026-10-12 | lunes | Día de la Raza |
| 2026-11-02 | lunes | Todos los Santos (trasladado) |
| 2026-11-16 | lunes | Independencia de Cartagena (trasladado) |
| 2026-12-08 | martes | Inmaculada Concepción |
| 2026-12-25 | viernes | Navidad |

**La ocupación baja con la lejanía.** Nadie reserva una sala con dos meses de
anticipación, y los datos lo reflejan: alrededor del 12 % de las franjas de octubre
están ocupadas, 6 % en noviembre y 2 % en diciembre. Hay franjas libres de sobra
para probar el flujo de reservar, y suficientes ocupadas para probar el conflicto.

**Los estados son coherentes con la fecha.** Lo anterior al 9 de octubre quedó en
`completada` o `cancelada`. Del 9 en adelante hay `activa` y `cancelada`, nunca
`completada`.

**Una franja tiene como máximo una reserva.** Esa es una propiedad de los datos que
les entrego, no una restricción de la base: la base sigue permitiendo que inserten
dos reservas activas sobre la misma franja. **Impedirlo es trabajo de ustedes.**

---

## Sobre los IDs

El esquema define `id INTEGER PRIMARY KEY`, **sin autoincremento**. Su aplicación
tiene que calcular el id de cada fila nueva. Los nuevos máximos son:

| Tabla | Máximo id |
|---|---|
| `franjas` | 7110 |
| `reservas` | 570 |

Si prefieren que la base lo asigne sola, al final de `datos_complemento.sql` hay un
bloque comentado con el `ALTER TABLE` para PostgreSQL y para MySQL. Es aditivo: los
`INSERT` que ya traen id siguen funcionando igual.

---

## Verificación rápida

Después de cargar, esta consulta debe devolver 79 filas, la última del 31 de
diciembre:

```sql
SELECT f.fecha,
       count(*)                                        AS franjas,
       count(r.id) FILTER (WHERE r.estado = 'activa')  AS ocupadas
FROM franjas f
LEFT JOIN reservas r ON r.franja_id = f.id
GROUP BY f.fecha
ORDER BY f.fecha;
```

En MySQL, cambiar el `FILTER` por
`sum(case when r.estado = 'activa' then 1 else 0 end)`.
