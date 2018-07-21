% File  	ASK.PL
% Author  	Mike Uschold
% Purpose	Facilities for asking user questions.  Provides facility for
%		yes/no and multiple(multiple) choice questions and a general
%		facility for prompting.
% Needs:	MYREAD.PL
% Date		19 Nov 84

/*
:- public yes_no/2,
	  prompt_for_input/2,
	  prompt_for_inputs/2,
	  write_prompt/1,
	  multiple_choice/4,
	  multiple_choice/5,
	  list_multiple_choice/1,
	  list_multiple_choice/2,
	  numlst/1,
	  numlst/4,
	  help_or_abort/1,
	  help_or_abort/2,
	  help_request/1,
	  help_request/2.

:- mode	  multiple_choice(+, +, +, -),
	  list_multiple_chioce(+),
	  list_multiple_chioce(+, +),
	  finish_list_multiple_choice(+, +, +),
	  prompt_for_inputs(+,-),
	  prompt_for_input(+,-),
	  help_or_abort(+),
	  help_or_abort(+,-),
	  help_request(+),
	  help_request(+,-).
*/

% PREDICATE
% yes_no(+Prompt, -Ans)
% Prompts the user with "Prompt" requiring an answer of "Yes" or "No"
% Returns Ans = 'yes', 'no', 'abort' or '?' (for help).  
% Abbreviations are allowed.

yes_no(Prompt, Ans) :- 
	prompt_for_input(Prompt, Reply),
	yes_or_no(Reply, Ans), !.
yes_no(Prompt, Ans) :-
	write('Please answer <yes> or <no>'), nl,
	yes_no(Prompt, Ans).

yes_or_no(Reply, yes) :-
	equivalent(command, Reply, yes), !.
yes_or_no(Reply, no)  :-
	equivalent(command, Reply, no), !.
yes_or_no(Reply, Expanded) :-
	help_or_abort(Reply, Expanded), !.	


% PREDICATE
% prompt_for_input(+Prompt, -Input)
% Prompts user for one word responses.  
% To be used for yes/no, multiple choice etc...

prompt_for_input(Prompt, Input) :-
	write_prompt(Prompt),
	my_readin([Input|_]).


%PREDICATE
%prompt_for_inputs(+Prompt,-Input)
% Prompts user for response list.

prompt_for_inputs(Prompt,Inputs):-
	write_prompt(Prompt),
	my_readin(Inputs).


% PREDICATE
% write_prompt(+Prompt)
% Takes Prompt in one of two forms and uses "writef" of "write" accordingly.

write_prompt(Text-Args) :-
	!,
	Writef =.. [writef, Text, Args],
	call(Writef),
	ttyflush.
write_prompt(Text) :-
	write_prompt(Text-[]).


% PREDICATE
% multiple_choice(+Prompt, +List, +Max, -Ans)
% Prompts for up to "Max" selections from the items in "List"
% Allows the user to abort program or ask for help.  In these cases,
% the atoms 'abort' and '?' are returned. 

multiple_choice(Prompt, List, Max, Ans) :-
	write_prompt(Prompt), nl,
	list_multiple_choice(List),
	length(List, N),
	numlst(1, N, Max, Reply),
	finish_multiple_choice(Prompt, List, Max, Reply, Ans).

% PREDICATE
% multiple_choice(+Prompt, +List, +KeyWords, +Max, -Ans)
% Same as multiple_choice/4 except that "Ans" is composes of items from
% "KeyWords" instead of the corresponding integers.

multiple_choice(Prompt, List, KeyWords, Max, Ans) :-
	write_prompt(Prompt), nl,
	list_multiple_choice(List),
	length(List, N),
	numlst(1, N, Max, Integers),
	finish_multiple_choice(Prompt, List, KeyWords, Max, Integers, Ans).


% finish_multiple_choice(+Prompt, +List, +Max, +Reply, -Ans)
% Allows a help or abort request thru.
% Forces reprompt if user has simply typed a <CR>

% Reprompt
finish_multiple_choice(Prompt, List, Max, [], Ans) :- !,
	multiple_choice(Prompt, List, Max, Ans).
% Help or Abort
finish_multiple_choice(_, _, _, [Reply|_], Reply) :- 
	help_or_abort(Reply), !.
