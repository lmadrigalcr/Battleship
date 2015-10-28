%% :- module(battleship, []).
:- use_module(library(clpfd)).
:- use_module(filereader).

%%%%%%%%%%%
%% FACTS %%
%%%%%%%%%%%

%% The size of each type of ship.

sizeOf(aircraft, 5).
sizeOf(battleship, 4).
sizeOf(cruiser, 3).
sizeOf(destroyer, 2).
sizeOf(submarine, 1).

%% The amount of each type of ship in the board.

amountOf(aircraft, 1).
amountOf(battleship, 1).
amountOf(cruiser, 1).
amountOf(destroyer, 3).
amountOf(submarine, 4).

%% The number used in the board to represent each ship.

indexOf(aircraft, 1).
indexOf(battleship, 2).
indexOf(cruiser, 3).
indexOf(destroyer, 4).
indexOf(submarine, 5).

% A sample boards.

my_board([
    [4,0,0,0,0,0,0,3,3,3],
    [4,0,0,0,0,0,0,0,5,0],
    [0,0,0,0,1,0,0,0,0,0],
    [0,0,0,0,1,0,0,0,4,4],
    [0,0,0,0,1,0,0,0,0,0],
    [0,5,0,0,1,0,0,0,0,0],
    [0,0,0,0,1,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,4,4],
    [0,2,2,2,2,0,0,0,0,0],
    [0,0,5,0,0,0,0,0,0,5]
]).

clear_board([
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0]
]).

%%%%%%%%%%%%%%%%%%
%% HELPER RULES %%
%%%%%%%%%%%%%%%%%%

prompt(Message, Input) :-
  write(Message),
  read(Input).

print_matrix([]).

print_matrix([H|T]) :-
     write(H),
     nl,
     print_matrix(T).

update_list(List, Index, Element, Result) :-
     update_list_aux(Index, [], Element, List, Result).

update_list_aux(0, H, E, [_|T], Result) :-
     L2 = [E|T],
     append(H, L2, Result), !.

update_list_aux(I, H, E, [E1|T], Result) :-
     I2 is I - 1,
     append(H, [E1], L2),
     update_list_aux(I2, L2, E, T, Result).

update_matrix(Matrix, Row, Col, Element, Result) :-
    update_matrix_aux(Row, Col, [], Matrix, Element, Result).

update_matrix_aux(0, Col, [], [H|T], Element, Result) :-
    update_list(H, Col, Element, H2),
    Result = [H2|T],
    !.

update_matrix_aux(0, Col, L, [H|T], Element, Result) :-
    update_list(H, Col, Element, H2),
    M2 = [H2|T],
    append(L, M2, Result), !.

update_matrix_aux(Row, Col, L, [H|T], Element, Result) :-
    Row2 is Row - 1,
    append(L, [H], M2),
    update_matrix_aux(Row2, Col, M2, T, Element, Result).

row_at(Board, X, Row) :-
  nth0(X, Board, Row).

column_at(Y, Row, Cell) :-
  nth0(Y, Row, Cell).

count([], _, 0).

count([X|T], X, C) :-
    count(T, X, C2),
    C is C2 + 1.

count([H|T], X, C) :-
    H \= X,
    count(T, X, C).

count_matrix([], _, 0).

count_matrix([H|T], X, C) :-
    count_matrix(T, X, C2),
    count(H, X, C3),
    C is C2 + C3.

sum_to_list([], _, []).

sum_to_list([H1|T1], E, [H2|T2]) :-
    H1 < 0,
    !,
    sum_to_list(T1, E, T2),
    H2 is 0.

sum_to_list([H1|T1], E, [H2|T2]) :-
    sum_to_list(T1, E, T2),
    H2 is H1 + E.

sum_to_matrix([], [], []).

sum_to_matrix([H1|T1], [H2|T2], [H3|T3]) :-
    sum_to_matrix(T1, T2, T3),
    sum_to_list(H1, H2, H3).

