%   File   : TRYSEE.PL
%   Author : R.A.O'Keefe
%   Updated: 16 December 1983
%   Purpose: Search through several directories/extensions to find a file
%   Needs  : append/3 from Util:ListUtil.Pl

%   try_hard_to_see(FileName, DeviceDefaults, ExtensionDefaults)
%       -- tries all the Extension and Device defaults (varying the
%       -- extensions first) until it succeeds in 'see'ing the file,
%       -- and fails if the file cannot be found.
%   try_hard_to_see(FileName, Devs, Exts, FileFound)
%       -- is like try_hard_to_see/3, but doesn't open the file, it
%       -- just binds FileFound to it.  If no file can be found, it
%       -- just fails.  The other version prints a message.


:- public
        try_hard_to_see/3,
        try_hard_to_see/4.

:- mode
        try_hard_to_see(+, +, +, ?),
        try_hard_to_see(+, +, +),
            expand_file(+, +, +, -),
                parse_file(-, -, -, ?, ?),
                    file_component(-, ?, ?),
                        letter_or_digit(+, -),
                normalise_file_component(+, +, -),
                supply_file_default(+, +, +, -),
                    supply_file_default(+, +, -),
                pack_file_title(+, +, +, -).


try_hard_to_see(Title, DeviceDefaults, ExtensionDefaults, FileFound) :-
        seeing(OldFile),
        nofileerrors,
        (   expand_file(Title, DeviceDefaults, ExtensionDefaults, FullTitle),
            see(FullTitle),
            seeing(FileFound),
            seen
        ;   true
        ),  !,
        see(OldFile),
        fileerrors,
        nonvar(FullTitle).              %   HACK HACK HACK


try_hard_to_see(Title, DeviceDefaults, ExtensionDefaults) :-
        nofileerrors,
        expand_file(Title, DeviceDefaults, ExtensionDefaults, FullTitle),
        see(FullTitle), !,
        fileerrors.
try_hard_to_see(Title, _, _) :-
        fileerrors,
        write('** Can''t see '), writeq(Title), nl, fail.


expand_file(Title, DeviceDefaults, ExtensionDefaults, FullTitle) :-
        atomic(Title),  
        name(Title, TitleName), !,
        expand_file(TitleName, DeviceDefaults, ExtensionDefaults, FullTitle).
expand_file(Title, DeviceDefaults, ExtensionDefaults, FullTitle) :-
        parse_file(Device, FileName, Extension, Title, []),
        normalise_file_component(FileName, 6, TryFileName), !,
        supply_file_default(Device, DeviceDefaults, 6, TryDevice),
        supply_file_default(Extension, ExtensionDefaults, 3, TryExtension),
        pack_file_title(TryDevice, TryFileName, TryExtension, TryTitle),
        name(FullTitle, TryTitle).


        parse_file(Device, FileName, Extension) -->
                (   file_component(Device), "/"
                |   {   Device = ""   }
                ),  !,
                file_component(FileName),
                (   ".", file_component(Extension)
                |   {   Extension = ""   }
                ),  !.


                file_component([LetDig|Rest]) -->
                        [Char], {   letter_or_digit(Char, LetDig)   }, !,
                        file_component(Rest).
                file_component([]) --> [].

                        letter_or_digit(C, C) :-
                                C >= "0", C =< "9", !.
                        letter_or_digit(C, C) :-
                                C >= "a", C =< "z", !.
                        letter_or_digit(C, D) :-
                                C >= "A", C =< "Z",
                                D is C+("a"-"A").


        normalise_file_component([], _, []) :- !.
        normalise_file_component(Default, Length, TryThis) :-
                atomic(Default),
                name(Default, DefaultName), !,
                normalise_file_component(DefaultName, Length, TryThis).
        normalise_file_component(_, 0, []) :- !.
        normalise_file_component([C|Rest], Length, [LetDig|More]) :-
                letter_or_digit(C, LetDig), !,
                Left is Length-1,
                normalise_file_component(Rest, Left, More).
        normalise_file_component([_|Rest], Length, TryThis) :-
                normalise_file_component(Rest, Length, TryThis).


        supply_file_default(Given, _, Length, TryThis) :-
                normalise_file_component(Given, Length, TryThis).
        supply_file_default([], Defaults, Length, TryThis) :-
                supply_file_default(Defaults, Length, TryThis).

                supply_file_default([Default|_], Length, TryThis) :-
                        normalise_file_component(Default, Length, TryThis).
                supply_file_default([_|Defaults], Length, TryThis) :- !,
                        supply_file_default(Defaults, Length, TryThis).


        pack_file_title([], FileName, Extension, Title) :- !,
                append(FileName, [46|Extension], Title), !.     % 46 is "."
        pack_file_title(Device, FileName, Extension, Title) :-
                pack_file_title([], FileName, Extension, Tail),
                append(Device, [92|Tail], Title), !.            % 58 is "/"

