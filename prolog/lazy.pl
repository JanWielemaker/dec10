%   File   : LAZY.PL
%   Author : R.A.O'Keefe
%   Updated: 30 October 1983
%   Purpose: Lazy lists in Prolog.
%   Needs  : apply/2 from APPLIC.PL.

%   Note: this code is "pure" only in the sense that it has no side-
%   effects.  It does rely on the 'var' metalogical predicate and cuts.
%   The lists are a little bit too eager to really be called lazy, but
%   if you look at N elements it is true that only N+1 will be computed.
%   Really lazy lists would compute N.  If you backtrack, the computed
%   elements will be undone just like other Prolog data structures, a
%   Prolog system with "intelligent backtracking" might not do that.

/*
:- type
	lazy_list(T) --> list(T)/void(T,T).

:- pred
	make_lazy(T, void(T,T), lazy_list(T)),
	head_lazy(lazy_list(T), T),
	tail_lazy(lazy_list(T), lazy_list(T)),
	member_check_lazy(T, lazy_list(T)).
*/
:- public
	make_lazy/3,
	head_lazy/2,
	tail_lazy/2,
	member_check_lazy/2.

:- mode
	make_lazy(+, +, -),
	head_lazy(+, ?),
	tail_lazy(+, -),
	member_check_lazy(+, +).


%   A lazy list is a pair consisting of a normal Prolog list (usually
%   ending with an unbound variable) and a goal which may be used to
%   generate new elements.  The idea is that [X0,X1,X2,...]/R should
%   satisfy X0 R X1, X1 R X2, ...  These objects should only be used
%   as arguments to these predicates.

make_lazy(First, Step, [First|_]/Step).


head_lazy([Head|_]/_, Head).


tail_lazy([_|Tail]/Step, Tail/Step) :-
	nonvar(Tail), !.	%  delete this clause to get logic
tail_lazy([Head|Tail]/Step, Tail/Step) :-
	apply(Step, [Head,Next]),
	Tail = [Next|_].


member_check_lazy(Thing, LazyList) :-
	head_lazy(LazyList, Thing), !.
member_check_lazy(Thing, LazyList) :-
	tail_lazy(LazyList, LazyTail),
	member_check_lazy(Thing, LazyTail).
