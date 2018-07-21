%   File   : DEPTH.PL
%   Author : R.A.O'Keefe
%   Updated: 12 March 1984
%   Purpose: Find or check the depth of a term.

/*  Many resolution-based theorem provers impose a Depth Bound on the
    terms they create.  Not the least of the reasons for this is to
    stop infinite loops.  This module provides two entry points:

	depth_of_term(Term, Depth)
	depth_bound(Term, Bound)

    depth_of_term calculates the depth of the term, using the definition
	depth(Var) = 0
	dpeth(Const) = 0
	depth(F(T1,...,Tn)) = 1+max(depth(T1),...,depth(Tn))

    Mostly, we couldn't care less what the depth of a term is, provided
    it is below some fixed bound.  depth_bound checks that the depth of
    the given term is below the bound (which is assumed to be an integer
    >= 1), without ever finding out what the depth actually is.
*/

:- public
	depth_bound/2,
	depth_of_term/2.

:- mode
	depth_bound(+, +),
	    depth_bound(+, +, +),
	depth_of_term(+, -),
	    depth_of_term(+, +, +, -).


depth_bound(Compound, Bound) :-
	nonvar(Compound),
	functor(Compound, _, Arity),
	Arity > 0,
	!,
	Bound > 0,		% this is the test!
	Limit is Bound-1,
	depth_bound(Arity, Compound, Limit).
depth_bound(_, _).


depth_bound(0, _, _) :- !.
depth_bound(N, Compound, Limit) :-
	arg(N, Compound, Arg),
	depth_bound(Arg, Limit),
	M is N-1, !,
	depth_bound(M, Compound, Limit).



depth_of_term(Compound, Depth) :-
	nonvar(Compound),
	functor(Compound, _, Arity),
	Arity > 0,
	!,
	depth_of_term(Arity, Compound, 0, ArgDepth),
	Depth is ArgDepth+1.
depth_of_term(_, 0).

depth_of_term(0, _, Depth, Depth) :- !.
depth_of_term(N, Compound, SoFar, Depth) :-
	arg(N, Compound, Arg),
	depth_of_term(Arg, ArgDepth),
	ArgDepth > SoFar,
	M is N-1,
	!,
	depth_of_term(M, Compound, ArgDepth, Depth).
depth_of_term(N, Compound, SoFar, Depth) :-
	M is N-1,
	depth_of_term(M, Compound, SoFar, Depth).


distfi.ex       482877785   124   0     100644  2061      `
%   File   : DISTFI.EX
%   Author : R.A.O'Keefe
%   Updated: 10 May 1984
%   Purpose: Load Util:Distfix.Pl and define some examples.

:- compile(['util:rdtok.pl', 'util:distfi.pl']).

:- distfixop(850, fx, [append,A,to,Z,giving,L], append(A,Z,L)),
   distfixop(850, fx, [remove,A,from,L,giving,Z], append(A,Z,L)),
   distfixop(700, xfy, [S,is,the,set,of,X,such,that,P], setof(X,P,S)),
   distfixop(700, xfy, [B,is,the,bag,of,X,such,that,P], bagof(X,P,B)),
   distfixop(850, fx, [apply,P,to,Args], apply(P,Args)),
   distfixop(850, fx, [compare,X,with,Y,giving,R], compare(R,X,Y)),
   distfixop(850, fx, [the,principal,functor,of,T,is,F,with,arity,N],
				functor(T,F,N)),
   distfixop(850, fx, [number,the,variables,of,X,starting,from,S,
			up,to,N], numbervars(X,S,N)),
   distfixop(850, fx, [make,X,ground], numbervars(X,0,_)),
   distfixop(850, fx, [unify,X,with,Y], X = Y),
   distfixop(700, xfx, [X,unifies,with,Y], X = Y),
   distfixop(700, xfx, [X,does,not,unify,with,Y], \=(X,Y)),
   distfixop(850, fx, [select,Elem,from,List,leaving,Rest],
			select(Elem,List,Rest)),
   distfixop(999, fy, [if,Test,then,True,else,False], (Test->True;False)),
   distfixop(999, fy, [if,Test,then,True], (Test->True;true)),
   distfixop(850, yfx, [X,for,all,Y], forall(Y,X)).


dconsult(File) :-
	(File == user ; exists(File)),
	seeing(Old),
	see(File),
	repeat,
	    read(Foo, Vars),
	    expand_term(Foo, Baz),
	    dconsult(Baz, Vars),
	!,
	seen,
	see(Old).

dconsult(end_of_file, _) :- !.
dconsult(:-(Cmd), _) :-
	(call(Cmd) ; ttyput(63), ttynl),
	!, fail.
dconsult(?-(Ques), []) :-
	(call(Ques), display(yes) ; display(no)),
	!, ttynl, fail.
dconsult(?-(Ques), Vars) :-
	(call(Ques), dvars(Vars) ; display(no), ttynl),
	!, fail.
dconsult(:-(H,B), _) :-
	assertz(:-(H,B)),
	!, fail.
dconsult(Ques, Vars) :-
	seeing(user), !,
	dconsult(?-(Ques), Vars).
dconsult(H, _) :-
	assertz(H),
	!, fail.

dvars([V=T|Vars]) :-
	display(V), display(' = '), print(T), nl, !,
	dvars(Vars).
dvars([]) :-
	display('more (y/n)? '), ttyflush,
	get0(C), ttyskip(31),
	C\/32 =\= "y".