sum_matrix(M1, M2, M3) :-
    maplist(maplist(plus), M1, M2, M3).

%%%%%%%%%%%%%%%%
%% MAIN RULES %%
%%%%%%%%%%%%%%%%

print_welcome :-
    nl, write('Battleship Prolog'), nl,
    write('================='), nl, nl,
    write('Instrucciones:'), nl,
    write(' 1. Durante su turno el programa le preguntará la celda a la cual desea atacar,'), nl,
    write('    ingrese primero la fila y luego la columna. A continuación el programa evaluará'), nl,
    write('    su jugada y le contestará hit o miss.'), nl,
    write(' 2. Durante el turno del programa, este le indicará la celda a la cual esta atacando,'), nl,
    write('    seguidamente usted deberá evaluar la jugada y contestar hit o miss.'), nl,
    write(' 3. El juego termina cuando se hayan hundido todos los barcos de alguno de los jugadores.'), nl, nl.

prompt_coordinates(X, Y) :-
  prompt('Fila: ', X),
  prompt('Columna: ', Y).

% ship_at/3
% ship_at(B, X, Y)
% True if B[X][Y] != 0

ship_at(Board, X, Y) :-
    row_at(Board, X, Row),
    column_at(Y, Row, Cell),
    Cell \= 0.

% show_evaluation/4
% recieve_evaluation(B1, X, Y, B2)
% Write miss if B[X][Y] == 0, else write hit.

show_evaluation(Board, X, Y, Result) :-
    ship_at(Board, X, Y),
    update_matrix(Board, X, Y, -1, Result),
    write('Evaluación: hit.'), nl, nl, !.

show_evaluation(Board, _, _, Board) :-
    write('Evaluación: miss.'), nl, nl.

% process_evaluation/5
% recieve_evaluation(B1, X, Y, Eval, B2)
% B2 is the modified board B1 after the evaluated attack.

replace([_|T], 0, X, [X|T]).

replace([H|T], I, X, [H|R]) :-
    I > -1,
    NI is I-1,
    replace(T, NI, X, R),
    !.

replace(L, _, _, L).

substract_at(List, Index, Result) :-
    nth0(Index, List, E),
    E2 is E - 1,
    replace(List, Index, E2, Result), !.

process_evaluation(Board, Rows, Cols, X, Y, hit, Board2, Rows2, Cols2) :-
    update_matrix(Board, X, Y, -1, Board2),
    substract_at(Rows, X, Rows2),
    substract_at(Cols, Y, Cols2),
    !.

process_evaluation(Board, Rows, Cols, X, Y, miss, Board2, Rows, Cols) :-
    update_matrix(Board, X, Y, -2, Board2), !.

process_evaluation(Board, Rows, Cols, X, Y, _, Board2, Rows2, Cols2) :-
    write('Entrada incorrecta. Ingrese hit o miss.'), nl,
    recieve_evaluation(Board, Rows, Cols, X, Y, Board2, Rows2, Cols2).

% attack/2
% attack(X, Y)
% Print the attack coordinates to the user.

attack(X, Y) :-
    write('Fila: '),
    write(X),
    write('.'), nl,
    write('Columna: '),
    write(Y),
    write('.'), nl.

% recieve_evaluation/4
% recieve_evaluation(B1, X, Y, B2)
% Read the user evaluation and set B2 to the modified B1 board.

recieve_evaluation(Board, Rows, Cols, X, Y, Board2, Rows2, Cols2) :-
    attack(X, Y),
    write('Evaluación: '),
    read(Eval), nl,
    process_evaluation(Board, Rows, Cols, X, Y, Eval, Board2, Rows2, Cols2).

increment(List, Index, Result) :-
    nth0(Index, List, E),
    E >= 0,
    E2 is E + 10,
    replace(List, Index, E2, Result), !.

increment(List, _, List).

