%   File: Mec:PP.Pl	 Author: R.A.O'Keefe	   Updated: 28 July 82

%   		Prolog Pretty-Printer
%   For documentation, see the on-line helper file Mec:PP.Hlp

:- public
	(ca)/0, (ca)/1, (ca)/2,
	(cf)/0, (cf)/1, (cf)/2,
	(co)/0, (co)/1, (co)/2, (co)/3,
	(cp)/0, (cp)/1, (cp)/2,
	isCurrent/2, isCurrent/3, isCurrent/4,	%  just for setof
	(on)/2,
	(pp)/0, (pp)/1.

:- mode
	answer_List(+, +),
	ca, ca(+), ca(+, -),
	cf, cf(+), cf(+, -),
	co, co(+), co(+, -), co(+, +, +),
	cp, cp(+), cp(+, -),
	final_Check(+, +, +, +),
	isCurrent(+, ?), isCurrent(+, +, ?), isCurrent(+, +, +, ?),
	in_Range(+, +),
	match_wild(+, +),
	pp, pp(+),
	pp_conjunction(+, +, +, +),
	pp_disjunction(+, +, +, +),
	pp_explicit(+), pp_explicit(+, +),
	pp_head(+, +, +),
	pp_tail(+, +),
	puts(+).

:-	op(950, xfx, on).
:-	op(900,  fx, [ca, cf, co, cp, pp]).


/*----------------------------------------------------------------------+
|									|
|				Utilities				|
|									|
|	Call on File		-- obey Call with output to File	|
|	puts(String)		-- print escaped string			|
|	answer_List(L,Sep)	-- write non-empty list neatly		|
|	match_wild(Pat,Str)	-- Tops-10-like "wild card" matcher	|
|									|
+----------------------------------------------------------------------*/

Output on File :-
	telling(OldFile),
	nofileerrors,
	(   tell(File),
		fileerrors, !,
		(   call(Output), tell(OldFile)
		;   tell(OldFile), fail
		)
	;   /* couldn't open the file */
		fileerrors,
		display('** can''t tell '), display(File), ttynl,
		fail
	).


puts([]) :- !.			%  puts(Var) forcibly terminates
puts([94,C|Rest]) :-		%   94 is "^"
	(   C = 94, put(C)	%   ^^ -> ^
	;   C < 32		%   ignore control characters
	;   D is C/\31,put(D)	%   control shift
	),  !,
	puts(Rest).
puts([C|Rest]) :-
	put(C),
	puts(Rest).


answer_List([Head], Separator) :- !,
	writeq(Head), put(46), put(Separator).		%  46 is ","
answer_List([Head|Tail], Separator) :-
	writeq(Head), put(44), put(Separator), !,	%  44 is "."
	answer_List(Tail, Separator).


%   patterns are like TOPS-10 files with wild cards.
%	Ascii 42 = '*', Ascii 63 = '?' are the wild card codes.
 
match_wild([Ch|Patt], [Ch|Name]) :- !,
	match_wild(Patt, Name).
match_wild([63|Patt], [Ch|Name]) :- !,
	match_wild(Patt, Name).
match_wild([42|Patt], [Ch|Name]) :-
	match_wild(Patt, [Ch|Name]), !.
match_wild([42|Patt], [Ch|Name]) :- !,
	match_wild([42|Patt], Name).
match_wild([42], []).
match_wild([], []).


/*----------------------------------------------------------------------+
|									|
|			    Current Atoms				|
|									|
|    The predicates provided to the user are				|
|	ca(AtomPattern, AnswerList)	-- return current atoms		|
|	ca(AtomPattern)			-- display current atoms	|
|	ca				-- display all current atoms	|
|									|
|   AtomPattern ::=							|
|	Variable			-- matches any atom		|
|	Atom				-- matches only itself		|
|	StringPattern			-- matches atoms by name	|
|	[ AtomPattern | AtomPattern ]	-- matches what either matches	|
|									|
|   ca is defined as an operator for convenience.  The atoms will be	|
|   returned in ascending alphabetic order.  NB ca/1 will FAIL if no	|
|   atoms match its pattern.  ca/2 can return the empty list.		|
|									|
+----------------------------------------------------------------------*/

ca :-
	ca(Variable).			%  a Variable matches anything

