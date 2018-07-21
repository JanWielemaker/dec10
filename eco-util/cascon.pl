% File:      CASCON.PL
% Author:    Michael Uschold
% Purpose:   Permits simple case conversion of words to either all upper
%	     or all lower case.
/*
:- public captal/2, uncap/2.

:- mode captal(+, -).
:- mode uncap(+, -).
*/

/* "captal"  Converts an atom -or- a list of characters to upper case. */
captal(In, Out) :-		%   Convert a list of characters
	captal0(In, Out), !.
captal(In, Out) :-		%   Convert an atom
	name(In, Inlist),
	captal0(Inlist, Outlist),
	name(Out, Outlist), !.
captal(_, _) :-
	writef('\nIllegal input to "captal" predicate, WATCH OUT!\n
		See file: CASCON.PL[400,7260,pini]%f').

captal0([], []).			%   Converts a list of characters to upper case
captal0([H|T], [Hcap|W]) :-	
	H >= 97,		%   "a",
	H =< 122, !,		%   "z",
	Hcap is H-32,
	captal0(T, W).
captal0([H|T], [H|W]) :-
	captal0(T, W).

/* "uncap"  Converts an atom -or- a list of characters to lower case. */
uncap(In, Out) :-		%   Convert a list of characters
	uncap0(In, Out), !.
uncap(In, Out) :-		%   Convert an atom
	name(In, Inlist),
	uncap0(Inlist, Outlist),
	name(Out, Outlist), !.
uncap(_, _) :-
	writef('\nIllegal input to "uncap" predicate, WATCH OUT!\n%f').

uncap0([], []).			%   Converts a list of characters to lower case
uncap0([H|T], [Hsmall|W]) :-	
	H >= 65,		%   "A"
	H =< 90, !,		%   "Z"
	Hsmall is H+32,
	uncap0(T, W).
uncap0([H|T], [H|W]) :-
	uncap0(T, W).


