:- module(filereader, [get_board/1, get_rows/1, get_cols/1]).

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

get_board(B):-
  main(Xs,'my_board'),
  parse_board(Xs,B).

parse_board([],[]).
parse_board([H1|T1], [H2|T2]) :-
  parse_board(T1, T2),
  convert(H1,H2).

get_cols([_,H|_], H).
get_cols(C) :-
  main(Xs, 'opponent'),
  get_cols(Xs, Ys),
  convert(Ys, C).

get_rows([H|_], H).
get_rows(R) :-
  main(Xs, 'opponent'),
  get_rows(Xs, Ys),
  convert(Ys, R).

convert([],[]).
convert([H1|T1], [H2|T2]) :-
  convert(T1, T2),
  char_number(H1,H2).

char_number(X, R) :- R is X-48.
