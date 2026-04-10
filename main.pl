% ==========================================
% PROGRAMACIÓN DE HORARIO SEMESTRAL
% ==========================================

% Para cargar la librería necesaria para el límite de tiempo
:- use_module(library(time)).

% Para que los hechos puedan eliminarse y modificarse dinamicamente según 
% los requerimientos al cambiar la cantidad de grupos.
:- dynamic imparte/2.
:- dynamic requiere/2.
:- dynamic numero_turnos/1.

% ------------------------------------------
% BASE DE HECHOS (DATOS DE ENTRADA)
% ------------------------------------------

% Número de turnos al día
numero_turnos(6).

% Maestros y las asignaturas que pueden impartir
imparte(audev, rds).
imparte(audev, rds2).
imparte(cancel, ia).
imparte(cancel, io).
imparte(cancel, sim).
imparte(cecena, tbd).
imparte(cecena, io).
imparte(cecena, rds2).
imparte(nevarez, poo).
imparte(nevarez, sim).
imparte(nevarez, tbd).
imparte(mosqued, plf).
imparte(mosqued, daad).
imparte(mosqued, tbd).
imparte(villa, bdd).
imparte(villa, iso).
imparte(villa, sim).

% Asignaturas y la cantidad de grupos/clases semanales necesarias
% Cada grupo representa una planificación diferente
requiere(io, 3).
requiere(tbd, 2).
requiere(ia, 2).
requiere(plf, 1).
requiere(bdd, 3).
requiere(rds, 2).
requiere(rds2, 4).
requiere(poo, 4).
requiere(daad, 2).
requiere(iso, 1).

% ------------------------------------------
% LÓGICA DE GENERACIÓN Y RESTRICCIONES
% ------------------------------------------

% Utilidad para replicar materias según los grupos que requieren.
repetir(_, 0, []) :- !.
repetir(M, N, [M|R]) :- N > 0, N1 is N - 1, repetir(M, N1, R).

% Genera una lista plana con todas las clases que se deben programar.
obtener_clases([], []).
obtener_clases([(M, N)|T], Lista) :-
    repetir(M, N, L1),
    obtener_clases(T, L2),
    append(L1, L2, Lista).

todas_las_clases(Lista) :-
    findall((M, N), requiere(M, N), Req),
    obtener_clases(Req, Lista).

% Determina la disponibilidad de maestros asegurando que un maestro 
% no imparta mas de 8 horas diarias (4 turnos de 2h).
turnos_maestros(Cuentas) :-
    setof(M, Mat^imparte(M, Mat), Maestros),
    findall((Maestro, 4), member(Maestro, Maestros), Cuentas).

% FASE 1: Asigna un maestro disponible a cada clase respetando la carga maxima.
asignar_maestros([], _, []).
asignar_maestros([M|Ms], Cuentas, [clase(M, Maestro)|Asignaciones]) :-
    imparte(Maestro, M), % Obtener maestros que impartan la materia
    select((Maestro, N), Cuentas, Resto),       
    N > 0, % Verifica que no haya sobrepasado sus 8 horas.
    N1 is N - 1,
    asignar_maestros(Ms, [(Maestro, N1)|Resto], Asignaciones).

% Si la cantidad de clases no llena todas las aulas en todos los turnos, rellena con libres.
rellenar_clases_libres(ClasesAsignadas, NumAulas, NumTurnos, ClasesAjustadas) :-
    length(ClasesAsignadas, L),
    Faltantes is (NumAulas * NumTurnos) - L, % NumAulas * No. de turnos = Total de turnos a cubrir en el día
    repetir(clase(libre, libre), Faltantes, Libres),
    append(ClasesAsignadas, Libres, ClasesAjustadas).

% Evalúa si dos maestros causan un empalme en el mismo horario.
conflict(Maestro1, Maestro2) :-
    Maestro1 \= libre,
    Maestro1 == Maestro2.

% Agrupa la lista de clases en bloques del tamaño de aulas disponibles para los 6 turnos,
% validando que una misma materia no se imparta más de una vez al día para el mismo grupo (aula).
agrupar_en_turnos(ClasesAjustadas, NumAulas, Grupos) :-
    iniciar_historial(NumAulas, Historial),
    agrupar_en_turnos_h(ClasesAjustadas, NumAulas, Historial, Grupos).

% Genera una lista de N listas vacías donde N = No. de aulas.
iniciar_historial(0, []) :- !.
iniciar_historial(N, [[]|R]) :-
    N > 0,
    N1 is N - 1,
    iniciar_historial(N1, R).

