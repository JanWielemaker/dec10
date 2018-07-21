%   File   : TYPE.PL
%   Author : R.A.O'Keefe
%   Updated: 21 June 1983
%   Purpose: A Tops-10-like "type" command to display files.

%   "type [a,b,c]" will try hard to see a, b, c and will display them
%   on the terminal.  Output redirection will have no effect on it, a
%   more general command can be made by editing this one.  When this
%   is interpreted, you can stop it.  When it is compiled, all you can
%   do is use ^O.  Helper.Pl is needed for try_hard_to_see.
%   With PP.PL loaded, you can say "type [a,b,c] on d" to copy files.

:- public
        (ty)/1,
        (type)/1.

:- mode
        ty(+),
        type(+).

:- op(940, fx, [ty,type]).


ty File :-
        type File.

type Var :-
        var(Var),
        !,
        display('! variable given as file name'), ttynl,
        fail.
type [Head|Tail] :- !,
        type Head, !,
        type Tail.
type File :-
        seeing(Old),
        try_hard_to_see(File, ['/usr/bs/press','/usr/bs/prolog'], [pl,hlp,txt,lpt]),
        seeing(New),
        display('File '), display(New), ttynl,
        repeat,
            get0(Ch),
            ttyput(Ch),
            Ch = -1,
        !,
        seen,
        see(Old).



