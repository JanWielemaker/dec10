%   File   : COUNT.PL
%   Author : Richard A. O'Keefe
%   Updated: 4 August 1984
%   Purpose: Find out how big a file or program is.
%   Needs  : getfile/1 from UTIL:GETFIL.PL, give_help from UTIL:HELPER.PL,
%	     and try_hard_to_see/3 from UTIL:TRYSEE.PL.

%   This program is a re-implementation of Chris Mellish's clause counter,
%   which uses my 'try_hard_to_see' and 'help' mechanisms.  For information
%   on how to use the program, run it and type 'help' or .Help Util:Count
%   It has now been rehacked to live in ToolKit, so 'help' is redundant.

:- public
/*	help/0,			%  displays Mec:Count.Hlp		*/
	count/0.		%  top level

:- mode
	count_command(+,-),
	count_command(+,-,-),
	count,
	count(+,-,+,-),
	count(+,+,-,+,-),
/*	help,								*/
	load_goals(+,-,-),
	load_list(+,-,-),
	proceed(+,-,-),
	proceed(+,+,-,+,-),
	read_and_expand(-).


/*  help :- 								*/
/*	give_help(count, count).					*/


count :-
/*	abolish(noticed, 2),						*/
	count(0, C, 0, P),
	writef('%20L%5R clauses%4R predicates.\n',
		['Grand total:', C, P]).

count(Cold, Cnew, Pold, Pnew) :-
	getfile(File), !,
	count(File, Cold, Cnew, Pold, Pnew).
 
count('',   Cfin, Cfin, Pfin, Pfin) :- !.
count('?',  Cold, Cnew, Pold, Pnew) :-
	give_help(count, files), !,
	count(Cold, Cnew, Pold, Pnew).
count(File, Cold, Cnew, Pold, Pnew) :-
	proceed(File, C, P),
	Cmid is Cold+C,
	Pmid is Pold+P, !,
	count(Cmid, Cnew, Pmid, Pnew).


proceed(File, C, P) :-
	seeing(OldFile),
	try_hard_to_see(File, ['press','mec','util'], ['pl', 'cpl']), !,
	read_and_expand(Term),
	proceed(Term, 0, C, 0, P),
	seeing(FileName),
	seen,
	see(OldFile), !,
	writef('%20L%5R clauses%4R predicates.\n', [FileName, C, P]).
proceed(File, 0).


read_and_expand(Term) :-
	read(Read),
	(   var(Read), Term = true, !
	;   expand_term(Read, Term)
	).
 
 
proceed(end_of_file, Cfin, Cfin, Pfin, Pfin) :- !.
proceed(Term, Cold, Cnew, Pold, Pnew) :-
	count_command(Term, C, P),
	Cmid is Cold+C,
	Pmid is Pold+P,
	read_and_expand(Next), !,
	proceed(Next, Cmid, Cnew, Pmid, Pnew).
 
 
count_command(( :- Goals ), C, P) :- !,
	load_goals(Goals, C, P).
count_command(( ?- Goals ), C, P) :- !,
	load_goals(Goals, C, P).
count_command((Head:-Body), 1, P) :- !,
	count_command(Head, P).
count_command(Head, 1, P) :- !,
	count_command(Head, P).

count_command(Head, 1) :-
	functor(Head, F, N),
	\+ '$seen'(F, N), !,
	seeing(File),
	assertz('$seen'(F, N)),
	assertz('$defn'(F, N, File)).
count_command(Head, 0).
 
 
load_goals((G1,G2), C, P) :- !,
	load_goals(G1, C1, P1),
	load_goals(G2, C2, P2),
	C is C1+C2,
	P is P1+P2.
load_goals(compile(L), C, P) :- !,
	load_list(L, C, P).
load_goals([A|B], C, P) :- !,
	load_list([A|B], C, P).
load_goals(consult(L), C, P) :- !,
	load_list(L, C, P).
load_goals(reconsult(L), C, P) :- !,	% not quite right
	load_list(L, C, P).
load_goals(load(L), C, P) :- !,
	load_list(L, C, P).
load_goals(op(P,T,A), 0, 0) :- !,
	op(P, T, A).
load_goals(_, 0, 0).

 
load_list([File|Rest], C, P) :- !,
	load_list(File, C1, P1),
	load_list(Rest, C2, P2),
	C is C1+C2,
	P is P1+P2.
load_list([], 0, 0) :- !.
load_list(-File, C, P) :- !,	% not quite right
	proceed(File, C, P).
load_list(File, C, P) :-
	atom(File), !,
	proceed(File, C, P).
load_list(_, 0, 0).
 