increment_adyacents(L, I, R) :-
    I2 is I - 1,
    I3 is I + 1,
    increment(L, I2, L2),
    increment(L2, I3, R).

adjust_adyacent_row(L1, L2) :-
    adjust_adyacent_row_aux(L1, L1, L2, 0).

adjust_adyacent_row_aux([], L, L, _).

adjust_adyacent_row_aux([-1|T], L1, L2, I) :-
    increment_adyacents(L1, I, L3),
    I2 is I + 1,
    adjust_adyacent_row_aux(T, L3, L2, I2), !.

adjust_adyacent_row_aux([_|T], L1, L2, I) :-
    I2 is I + 1,
    adjust_adyacent_row_aux(T, L1, L2, I2), !.

adjust_adyacent_board([], []).

adjust_adyacent_board([H1|T1], [H2|T2]) :-
    adjust_adyacent_board(T1, T2),
    adjust_adyacent_row(H1, H2).

probability_matrix(Board, Rows, Cols, Result) :-
    transpose(Board, Transposed),
    adjust_adyacent_board(Board, Board2),
    adjust_adyacent_board(Transposed, Transposed2),
    sum_to_matrix(Board2, Rows, Board3),
    sum_to_matrix(Transposed2, Cols, Transposed3),
    transpose(Transposed3, Board4),
    sum_matrix(Board3, Board4, Result).

max_list_index(L, I) :-
    max_list(L, X),
    nth0(I, L, X), !.

max_matrix_index(M, I, J) :-
    max_matrix_index_aux(M, I, J, 0, _).

max_matrix_index_aux([H], I, J, R, E) :-
    max_list(H, X),
    nth0(J, H, X),
    I is R,
    E is X,
    !.

max_matrix_index_aux([H|T], I, J, R, E) :-
    R2 is R + 1,
    max_matrix_index_aux(T, _, _, R2, E2),
    max_list(H, X),
    X > E2,
    nth0(J, H, X),
    I is R,
    E is X,
    !.

max_matrix_index_aux([_|T], I, J, R, E) :-
    R2 is R + 1,
    max_matrix_index_aux(T, I, J, R2, E).

check :-
    clear_board(B),
    probability_matrix(B, [2, 5, 1, 0, 3, 2, 1, 2, 4, 2], [2, 5, 0, 2, 2, 5, 1, 1, 2, 2], X),
    print_matrix(X),
    max_matrix_index(X, I, J),
    attack(I, J).

% attack_coordinates/5
% attack_coordinates(B, R, C, X, Y)
% Get the attack coordinates on the opponent board.

attack_coordinates(Board, Rows, Cols, X, Y) :-
    probability_matrix(Board, Rows, Cols, M),
    max_matrix_index(M, X, Y).

% all_sunk/3
% all_sunk(B)
% Check if all ship in the board are sunk by counting the number if cells with a value -1 (sunk value).
% If the count sum 22 (number of ship cells in the board) return true.

all_sunk(Board) :-
    count_matrix(Board, -1, X),
    X = 22.

% check_board/2
% check_board(B, M)
% Print a message if all ships in the board are sunk.

check_board(Board, Message) :-
    all_sunk(Board),
    write(Message),
    nl, !, fail.

check_board(_, _).

% step/2
% step(B1, B2)
% B1 is the IA board, B2 is the User board.

step(B1, B2, R, C) :-
    prompt_coordinates(X1, Y1),
    show_evaluation(B1, X1, Y1, B3),
    check_board(B3, 'Felicidades. Ha ganado.'),
    attack_coordinates(B2, R, C, X2, Y2),
    recieve_evaluation(B2, R, C, X2, Y2, B4, R2, C2),
    check_board(B4, 'Lo siento. Ha perdido.'),
    step(B3, B4, R2, C2).

start :-
    print_welcome,
    my_board(B1),
    clear_board(B2),
    get_rows(R),
    get_cols(C),
    step(B1, B2, R, C).