ca(Pattern) :-
	ca(Pattern, Atoms),
	answer_List(Atoms, 32).

ca(Pattern, Atoms) :-
	setof(Atom, isCurrent(Pattern, Atom), Atoms).


isCurrent(Variable, Atom) :-		%  <Variable>
	var(Variable), !,	
	current_atom(Atom).
isCurrent(Atom, Atom) :-		%  <Atom>
	atom(Atom), !.
isCurrent([Head|Tail], Atom) :-		%  <String Pattern>
	integer(Head), !,
	current_atom(Atom),
	name(Atom, String),
	match_wild([Head|Tail], String).
isCurrent([Head|_], Atom) :-		%  [ <Atom Pattern> | _ ]
	isCurrent(Head, Atom).
isCurrent([_|Tail], Atom) :- !,		%  [ _ | <Atom Pattern> ]
	isCurrent(Tail, Atom).


/*----------------------------------------------------------------------+
|									|
|			   Current Operators				|
|									|
|   The predicates provided to the user are				|
|	co(OperatorPattern, AnswerList)	-- return matching operaotrs	|
|	co(OperatorPattern)		-- display matching operators	|
|	co				-- display all operators	|
|	co(P, T, A)			-- same as co op(P,T,A)		|
|									|
|   OperatorPattern ::=							|
|	op(Range, AtomPattern, AtomPattern)				|
|	AtomPattern			-- same as op(_,_,P)		|						|
|   Range ::=								|
|	Lower - Upper			-- Lower <= Actual <= Upper ?	|
|	RelOp(Limit)			-- Actual Relop Limit ?		|
|	Number				-- Actual = Number ?		|
|	[ Range | Range ]		-- true if in either Range	|
|	Variable			-- matches anything		|
|									|
|   co is defined as an operator for convenience.  The result is a list	|
|   of op(Prec,Type,Name) terms in increasing order.  The order is that	|
|   imposed by compare/3 : first in numeric order of precedence, then	|
|   by type, where fx < fy < xf < xfx < xfy < yf < yfx < yfy, then in	|
|   alphabetic order of operator name.  NB co/1 will FAIL if there are	|
|   no matching operator definitions.  If you want to save operators on |
|   a file, do (write(':- '), co).					|
|									|
+----------------------------------------------------------------------*/

co :-
	co("*").

co(Pattern) :-
	co(Pattern, Operators),
	answer_List(Operators, 31).

co(op(Precedence, Type, Name), Operators) :-
	setof(Operator, isCurrent(Precedence, Type, Name, Operator), Operators).
co(Pattern, Operators) :-
	co(op(_, _, Pattern), Operators).

co(Precedence, Type, Name) :-
	co(op(Precedence, Type, Name)).


	isCurrent(Range, TypePattern, NamePattern, op(Prec, Type, Name)) :-
		current_op(Prec, Type, Name),
		in_Range(Range, Prec),
		isCurrent(TypePattern, Type),
		isCurrent(NamePattern, Name).


		in_Range(Variable, X) :-
			var(Variable), !.
		in_Range(Lower-Upper, X) :-
			Lower =< X, X =< Upper.
		in_Range(<(Limit), X) :-
			X < Limit.
		in_Range(>=(Limit), X) :-
			X >= Limit.
		in_Range(>(Limit), X) :-
			X > Limit.
		in_Range(=<(Limit), X) :-
			X =< Limit.
		in_Range(=\=(Limit), X) :-
			X =\= Limit.
		in_Range(=:=(Limit), Limit).
		in_Range(=(Limit), Limit).
		in_Range([Head|_], X) :-
			in_Range(Head, X).
		in_Range([_|Tail], X) :- !,
			in_Range(Tail, X).
		in_Range(X, X) :-
			integer(X).


