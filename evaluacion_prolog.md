# Evaluación de Programación Lógica y Funcional (Prolog)

## Sección 1: Preguntas de Comprensión (Teoría)

Responde a las siguientes preguntas basándote en cómo funciona tu archivo `main.pl`:

1. **Backtracking:** En la regla `agrupar_en_turnos_h/4` y `seleccionar_distintos_h/6`, ¿qué papel juega el *backtracking* (retroceso) de Prolog si en un turno específico se llega a un `conflict/2` que evalúa a verdadero (es decir, hay un empalme)? ¿Cómo intenta Prolog resolverlo?
- **Respuesta:** En el caso que llegue a haber un conflicto de maestros, es decir, que conflict/2 sea verdadero, entonces el predicado select devolverá la ClaseActual a TempRestantes, e intentará con la clase siguiente. Si todas las clases tienen conflicto de maestros en el turno actual, ninguna clase será seleccionada y se procederá a la siguiente aula, o al siguiente turno en caso de que ya no queden aulas por asignar en el turno actual.
2. **El Operador de Corte (`!`):** En tu utilidad `repetir(_, 0, []) :- !.`, utilizaste el operador de corte (cut). ¿Qué sucedería en la ejecución (específicamente en la búsqueda de soluciones) si quitaras ese `!` y el programa necesitara retroceder sobre esa regla?
- **Respuesta:** Sé que el operador de corte ! previene que la regla ejecute backtracking, sin embargo, no tengo claro que efecto causaría de no estar ahí. Mi hipótesis sería que el programa intentaría hacer backtracking para probar con el resto de materias de obtener_clases/2.
3. **Condicionales:** En la regla `conflict(Maestro1, Maestro2)`, utilizas `\=` y `==`. En Prolog, ¿cuál es la diferencia estricta entre evaluar algo con `\=` (o `\==`) comparado con no unificar, y por qué es seguro usar `==` aquí en lugar de `=`?
- **Respuesta:** Debido a que Maestro1 ya fue unificado por seleccionar_distintos_h, el operador \= valida si es posible unificar Maestro1 con libre, resultando verdadero si no es posible. En caso de que Maestro1 haya sido unificado con libre por seleccionar_distintos_h, la regla conflict devolverá falso inmediatamente al comparar Maestro1 con libre, ya si la unificación si sería posible.  Por otro lado, es posible utilizar == porque ambas variables Maestro1 y Maestro2 ya han sido unificadas, comportamiento compatible con el operador ==.
4. **Manejo de Estado (Historial):** Tu programa implementa una lista de listas llamada `Historial`. ¿Por qué fue necesario pasar este historial a lo largo de todos los turnos? ¿Qué restricción de negocio específica de tu escuela evita este historial?
- **Respuesta:** Historial es una lista de listas, cada lista contiene las clases que ya fueron asignadas a un aula específica, con el objetivo de cumplir con la regla de negocio que indica que una misma aula no puede recibir la misma clases más de una vez.

---

## Sección 2: Ejercicios Estructurales (Práctica)

Realiza las siguientes modificaciones en tu archivo `main.pl`. Cuando termines, verifica que el programa se comporte de acuerdo a los nuevos requerimientos.

### Ejercicio 1: Limpieza completa (Dificultad: Fácil)
Actualmente, tu regla `limpiar_datos/0` (al final del archivo) elimina `imparte/2` y `requiere/2`, pero olvidamos incluir el nuevo hecho dinámico que agregamos recientemente: `numero_turnos/1`.
* **Tu tarea:** Modifica la regla `limpiar_datos/0` para que también borre `numero_turnos/1` de la memoria. Además, haz que imprima en consola un mensaje extra que diga _"Turnos eliminados."_.

### Ejercicio 2: Cambio visual en celdas vacías (Dificultad: Fácil)
En la regla `imprimir_celda/3`, cuando un espacio no tiene maestro asignado (es decir, `Maestro == libre`), el programa imprime un simple guion `'-'`.
* **Tu tarea:** Modifica esa regla para que, en lugar de imprimir un guion, imprima la palabra `"LIBRE"`. Asegúrate de que el espaciado no se rompa (mantén los espacios o tabulaciones necesarios).

### Ejercicio 3: Nombramiento de aulas en mayúsculas (Dificultad: Media)
Actualmente, tus aulas se nombran con letras minúsculas (a, b, c, d...) porque en la regla `generar/0` llamas a `generar_aulas(NumAulas, 97, Aulas)`, donde `97` es el código ASCII de la letra 'a'.
* **Tu tarea:** Cambia el comportamiento para que las aulas se nombren con letras mayúsculas (A, B, C, D...). Identifica qué línea dentro principal de `generar/0` debes modificar y cuál es el código ASCII correcto para empezar desde la 'A'.

### Ejercicio 4: Limitación laboral de los maestros (Dificultad: Media)
El sindicato de maestros acaba de pasar una nueva reforma: ningún maestro puede dar más de 6 horas diarias (lo que equivale a 3 turnos, ya que cada turno es de 2 horas). Actualmente, el límite está configurado para 8 horas (4 turnos).
* **Tu tarea:** Encuentra la regla responsable de asignar este límite inicial de turnos por docente (`turnos_maestros/1`) y modifícala para reflejar la nueva capacidad máxima de **3 turnos** por maestro.

