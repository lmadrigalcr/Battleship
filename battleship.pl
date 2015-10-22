%% :- module(battleship, []).

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

opponent_board([
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

prompt_number(Message, Number) :-
  write(Message),
  read(Number).

prompt_coordinates(X, Y) :-
  prompt_number('Fila: ', X),
  prompt_number('Columna: ', Y).

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

%%%%%%%%%%%%%%%%
%% MAIN RULES %%
%%%%%%%%%%%%%%%%

% ship_at/3
% ship_at(B, X, Y)
% True if B[X][Y] != 0

ship_at(Board, X, Y) :-
    row_at(Board, X, Row),
    column_at(Y, Row, Cell),
    Cell \= 0.

% show_evaluation/3
% recieve_evaluation(B, X, Y)
% Write miss if B[X][Y] == 0, else write hit.

show_evaluation(Board, X, Y) :-
    ship_at(Board, X, Y),
    write('hit'), nl, nl, !.

show_evaluation(_, _, _) :-
    write('miss'), nl, nl.

% process_evaluation/5
% recieve_evaluation(B1, X, Y, Eval, B2)
% B2 is the modified board B1 after the evaluated attack.

process_evaluation(Board, X, Y, hit, Result) :-
    update_matrix(Board, X, Y, '*', Result),
    !.

process_evaluation(Board, X, Y, miss, Result) :-
    update_matrix(Board, X, Y, '-', Result),
    !.

process_evaluation(Board, X, Y, _, Result) :-
    write('Entrada incorrecta. Ingrese hit o miss.'), nl,
    recieve_evaluation(Board, X, Y, Result).

% recieve_evaluation/4
% recieve_evaluation(B1, X, Y, B2)
% Read the user evaluation and set B2 to the modified B1 board.

recieve_evaluation(Board, X, Y, Result) :-
    write('Evaluación: '),
    read(Eval), nl,
    process_evaluation(Board, X, Y, Eval, Result).

% attack_coordinates/3
% attack_coordinates(Board, X, Y)
% Get the attack coordinates on the opponent board.

attack_coordinates(Board, X, Y) :-
    random_between(0, 9, X),
    random_between(0, 9, Y).

% attack/2
% attack(X, Y)
% Print the attack coordinates to the user.

attack(X, Y) :-
    write('('),
    write(X),
    write(', '),
    write(Y),
    write(')'),
    nl.

% step/2
% step(B1, B2)
% B1 is the IA board, B2 is the User board.

step(B1, B2) :-
    prompt_coordinates(X1, Y1),
    show_evaluation(B1, X1, Y1),
    attack_coordinates(B2, X2, Y2),
    attack(X2, Y2),
    recieve_evaluation(B2, X2, Y2, B3),
    step(B1, B3).

start :-
    my_board(B1),
    opponent_board(B2),
    step(B1, B2).