agrupar_en_turnos_h([], _, _, []). % Caso base: Se detiene cuando ya no quedan clases por asignar a un turno.
agrupar_en_turnos_h(Clases, NumAulas, Historial, [Turno | RestoTurnos]) :-
    seleccionar_distintos_h(Clases, NumAulas, Turno, ClasesRestantes, Historial, NuevoHistorial),
    agrupar_en_turnos_h(ClasesRestantes, NumAulas, NuevoHistorial, RestoTurnos).

% Caso base: Se detiene cuando ha sido generado el turno completo
% Importante -> TempRestantes en la llamada recursiva (véase abajo) es unificada con la lista completa de Clases
seleccionar_distintos_h(Clases, 0, [], Clases, [], []) :- !.

% Clases: Lista de hechos clase(Materia, Maestro) o clase(libre, libre)
% NumAulas: No. de aulas (ej. Aulas = ['a', 'b', 'c', 'd'], entonces NumAulas = 4)
% [C | TurnoResto]: Variable a unificar (variable de salida)
% Restantes: Variable a unificar (variable de salida)
% [Hist | HistResto]: Historial descompuesto, donde Hist es el primer elemento de Historial, es decir, una lista
%                     con las clases impartidas a un aula específica a lo largo de todos los turnos
% [[Mat|Hist]|NuevoHistResto]: Variable a unificar (variable de salida)
seleccionar_distintos_h(Clases, NumAulas, [ClaseActual|TurnoResto], Restantes, [Hist|HistResto], [[Mat|Hist]|NuevoHistResto]) :-
    NumAulas > 0, % Verifica si aún quedan aulas por asignar en el turno actual
    NumAulas1 is NumAulas - 1, % Contador descendiente
    % Primero hace la llamada recursiva antes de hacer cualquier validación,
    % por lo tanto, las validaciones se haran desde NumAulas = 1 hasta NumAulas = N, de manera ascendiente
    % a.k.a. recorre las aulas desde la última hasta la primera
    seleccionar_distintos_h(Clases, NumAulas1, TurnoResto, TempRestantes, HistResto, NuevoHistResto),
    % Extrae una clase "ClaseActual" de la lista de clases no asignadas "TempRestantes", dejando el resto en la lista "Restante"
    select(ClaseActual, TempRestantes, Restantes),
    ClaseActual = clase(Mat, Maestro), % A partir de la clase seleccionda, extrae la materia "Mat" y el maestro que la imparte.
    % Verifica si la materia es "libre" o si la materia no pertenece al historial del aula actual, 
    % es decir, si la materia no ha sido impartida aún a dicha aula
    (Mat == libre ; \+ member(Mat, Hist)),
    % Extrae uno por uno los maestros existentes dentro de TurnoResto, 
    % que contiene las clases ya asignadas a otras aulas en el turno actual,
    % y verifica que el maestro de la clase seleccionada "ClaseActual" no se encuentre ya en la lista
    \+ (member(clase(_, M2), TurnoResto), conflict(Maestro, M2)).

% Genera identificadores de aulas dinamicos (a, b, c...)
generar_aulas(0, _, []) :- !.
generar_aulas(N, Codigo, [Letra|Resto]) :-
    N > 0,
    char_code(Letra, Codigo),
    N1 is N - 1,
    CodigoSig is Codigo + 1,
    generar_aulas(N1, CodigoSig, Resto).

% Genera la lista de turnos (t1, t2, t3...)
generar_turnos(NumTurnos, Turnos) :-
    generar_turnos_aux(1, NumTurnos, Turnos).

generar_turnos_aux(Actual, Max, []) :- Actual > Max, !.
generar_turnos_aux(Actual, Max, [Turno|Resto]) :-
    Actual =< Max,
    atom_concat(t, Actual, Turno),
    Siguiente is Actual + 1,
    generar_turnos_aux(Siguiente, Max, Resto).

% FASE 2: Etiqueta cada agrupación con su Turno y Aula correspondiente.
etiquetar_horario([], [], _, []).
etiquetar_horario([Grupo | RestoGrupos], [IdTurno | RestoIds], Aulas, HorarioFinal) :-
    etiquetar_grupo(Grupo, IdTurno, Aulas, HorarioTurno),
    etiquetar_horario(RestoGrupos, RestoIds, Aulas, HorarioRestante),
    append(HorarioTurno, HorarioRestante, HorarioFinal).

etiquetar_grupo([], _, [], []).
etiquetar_grupo([clase(Materia, Maestro) | Resto], IdTurno, [IdAula | RestoAulas], [asignacion(IdTurno, IdAula, Maestro, Materia) | RestoAsignaciones]) :-
    etiquetar_grupo(Resto, IdTurno, RestoAulas, RestoAsignaciones).

% ------------------------------------------
% SALIDA, FORMATO Y GESTIÓN DE DATOS 
% ------------------------------------------

