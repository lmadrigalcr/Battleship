main(FileName) :-
    open(FileName, read, Str),
    read_file(Str,Lines),
    close(Str),
    write(Lines), !.

read_file(end_of_file,_ ):- !.

read_file(Stream,[]) :-
    at_end_of_stream(Stream).

read_file(Stream,[X|L]) :-
    \+at_end_of_stream(Stream),
    read(Stream,X),
    read_file(Stream,L).
