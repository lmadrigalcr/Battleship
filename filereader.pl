:- module(filereader, [get_board/2, get_opponent_data/3]).

main(Lines, FileName) :-
    open(FileName, read, Str),
    read_file(Str,Lines),
    close(Str),
    !.

read_file(end_of_file,_ ):- !.

read_file(Stream,[]) :-
    at_end_of_stream(Stream).

read_file(Stream,[X|L]) :-
    \+at_end_of_stream(Stream),
    read(Stream,X),
    read_file(Stream,L).

get_board(File, B):-
  main(Xs, File),
  parse_board(Xs,B).

parse_board([],[]).

parse_board([H1|T1], [H2|T2]) :-
  parse_board(T1, T2),
  convert(H1,H2).

get_opponent_data(File, R, C) :-
    get_rows(File, R),
    get_cols(File, C).

get_cols_aux([_,H|_], H).

get_cols(File, C) :-
  main(Xs, File),
  get_cols_aux(Xs, Ys),
  convert(Ys, C).

get_rows_aux([H|_], H).

get_rows(File, R) :-
  main(Xs, File),
  get_rows_aux(Xs, Ys),
  convert(Ys, R).

convert([],[]).

convert([H1|T1], [H2|T2]) :-
  convert(T1, T2),
  char_number(H1,H2).

char_number(X, R) :- R is X-48.