% Entry Point Principal: Orquesta la generación y muestra del horario.
generar :-
    todas_las_clases(Clases), % Obtiene una lista aplanada "Clases" de todas las clases a impartir (ej. [io, io, io, tbd, tbd, ia, ia, plf, bdd|…])
    length(Clases, L), % Obtiene el número total de clases a impartir "L"
    numero_turnos(NumTurnos), % Obtiene la cantidad de turnos definidos
    NumAulas is ceiling(L / NumTurnos), % Divide L entre el número total de turnos en el día y redondea el resultado hacia arriba para obtener el número de aulas necesarias "NumAulas"
    generar_aulas(NumAulas, 97, Aulas), % Genera una lista con las aulas generadas "Aulas", cada una representada por una letra, siendo la primera 'a' (ASCII 97)
    turnos_maestros(Cuentas), % Genera una lista de tuplas (Maestro, No. de turnos) llamada "Cuentas", con los maestros disponibles y el número de turnos máximo que pueden tener al día
    asignar_maestros(Clases, Cuentas, ClasesAsignadas), % Genera una lista de hechos de tipo clase(Materia, Maestro) llamada "ClasesAsignadas"
    % En caso de que las clases asignadas no sean suficientes para cubrir todos los turnos del día,
    % los turnos faltantes son agregados a como clase(libre, libre) a una nueva lista "ClasesAjustadas"
    rellenar_clases_libres(ClasesAsignadas, NumAulas, NumTurnos, ClasesAjustadas),
    % Turnos típicos solicitados generados dinámicamente
    generar_turnos(NumTurnos, Turnos),
    % Inicia la búsqueda con tiempo límite de 30 segundos
    catch(
        call_with_time_limit(30, (
            agrupar_en_turnos(ClasesAjustadas, NumAulas, Grupos),
            etiquetar_horario(Grupos, Turnos, Aulas, Horario),
            mostrar_horario(Horario, Aulas, Turnos),
            salvar_horario('horario_salvado.txt', Horario),
            nl, writeln('-> Planificacion guardada en "horario_salvado.txt" exitosamente.')
        )),
        time_limit_exceeded,
        (nl, writeln('Solucion no encontrada dentro del limite de tiempo.'))
    ).

mostrar_horario(Horario, Aulas, Turnos) :-
    nl, writeln('=== PLANIFICACION DE UNA SEMANA TIPICA ==='),
    % Se asume el mismo horario de lunes a viernes
    writeln('Dias: Lunes a Viernes'),
    writeln('-----------------------------------------------------------------------------------------------------'),
    % La cabecera será general ya que los turnos son dinámicos
    writeln('Aulas / Turnos'),
    writeln('-----------------------------------------------------------------------------------------------------'),
    mostrar_aulas(Aulas, Turnos, Horario),
    writeln('-----------------------------------------------------------------------------------------------------').

mostrar_aulas([], _, _).
mostrar_aulas([Aula|Resto], Turnos, Horario) :-
    imprimir_aula(Aula, Turnos, Horario),
    mostrar_aulas(Resto, Turnos, Horario).

imprimir_aula(Aula, Turnos, Horario) :-
    upcase_atom(Aula, AulaUpper),
    format('  ~w  |', [AulaUpper]),
    imprimir_celdas(Turnos, Aula, Horario),
    nl.

imprimir_celdas([], _, _).
imprimir_celdas([Turno|Resto], Aula, Horario) :-
    imprimir_celda(Turno, Aula, Horario),
    imprimir_celdas(Resto, Aula, Horario).

imprimir_celda(Turno, Aula, Horario) :-
    member(asignacion(Turno, Aula, Maestro, Materia), Horario),
    (   Maestro == libre ->
        format(' ~w \t|', ['-'])
    ;   format(' ~w, ~w \t|', [Maestro, Materia])
    ).

% Funciones de guardado y carga requeridas 
salvar_horario(Archivo, Horario) :-
    open(Archivo, write, Stream),
    write(Stream, Horario),
    write(Stream, '.'),
    close(Stream).

cargar_horario(Archivo) :-
    open(Archivo, read, Stream),
    read(Stream, Horario),
    close(Stream),
    setof(A, T^M^Mat^member(asignacion(T, A, M, Mat), Horario), Aulas),
    setof(T, A^M^Mat^member(asignacion(T, A, M, Mat), Horario), Turnos),
    nl, writeln('=== HORARIO CARGADO DESDE ARCHIVO ==='),
    mostrar_horario(Horario, Aulas, Turnos).

% Elimina la información definida según lo requerido 
limpiar_datos :-
    retractall(imparte(_, _)),
    retractall(requiere(_, _)),
    writeln('Planificacion, maestros definidos y requerimientos han sido eliminados.').