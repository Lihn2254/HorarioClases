# Generador de Horarios Escolares en Prolog

## Descripción General

Este programa está desarrollado en Prolog y tiene como objetivo automatizar la planificación de horarios semestrales para una escuela secundaria. Dado que todas las semanas del curso comparten la misma estructura, el sistema planifica una semana típica (de lunes a viernes) distribuyendo las cargas académicas en los horarios disponibles.

El algoritmo utiliza la resolución y el motor de inferencia lógica de Prolog para satisfacer un conjunto de restricciones operativas estrictas:

- Asigna profesores a las materias que están capacitados para impartir.
- Limita la carga laboral de los profesores a un máximo de 8 horas diarias (equivalente a 4 turnos de 2 horas).
- Evita empalmes, asegurando que un profesor no imparta más de una clase en el mismo bloque horario.
- Restringe la impartición de materias a un máximo de una clase por día para el mismo grupo.
- Gestiona la asignación dinámica de aulas ("a", "b", "c", etc.) en 6 turnos predefinidos: 7:00, 9:00, 11:00, 13:00, 15:00 y 17:00 horas.

El sistema también cuenta con persistencia de datos básica (guardar y cargar en un archivo de texto) y la capacidad de limpiar la base de hechos dinámicamente para procesar nuevas configuraciones.

## Ejecución del Programa

Para ejecutar este proyecto, necesitas un intérprete de Prolog como SWI-Prolog.

Carga el código fuente en el intérprete:

```prolog
?- [horarios].
```

(asegúrate de que el archivo se llame horarios.pl).

Para iniciar la generación del horario y visualizarlo, primero debes cargar los requerimientos desde el archivo de texto y luego ejecutar la regla principal:

```prolog
?- cargar_requerimientos('requerimientos_horario.txt').
?- generar.
```

Para cargar un horario previamente guardado:

```prolog
?- cargar_horario('horario_salvado.txt').
```

Para reiniciar el estado y limpiar la base de datos de profesores y requerimientos:

```prolog
?- limpiar_datos.
```

## Descripción Detallada de Reglas y Métodos

A continuación, se detalla la funcionalidad de cada regla y predicado definido en el código fuente.

### 1. Directivas Dinámicas y Base de Hechos

- `dynamic numero_turnos/1, imparte/2, requiere/2`: Permiten que los hechos sobre la configuración general (turnos), qué profesor imparte qué materia y cuántas clases se requieren de una materia sean modificados (agregados o eliminados) durante el tiempo de ejecución.
- `cargar_requerimientos(Archivo)`: Lee un archivo de texto con la base de hechos (como `requerimientos_horario.txt`) limpia los datos anteriores y carga dinámicamente (`assertz`) la nueva configuración para el generador.
- `imparte(Maestro, Materia)`: Define las asignaturas que cada docente está capacitado para enseñar.
- `requiere(Materia, CantidadGrupos)`: Define la cantidad de bloques o clases semanales que deben programarse para una materia específica.

### 2. Lógica de Generación y Procesamiento de Listas

- `repetir(Elemento, N, Lista)`: Un método de utilidad recursivo que toma un elemento y genera una lista de tamaño N que contiene copias de dicho elemento. Se usa para replicar las clases según los requerimientos.
- `obtener_clases(ListaRequerimientos, ListaClases)`: Itera sobre los hechos requiere y utiliza repetir para crear una lista plana que contenga todas las instancias de materias que deben programarse.
- `todas_las_clases(Lista)`: Recopila todos los requerimientos usando findall y delega a obtener_clases para obtener la lista total y final de materias a agendar.
- `maestros_disponibles(Cuentas)`: Identifica a los maestros únicos y les asigna un límite de disponibilidad. Inicializa a cada profesor con un máximo de 4 turnos disponibles (4 turnos x 2 horas = 8 horas diarias de límite).
- `asignar_maestros(ListaClases, Cuentas, Asignaciones)`: Toma la lista de materias e intenta emparejar cada una con un maestro capaz de impartirla. Simultáneamente, decrementa el contador de horas disponibles del maestro, asegurando por inferencia lógica que ninguno sobrepase el límite de 8 horas.
- `pad_clases(Clases, NumAulas, ClasesAjustadas)`: Si el total de clases a impartir es menor que la capacidad total de la escuela (Aulas x 6 turnos), este método rellena los espacios vacíos con objetos de tipo clase(libre, libre).

### 3. Restricciones y Agrupación Espacio-Temporal

- `conflict(Maestro1, Maestro2)`: Predicado que falla (o detecta conflicto) si dos maestros coinciden en un mismo bloque horario, omitiendo los turnos libres.
- `iniciar_historial(N, Historial)`: Crea una lista de listas vacías, de tamaño igual al número de aulas. Sirve para llevar un registro individual de las materias impartidas en cada aula durante el día y así evitar repeticiones.
- `seleccionar_distintos_h(Clases, N, Turno, Restantes, HistViejo, HistNuevo)`: Selecciona `N` clases de la lista general para conformar un solo turno horario (ej. todas las clases de las 7:00 AM). Emplea `conflict` para asegurar que ningún maestro esté repetido en ese bloque. Adicionalmente, verifica el `Historial` para garantizar que la materia asignada no haya sido impartida previamente en la misma aula en turnos anteriores del día. Al final, devuelve el historial actualizado (`HistNuevo`).
- `agrupar_en_turnos(Clases, NumAulas, Turnos)` (y `agrupar_en_turnos_h`): Encargados de ejecutar `seleccionar_distintos_h` 6 veces consecutivas para dividir la lista completa de clases en los 6 turnos diarios estipulados (T1 a T6), pasando el estado del historial como dependencia.
- `generar_aulas(N, Codigo, Aulas)`: Genera una lista de identificadores para las aulas utilizadas. Se vale del código ASCII (comenzando en 97 correspondiente a 'a') para devolver una lista como [a, b, c...] dependiendo del número de aulas calculadas que se necesitan.

### 4. Etiquetado

- `etiquetar_horario(Grupos, IdsTurnos, Aulas, HorarioFinal)` y `etiquetar_grupo/4`: Toman los bloques generados y los transforman en una estructura de datos más rica y formal: asignacion(Turno, Aula, Maestro, Materia). Esto asocia definitivamente cada clase validada a una coordenada de tiempo y espacio.

### 5. Salida, Formato y Persistencia

- `generar/0`: El método orquestador. Llama en secuencia a todas las reglas anteriores: calcula aulas necesarias, procesa datos, aplica restricciones, formatea la salida, la muestra en la consola y la guarda en un archivo.
- `mostrar_horario/2`, `mostrar_aulas/2`, `imprimir_aula/2`, `imprimir_celda/3`: Conjunto de reglas diseñadas puramente para la interfaz de usuario en la consola. Recorren la lista de asignaciones y dibujan una cuadrícula ASCII de "Lunes a Viernes", colocando guiones en los turnos libres y el formato "Maestro, Materia" en las celdas ocupadas.
- `salvar_horario(Archivo, Horario)`: Abre (o crea) un archivo de texto en disco y escribe la estructura completa del horario como un hecho o lista válida de Prolog terminada en punto.
- `cargar_horario(Archivo)`: Lee el término almacenado en el archivo de texto y lo envía directamente al método de formateo (mostrar_horario) para visualizarlo sin tener que calcularlo nuevamente.
- `limpiar_datos/0`: Utiliza el predicado retractall para vaciar dinámicamente la memoria lógica del programa borrando todos los hechos imparte/2 y requiere/2. Ideal para preparar el entorno antes de ingresar los datos de una nueva secundaria.