/*----------------------------------------------------------------------+
|									|
|			    Current Functor				|
|			    Current Predicate				|
|									|
|   The predicates available to the user are				|
|	cf(TermPattern, AnswerList)		-- return functors	|
|	cf(TermPattern)				-- display functors	|
|	cf					-- display all functors	|
|	cp(TermPattern, AnswerList)		-- return predicates	|
|	cp(TermPattern)				-- display predicates	|
|	cp					-- display all "	|
|									|
|   TermPattern ::=							|
|	AtomPattern/Range						|
|	AtomPattern				-- same as P/_		|
|	[ TermPattern | TermPattern ]		-- matches either	|
|	Term					-- functor(T,F,N)=>F/N	|
|									|
|   cf is defined as an operator for convenience.  The result is a list	|
|   of functor specifications in the form Functor/Arity.  It would be	|
|   useful at times to have functors represented by their most general	|
|   term, but unfortunately setof/3 calls compare/3 to do the ordering	|
|   and compare/3 orders on arity first.  This method will at least 	|
|   return things in the natural alphabetic order.  NB cf/1 will FAIL	|
|   if no functors match, while cf/2 will return the empty list.  Since	|
|   Atom Patterns can be disjunctions too, there would appear to be an	|
|   ambiguity here.  However, [A|A] qua F = [A qua F|A qua F], so all	|
|   is well.								|
|   cp is similar, but matches only current predicates.  A predicate	|
|   is current if and only if the interpreter has a clause for it; it	|
|   might be worth while telling cp about system predicates but I have	|
|   not done so yet.							|
|									|
+----------------------------------------------------------------------*/

cf :-
	cf(Functor/Arity).

cf(Pattern) :-
	cf(Pattern, Functors),
	answer_List(Functors, 32).

cf(Pattern, Functors) :-
	setof(Functor, isCurrent(Pattern, cf, Functor), Functors).


cp :-
	cp(_/_).

cp(Pattern) :-
	cp(Pattern, Predicates),
	answer_List(Predicates, 32).

cp(Pattern, Predicates) :-
	setof(Predicate, isCurrent(Pattern, cp, Predicate), Predicates).


isCurrent(Functor/Arity, WhoWantsToKnow, Functor/Arity) :-
	atom(Functor),
	integer(Arity), !,
	current_functor(Functor, MostGeneralTerm),
	functor(MostGeneralTerm, Functor, Arity),
	final_Check(WhoWantsToKnow, atom, Functor, MostGeneralTerm).
isCurrent(AtomPattern/Range, WhoWantsToKnow, Functor/Arity) :- !,
	isCurrent(AtomPattern, Functor),
	current_functor(Functor, MostGeneralTerm),
	functor(MostGeneralTerm, Functor, Arity),
	in_Range(Range, Arity),
	final_Check(WhoWantsToKnow, var, Functor, MostGeneralTerm).
isCurrent([Head|Tail], WhoWantsToKnow, Answer) :-
	integer(Head), !,
	isCurrent([Head|Tail]/_, WhoWantsToKnow, Answer).
isCurrent([Head|_], WhoWantsToKnow, Answer) :-
	isCurrent(Head, WhoWantsToKnow, Answer).
isCurrent([_|Tail], WhoWantsToKnow, Answer) :- !,
	isCurrent(Tail, WhoWantsToKnow, Answer).
isCurrent(Functor, WhoWantsToKnow, Answer) :-
	atom(Functor), !,
	isCurrent(Functor/Arity, WhoWantsToKnow, Answer).
isCurrent(Pattern, WhoWantsToKnow, Functor/Arity) :-
	ixref_Pattern(Pattern), !,
	ixref_Current(Pattern, Functor, Arity).
%%%	functor(MostGeneralTerm, Functor, Arity),
%%%	final_Check(WhoWantsToKnow, atom, Functor, MostGeneralTerm).
isCurrent(Term, WhoWantsToKnow, Answer) :-
	functor(Term, Functor, Arity), !,
	isCurrent(Functor/Arity, WhoWantsToKnow, Answer).


final_Check(cf, _,    Functor, Term).
final_Check(cp, _,    Functor, Term) :-
	current_predicate(Functor, Term).
final_Check(pp, var,  Functor, Term) :-
	current_predicate(Functor, Term),
	\+ clause(Term, incore(Term)).
final_Check(pp, atom, Functor, Term).
final_Check(sp, _,    Functor, Term) :-
	functor(Term, Functor, Arity),
	call('$seen'( Functor, Arity)).


