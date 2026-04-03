% ==========================================
% PROGRAMACIÓN DE HORARIO SEMESTRAL
% ==========================================

% Para que los hechos puedan eliminarse y modificarse dinamicamente según 
% los requerimientos al cambiar la cantidad de grupos.
:- dynamic imparte/2.
:- dynamic requiere/2.

% ------------------------------------------
% BASE DE HECHOS (DATOS DE ENTRADA)
% ------------------------------------------

% Maestros y las asignaturas que pueden impartir
imparte(audeves, redes).
imparte(audeves, redes_2).
imparte(cancela, ia).
imparte(cancela, io).
imparte(cancela, simulacion).
imparte(cecena, tesebada).
imparte(cecena, io).
imparte(cecena, redes_2).
imparte(nevarez, poo).
imparte(nevarez, simulacion).
imparte(nevarez, tesebada).
imparte(mosqueda, plf).
imparte(mosqueda, daad).
imparte(mosqueda, tesebada).
imparte(villa, bdd).
imparte(villa, iso).
imparte(villa, simulacion).

% Asignaturas y la cantidad de grupos/clases semanales necesarias
% Cada grupo representa una planificación diferente
requiere(io, 3).
requiere(tesebada, 2).
requiere(ia, 2).
requiere(plf, 1).
requiere(bdd, 3).
requiere(redes, 2).
requiere(redes_2, 4).
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
% no imparta mas de 8 horas diarias (4 turnos de 2h)[cite: 13].
maestros_disponibles(Cuentas) :-
    setof(M, Mat^imparte(M, Mat), Maestros),
    findall((Maestro, 4), member(Maestro, Maestros), Cuentas).

% FASE 1: Asigna un maestro disponible a cada clase respetando la carga maxima.
asignar_maestros([], _, []).
asignar_maestros([M|Ms], Cuentas, [clase(M, Maestro)|Asignaciones]) :-
    imparte(Maestro, M),
    select((Maestro, N), Cuentas, Resto),
    N > 0, % Verifica que no haya sobrepasado sus 8 horas.
    N1 is N - 1,
    asignar_maestros(Ms, [(Maestro, N1)|Resto], Asignaciones).

% Si la cantidad de clases no llena todas las aulas en todos los turnos, rellena con libres.
pad_clases(Clases, NumAulas, ClasesAjustadas) :-
    length(Clases, L),
    Faltantes is (NumAulas * 6) - L,
    repetir(clase(libre, libre), Faltantes, Libres),
    append(Clases, Libres, ClasesAjustadas).

% Evalúa si dos maestros causan un empalme en el mismo horario.
conflict(Maestro1, Maestro2) :-
    Maestro1 \= libre,
    Maestro1 == Maestro2.

% Selecciona 'N' clases distintas para un mismo turno evitando empalme de maestros[cite: 11].
% Esto garantiza indirectamente que a una asignatura no se le asigne mas de una 
% clase al mismo grupo en un día, ya que solo hay 1 instancia por grupo al día[cite: 12].
seleccionar_distintos(Clases, 0, [], Clases) :- !.
seleccionar_distintos(Clases, N, [C|TurnoResto], Restantes) :-
    N > 0,
    N1 is N - 1,
    seleccionar_distintos(Clases, N1, TurnoResto, TempRestantes),
    select(C, TempRestantes, Restantes),
    C = clase(_, Maestro),
    \+ (member(clase(_, M2), TurnoResto), conflict(Maestro, M2)).

% Agrupa la lista de clases en bloques del tamaño de aulas disponibles para los 6 turnos.
agrupar_en_turnos([], _, []).
agrupar_en_turnos(Clases, NumAulas, [Turno | RestoTurnos]) :-
    seleccionar_distintos(Clases, NumAulas, Turno, ClasesRestantes),
    agrupar_en_turnos(ClasesRestantes, NumAulas, RestoTurnos).

% Genera identificadores de aulas dinamicos (a, b, c...)
generar_aulas(0, _, []) :- !.
generar_aulas(N, Codigo, [Letra|Resto]) :-
    N > 0,
    char_code(Letra, Codigo),
    N1 is N - 1,
    CodigoSig is Codigo + 1,
    generar_aulas(N1, CodigoSig, Resto).

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
    todas_las_clases(Clases),
    length(Clases, L),
    NumAulas is ceiling(L / 6),
    generar_aulas(NumAulas, 97, Aulas), % 97 es el código ASCII para 'a'
    maestros_disponibles(Cuentas),
    asignar_maestros(Clases, Cuentas, ClasesAsignadas),
    pad_clases(ClasesAsignadas, NumAulas, ClasesAjustadas),
    % Turnos típicos solicitados [cite: 8, 9]
    Turnos = [t1, t2, t3, t4, t5, t6],
    agrupar_en_turnos(ClasesAjustadas, NumAulas, Grupos),
    etiquetar_horario(Grupos, Turnos, Aulas, Horario),
    mostrar_horario(Horario, Aulas),
    salvar_horario('horario_salvado.txt', Horario),
    nl, writeln('-> Planificacion guardada en "horario_salvado.txt" exitosamente.').

mostrar_horario(Horario, Aulas) :-
    nl, writeln('=== PLANIFICACION DE UNA SEMANA TIPICA ==='),
    % Se asume el mismo horario de lunes a viernes [cite: 4, 17]
    writeln('Dias: Lunes a Viernes'),
    writeln('-----------------------------------------------------------------------------------------------------'),
    writeln('Aula | 7:00 (T1)    | 9:00 (T2)    | 11:00 (T3)   | 13:00 (T4)   | 15:00 (T5)   | 17:00 (T6)   '),
    writeln('-----------------------------------------------------------------------------------------------------'),
    mostrar_aulas(Aulas, Horario),
    writeln('-----------------------------------------------------------------------------------------------------').

mostrar_aulas([], _).
mostrar_aulas([Aula|Resto], Horario) :-
    imprimir_aula(Aula, Horario),
    mostrar_aulas(Resto, Horario).

imprimir_aula(Aula, Horario) :-
    upcase_atom(Aula, AulaUpper),
    format('  ~w  |', [AulaUpper]),
    imprimir_celda(t1, Aula, Horario),
    imprimir_celda(t2, Aula, Horario),
    imprimir_celda(t3, Aula, Horario),
    imprimir_celda(t4, Aula, Horario),
    imprimir_celda(t5, Aula, Horario),
    imprimir_celda(t6, Aula, Horario),
    nl.

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
    nl, writeln('=== HORARIO CARGADO DESDE ARCHIVO ==='),
    mostrar_horario(Horario, Aulas).

% Elimina la información definida según lo requerido 
limpiar_datos :-
    retractall(imparte(_, _)),
    retractall(requiere(_, _)),
    writeln('Planificacion, maestros definidos y requerimientos han sido eliminados.').