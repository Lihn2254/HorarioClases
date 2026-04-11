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