/*----------------------------------------------------------------------+
|									|
|			Pretty-Print Predicates				|
|									|
|   The predicates provided to the user are				|
|	pp(TermPattern)			-- display selected predicates	|
|	pp(help)			-- display help summary		|
|	pp				-- display entire program	|
|									|
|   'pp' will print out the entire program, and will precede it with	|
|   a declaration of all the current operators.  pp(foo/2) will look	|
|   in the file which defines foo/2 if the predicate is compiled or	|
|   otherwise invisible; it adds a comment saying which file it read	|
|   so that you can tell.  This needs the '$defn'(Fn,Ar, File) facts	|
|   that IXREF puts in the database.  If you have these facts, you can	|
|   also ask pp from(File) to see everything defined in a particular	|
|   file; if you have no such facts no harm is done.  pp(help) needs	|
|   HELPER loaded before it will work.  pp is an operator.		|
|									|
|   The layout produced by PP suits my taste.  I have asked for other	|
|   people to supply me with rules to produce something that suits them,|
|   with the idea of parameterising PP.  Since no-one has done this,	|
|   PP is still as inflexible as listing/1.				|
|									|
+----------------------------------------------------------------------*/

pp :-
	puts(":-^_"), co, nl,
	pp(_/_).

pp(help) :- !,
	give_help('pp.hlp').
pp(Pattern) :-
	setof(Predicate, isCurrent(Pattern, pp, Predicate), Predicates),
	pp_explicit(Predicates).


	pp_explicit([Head|Tail]) :-
		pp_explicit(Head), !,
		pp_explicit(Tail).
	pp_explicit([]).
	pp_explicit(Functor/Arity) :-
		functor(Head, Functor, Arity),
		final_Check(pp, var, Functor, Head), !,
		(   clause(Head, Body),
			pp_explicit((Head:-Body), Head)
		;   nl
		).
	pp_explicit(Functor/Arity) :-
		call('$defn'(Functor, Arity, File)), !,
		functor(Head, Functor, Arity),
		seeing(OldFile),
		nofileerrors,
		(   see(File),
			puts("% From "), writeq(File), puts("^_^_"),
			repeat,
			    read(Term),
			    expand_term(Term, Form),
			    pp_explicit(Form, Head), !,
			nl,
			seen,
			see(OldFile)
		;   /* unable to open the file */
			display('** can''t see '), display(File), ttynl
		), !.
	pp_explicit(Functor/Arity) :-
		display('** '), display(Functor), display(/), display(Arity),
		display(' is undefined'), ttynl.
	

		pp_explicit(end_of_file, _) :- !.
		pp_explicit(Head, Head) :- !,
			pp_explicit((Head:-true), Head).
		pp_explicit((Head :-Body), Head) :-
			numbervars((Head:-Body), 0, _),
			writeq(Head),
			pp_conjunction(Body, 0, 2, 8),
			fail.
	
	
	pp_conjunction((A,B), L, R, D) :- !,
		pp_conjunction(A, L, 1, D), !,
		pp_conjunction(B, 1, R, D).
	pp_conjunction(true, L, 2, D) :- !,
		puts(".^_").
	pp_conjunction((A;B), L, R, D) :- !,
		pp_head(fail, L, D),
		pp_disjunction((A;B), 0, 2, D),
		pp_tail(R, ".^_").
	pp_conjunction((A->B), L, R, D) :- !,
		pp_conjunction(A, L, 5, D), !,
		pp_conjunction(B, 5, R, D).
	pp_conjunction(Goal, L, R, D) :-
		pp_head(Goal, L, D),
		writeq(Goal),
		pp_tail(R, ".^_").

		pp_head(!,    0, D) :- !, puts(" :- ").
		pp_head(!,    1, D) :- !, puts(",  ").
		pp_head(Goal, 0, D) :- !, puts(" :-^_"), tab(D).
		pp_head(Goal, 1, D) :- !, puts(",^_"), tab(D).
		pp_head(Goal, 3, D) :- !, puts("(   ").
		pp_head(Goal, 4, D) :- !, puts(";   ").
		pp_head(Goal, 5, D) :- !, puts(" ->^_"), tab(D).

		pp_tail(2, C) :- !, puts(C).
		pp_tail(_, _).

		pp_disjunction((A;B), L, R, D) :- !,
			pp_disjunction(A, L, 1, D), !,
			pp_disjunction(B, 1, R, D).
		pp_disjunction(Conj,  L, R, D) :-
			E is D+8, M is L+3,
			pp_conjunction(Conj, M, 1, E),
			nl, tab(D),
			pp_tail(R, ")").

