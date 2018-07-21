%   File   : RANDOM.PL
%   Author : R.A.O'Keefe
%   Updated: 1 October 1984
%   Purpose: Random number generator.

/*  This file needs 30-bit integers, or floating point, or both.
    The <<15 and >>15 are used to get binary fixed(30,15) arithmetic;
    floating point would do fine.  What we want is to take the
    fractional part of (A0/mod0+A1/mod1+A2/mod2).
*/

:- public
	random/2,
	random/3,
	rand_perm/2.

:- mode
	random(+, -),
	random(+, -, -),
	rand_perm(+, -).


%   given an integer N >= 1, random(N, I) unifies I with a random
%   integer between 0 and N.

random(N, I) :-
	(   retract(seed(A0,A1,A2))
	;   A0 = 3172, A1 = 9814, A2 = 20125
	),
	B0 is (A0*171) mod 30269,
	B1 is (A1*172) mod 30307,
	B2 is (A2*170) mod 30323,
	asserta(seed(B0,B1,B2)),
	!,
	I is ((((A0<<15)/30269+(A1<<15)/30307+(A2<<15)/30323)/\32767)*N)>>15.


%   given an non-empty List, random(List, Elem, Rest) unifies Elem with
%   a random element of List and Rest with the other elements.

random(List, Elem, Rest) :-
	length(List, N),
	N > 0,
	random(N, I),
	nth0(I, List, Elem, Rest).


%   rand_perm(List, Perm) unifies Perm with a random permutation
%   of List.  What good this may be I'm not sure, and there's bound
%   to be a more efficient way of doing it.  Oh well.

rand_perm([], []).
rand_perm([H1|T1], [H2|T2]) :-
	random([H1|T1], H2, T3),
	rand_perm(T3, T2).

