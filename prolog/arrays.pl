%   File   : ARRAYS.PL
%   Author : R.A.O'Keefe
%   Updated: 8 November 1983
%   Purpose: Updatable arrays in Prolog.

%   Changed for SWI-Prolog, 21/1/90 by Jan Wielemaker
%	* Removed public/mode declarations
%	* Inserted module declaraction

/*  These operations are fully described in
	"Updatable Arrays in Prolog", R.A.O'Keefe, DAI Working Paper 150.
    Note that store(Index, Old, Elem, New) sometimes side-effects Old and
    sometimes doesn't; you cannot rely on Old remaining unchanged.  This
    is NOT an example of logic programming.  For a logic programming
    solution (with cost O(lgN) rather O(1)) see Trees.Pl.
*/

:- module(arrays,
	[ array_length/1
	, array_to_list/2
	, fetch/3
	, list_to_array/2
	, store/4
	]).

/*
:- public
	array_length/1,
	array_to_list/2,
	fetch/3,
	list_to_array/2,
	store/4.

:- mode
	array_length(+, -),
	array_to_list(+, -),
	    un_wrap(+, ?),
	fetch(+, +, ?),
	    get_last(+, ?),
	list_to_array(+, -),
	    wrap_up(+, -),
	store(+, +, +, -),
	    store(+, +, -, +, -).
*/

array_length(Array+Updates, Length) :-
	functor(Array, array, Length).


array_to_list(Array+Updates, List) :-
	Array =.. [array|Wrapped],
	un_wrap(Wrapped, List).

	un_wrap([History|Histories], [Element|Elements]) :-
		get_last(History, Element), !,
		un_wrap(Histories, Elements).
	un_wrap([], []).


fetch(Index, Array+Updates, Element) :-
	arg(Index, Array, History),
	get_last(History, Element).

	get_last([Head|Tail], Element) :-
		var(Tail), !,
		Element = Head.
	get_last([_|Tail], Element) :-
		get_last(Tail, Element).


list_to_array(List, Array+0) :-
	wrap_up(List, Wrapped),
	Array =.. [array|Wrapped].

	wrap_up([Element|Elements], [[Element|_]|Wrapped]) :- !,
		wrap_up(Elements, Wrapped).
	wrap_up([], []).


store(Index, Array+Updates, Element, NewArray+NewUpdates) :-
	functor(Array, array, Length),
	arg(Index, Array, History),
	put_last(History, Element),
	K is Updates+1, !,
	store(Length, K, NewUpdates, Array, NewArray).

	store(N, N, 0, Old, New) :- !,
		Old =.. [array|OldList],
		un_wrap(OldList, MidList), !,
		wrap_up(MidList, NewList),
		New =.. [array|NewList].
	store(_, U, U, Array, Array).

	put_last(History, Element) :-
		var(History), !,
		History = [Element|_].
	put_last([_|History], Element) :-
		put_last(History, Element).

