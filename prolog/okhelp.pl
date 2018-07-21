go :-
	see('util:util.hlp'),
	repeat,
	    read_a_line(Line),
	    parse_line(Line),
	seen.


%   read_a_line(Line)
%   reads the next line from the current input stream.
%   If there IS a next line, Line is unified with the characters
%   froim up, up to but excluding the closing newline (31) character.
%   If there is NOT a next line, Line is unified with 'end_of_file'.

read_a_line(Line) :-
	get0(Char),
	read_a_line(Char, Line).

read_a_line(26, end_of_file) :- !.
read_a_line(Other, Line) :-
	rest_of_line(Other, Line).

rest_of_line(31, []) :- !.
rest_of_line(Char, [Char|Line]) :-
	get0(NextChar),
	rest_of_line(NextChar, Line).


%   parse_line(Line)
%   takes a list of characters or the constant end_of_file and does
%   one of three things with it.
%   1.  If it is 'end_of_file', it succeeds.  In the final program
%   it will have to apologise for not having found the predicate you
%   want help for.
%   2.  If the line can be parsed as
%	<predicate name>[(<arguments>)] %<file>
%   it prints the predicate name, its arity (the number of commas plus
%   1 if there are parentheses, otherwise 0), and the file name.  In the
%   final program this will be used to decide whether it is the
%   predicate we are looking for, and if so what file to visit.
%   3.  Otherwise it is a blank line or a header line or some other bit of
%   junk which we ignore.  In cases 2 and 3 we FAIL, because it is used in 
%   a failure-driven loop.

parse_line(end_of_file) :- !.
parse_line(Line) :-
	help_line(Pred, Arity, File, Line, _),
	!,
	name(PredAtom, Pred),
	name(FileAtom, File),
	writef('%t/%t comes from %t.\n', [PredAtom,Arity,FileAtom]),
	fail.
parse_line(_) :-
	nl,
	fail.

%   help_line(Pred, Arity, File) has to parse a help line.
%   There are no leading spaces or tabs on one of these lines.
%   The predicate symbol is everything up to the first "(" or
%   layout character.  If there is no "(" the arity is 0.  If
%   there is a "(", the arity is the number of commas up to
%   the matching ")" plus 1.  In either case we then have to
%   skip to the "%", and the File is everything after that.

help_line(Pred, Arity, File) -->
	help_pred(Pred, HadPren),
	{   Pred \== []   },
	help_arity(HadPren, Arity),
	skip_string(37),
	help_file(File).


help_pred([], yes) -->
	"(", !.
help_pred([], no) -->
	[C], {C =< 32}, !.
help_pred([C|Cs], HadPren) -->
	[C],
	help_pred(Cs, HadPren).


help_file([C|Cs]) -->
	[C], {C > 32}, !,
	help_file(Cs).
help_file([]) --> [].


help_arity(no, 0) --> !.
help_arity(yes, N) -->
	help_arity(0, 1, N).

help_arity(Depth, SoFar, Arity) -->
	(   "'", !, skip_string(39), help_arity(Depth, SoFar, Arity)
	|   """",!, skip_string(34), help_arity(Depth, SoFar, Arity)
	|   "(", !, {E is Depth+1},  help_arity(E, SoFar, Arity)
	|   ")", {Depth = 0}, !, {Arity = SoFar}
	|   ")", !, {E is Depth-1},  help_arity(E, SoFar, Arity)
	|   ",", {Depth = 0}, !, {Next is SoFar+1}, help_arity(Depth, Next, Arity)
	|   [_], help_arity(Depth, SoFar, Arity)
	).

skip_string(C) --> [C], !.
skip_string(C) --> [_], skip_string(C).


