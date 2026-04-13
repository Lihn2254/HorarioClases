# Generador de Horarios Escolares en Prolog

## Descripción General

Este programa está desarrollado en Prolog y tiene como objetivo automatizar la planificación de horarios semestrales para una escuela. Dado que todas las semanas del curso comparten la misma estructura, el sistema planifica una semana típica (de lunes a viernes) distribuyendo las cargas académicas en los horarios disponibles.

El algoritmo utiliza la resolución y el motor de inferencia lógica de Prolog para satisfacer un conjunto de restricciones operativas estrictas:

- Asigna profesores a las materias que están capacitados para impartir.
- Limita la carga laboral de los profesores a un máximo de 8 horas diarias (equivalente a 4 turnos de 2 horas).
- Evita empalmes, asegurando que un profesor no imparta más de una clase a la misma hora o turno.
- Restringe la impartición de materias a un máximo de una clase por día para el mismo grupo.

El sistema también cuenta con persistencia de datos básica (guardar y cargar en un archivo de texto) y la capacidad de limpiar la base de hechos dinámicamente para procesar nuevas configuraciones.

## Ejecución del Programa

Para ejecutar este proyecto, necesitas un intérprete de Prolog como SWI-Prolog.

Carga el código fuente en el intérprete:

```prolog
?- [main].
```

(asegúrate de que el archivo se llame main.pl).

Para iniciar la generación del horario y visualizarlo, primero debes cargar los requerimientos desde el archivo de texto y luego ejecutar la regla principal:

```prolog
?- cargar_requerimientos('req_horario.txt').
?- generar.
```

Para cargar un horario previamente guardado:

```prolog
?- cargar_horario('horario.txt').
```

Para reiniciar el estado y limpiar la base de datos de profesores y requerimientos:

```prolog
?- limpiar_datos.
```