% No Change
finish_multiple_choice(_, _, _, Ans, Ans) :- !.


% finish_multiple_choice(+Prompt, +List, +AllKeyWords, +Max, +Reply, 
%			 -SelectedKeyWords)
% Same as /2 version except that the integer selections are changed to keywords
% Reprompt
finish_multiple_choice(Prompt, List, AllKeyWords, Max, [], Ans) :- !,
	multiple_choice(Prompt, List, AllKeyWords, Max, Ans).
% Help or Abort
finish_multiple_choice(_, _, _, _, [Reply|_], [Reply]) :- 
	help_or_abort(Reply), !.
% Assign keywords to integer selections
finish_multiple_choice(_, _, KeyWords, _, Integers, Ans) :-
	nmembers(Integers, KeyWords, Ans).


% PREDICATE
% list_multiple_choice(+List)
% Prints out each item in "List" with a number next to it from 1 to N

list_multiple_choice(List) :-
	finish_list_multiple_choice(List, '*', 1).

list_multiple_choice(List, PromptChar) :-
	finish_list_multiple_choice(List, PromptChar, 1).	


finish_list_multiple_choice([], PromptChar, _) :- !, 
	writef('%w', [PromptChar]), ttyflush.
finish_list_multiple_choice([Head|Tail], PC, N) :-
	writef('%2r. %t\n', [N, Head]),
	M is N+1,
	finish_list_multiple_choice(Tail, PC, M). 



% PREDICATE
% numlst(+Min, +Max, +MaxSize, -Numlst) Prompts user for a list of up
% to "MaxSize" integers between Min and Max.  Used for multiple(multiple) choice
% questions.  All non digit characters are taken as delimiters or otherwise
% ignored with the exception of the full stop which may be misinterpreted as a
% decimal point in a real number.  In this case, the entire real number is
% ignored.
% Allows the user to abort request or ask for help.  

numlst(Numlst) :-
	numlst(1, 9999, 100, Numlst).

numlst(Min, Max, MaxSize, Numlst) :-
	my_readin(List),
	strip_junk(Min, Max, List, Numlst),
	list_size_ok(Numlst, MaxSize), !.
numlst(Min, Max, 1, Numlst) :- !,
	writef('\n*** Enter an integer between %t and %t ***\n\n', [Min, Max]),
	numlst(Min, Max, 1, Numlst).
numlst(Min, Max, MaxSize, Numlst) :- !,
	writef('\n*** Enter up to %t integers, each between %t and %t ***\n',
	        [MaxSize, Min, Max]),
	writef('*** Seperate them using blanks or commas ***'), 
	writef('You may enter "a" for abort, or "?" for help'),
	numlst(Min, Max, MaxSize, Numlst).

list_size_ok(Numlst, MaxSize) :-
	length(Numlst, N),
	N >= 0,
	N =< MaxSize.

strip_junk(_, _, [], []) :- !.
strip_junk(Min, Max, [Int|Rest], [Ans|SRest]) :-
	inrange(Min, Max, Int, Ans), !,
	strip_junk(Min, Max, Rest, SRest).
strip_junk(Min, Max, [_|Rest], SRest) :-
	strip_junk(Min, Max, Rest, SRest).

inrange(Min, Max, Int, Int) :-
	integer(Int),
	Int =< Max,
	Int >= Min, !.
inrange(_, _, Reply, Expanded) :-
	help_or_abort(Reply, Expanded), !.
inrange(_, _, Int, _) :-
	writef('** Warning ** "%t" out of range (ignored).\n', [Int]),
	!, fail.


% PREDICATE
% help_or_abort(+Reply, -Expanded)
% Is true if "Reply" expands to a help or abort request.

help_or_abort(Reply) :-
	help_or_abort(Reply, _).

help_or_abort(Reply, abort) :-
	equivalent(command, Reply, abort), !.
help_or_abort(Reply, Help) :-
	help_request(Reply, Help), !.


% PREDICATE
% help_requst(+Help, -Expanded)
% "help_request" succeeds if user has typed "?", or an abbreviation of "help"

help_request(Help) :-
	help_request(Help, _), !.

help_request(Help, '?') :-
	equivalent(command, Help, '?'), !.	