---

## Sección 3: Nuevas Preguntas Teóricas

5. **Predicados Integrados:** En la regla `turnos_maestros/1`, utilizas tanto `setof/3` como `findall/3`. ¿Cuál es la diferencia principal entre estos dos predicados y por qué es útil usar `setof/3` al recopilar la lista original de `Maestros`?
- **Respuesta:** El predicado setof agrupa aquellos elementos idénticos, por lo que devolverá solo los elementos únicos de la lista de entrada sin repetir. En el caso de este programa, ignora la materia impartida ya que solo el maestro es relevante. Por otro lado, findall encuentra todos los elementos que pueden ser unificados con el primer parámetro, obteniéndolos desde el segundo parámetro (en este caso, del predicado member que devuelve uno por uno )

6. **Desestructuración de Listas:** En el caso recursivo de `obtener_clases/2`, la cabeza de la regla es `obtener_clases([(Materia, N)|RestoMaterias], Clases)`. Explica detalladamente cómo Prolog hace pattern matching (unificación) con esta estructura cuando recibe una lista completa de tuplas.
- **Respuesta:** 

7. **Aritmética en Prolog:** En múltiples partes del código usas el operador `is` (por ejemplo, `N1 is N - 1`). ¿Qué diferencia fundamental tiene el operador `is` comparado con el operador de asignación/unificación `=` cuando se trata de expresiones matemáticas en Prolog? ¿Qué pasaría si intentaras escribir `N1 = N - 1`?
- **Respuesta:** 

8. **Orden de las Cláusulas:** En tus reglas recursivas (como `asignar_maestros/3` o `repetir/3`), el caso base `[]` o `0` siempre está escrito antes que la cláusula recursiva principal. ¿Por qué es fundamental en Prolog este orden estructural de las reglas? ¿Qué impacto o errores habría si resolvieras poner la cláusula recursiva primero y el caso base al final?
- **Respuesta:** 

---

## Sección 4: Nuevos Ejercicios Prácticos

### Ejercicio 5: Mensaje de cierre de tabla (Dificultad: Fácil)
Al generar el horario, la tabla del plan de clases cierra con una simple línea de guiones.
* **Tu tarea:** Modifica la lógica de impresión (en la zona correspondiente a `mostrar_horario/3`) para que, justo debajo de la última línea separadora de la cuadrícula, el programa imprima el texto `" FIN DEL HORARIO "`, haciendo que sea más claro cuándo termina el despliegue del resultado.

### Ejercicio 6: Carga laboral como variable dinámica (Dificultad: Media)
En el Ejercicio 4 cambiaste la capacidad laboral máxima a 3 turnos de manera estática. Ahora queremos que este dato sea configurable por el archivo de configuración.
* **Tu tarea:** Agrega un nuevo hecho `:- dynamic max_turnos_maestro/1.` al cabezal. Muta su valor por defecto a `max_turnos_maestro(3).` Modifica `turnos_maestros/1` para que consulte este hecho dinámico al construir la lista en lugar del número duro `3`. Por último, asegúrate de actualizar también `limpiar_datos/0` y `cargar_requerimientos/1`.

### Ejercicio 7: Validación temprana de materia nula (Dificultad: Media)
Actualmente, si tratas de ejecutar `generar.` sin haber establecido las materias o cargado los datos, el programa avanzará con una lista `Clases` vacía y continuará procesando una tabla poblada de celdas "LIBRE".
* **Tu tarea:** Modifica la regla principal `generar/0` para que, tras invocar `todas_las_clases(Clases)` (y obtener su longitud `L`), detenga en seco la ejecución si comprueba que la longitud `L` es `0`. De ser así, deberá imprimir `"Precaucion: No hay materias para programar."` y finalizar sin intentar calcular aulas, ni turnos, ni usar el `catch`. *Pista: Puedes auxiliarte de un IF (`(Condicion -> Then ; Else)`) o cortar la regla anticipadamente.*

### Ejercicio 8: Restricción selectiva: Maestro inactivo por turno (Dificultad: Difícil)
En este momento, la generación de bloques y turnos asume que todo maestro listado puede impartir sus horas en *cualquier* momento del día. Vamos a implementar que un maestro tenga restricciones.
* **Tu tarea:** 
  1. Define un hecho `:- dynamic no_disponible_turno/2.` (ej: `no_disponible_turno(mosqued, 1).` lo que implica que el maestro `mosqued` no asiste en el turno 1 numérico).
  2. Vas a tener que modificar `agrupar_en_turnos/3`, la regla `agrupar_en_turnos_h/4` y `seleccionar_distintos_h/6`. Tu objetivo será añadir un nuevo parámetro "Contador de Turno" (que inicie en 1 y sume +1 con cada bloque). 
  3. Dentro de `seleccionar_distintos_h`, usarás ese valor actual numérico para añadir una última validación: `\+ no_disponible_turno(Maestro, TurnoActual)`. Demuestra que el sistema ahora respeta que un maestro pueda vetar sus propios horarios de entrada.
