% Needs:  STRING.PL
/*
:- public nil_to_var/2,
	  generate_pairs/2,
	  error/2,
	  nmembers/3,
	  is_real_number/1,
	  join_names/2,
	  join_names/3,
	  pretty_display_list/2,
	  pretty_display_list/3,
	  change_nth_x_to_y/5,
	  replace_all/4,
	  replace_item/4,
	  replace_item/5,
	  add_or_replace_item/4,
	  var_add_or_replace_item/4,
	  verify_change/5,
	  do_change/5,
	  verify_action/2,
	  verify_action/3,
	  vars_to_ques_mk/2,
	  var_to_ques_mk/2,
	  wait/0,
	  wait/1,
	  wait/2,
	  add_item/3,
	  member_list/2,
	  put_list/1,
	  remove_list/3,
	  islist/1,
	  mywriteql/1,
	  mywriteq/1,
	  nsetof/3,
	  assert_to_list/2,
	  list_to_assert/1,
	  add_new_ones_to_list/3,
	  part_flatten/2,
	  remove_duplicates/3,
	  count/3,
	  remove/3,
	  replace1/4,
	  remove1/3,
	  check_same_members/2,
	  to_the_power/3,
	  to_the_power/4.

:- mode   nil_to_var(?, -),
	  term_to_atom(+, -),
	  generate_pairs(+, -),
	  error(+, +),
	  nmembers(+, +, ?),
	  is_real_number(+),
	  islist(+),
	  mywriteql(+),	  
	  mywriteq(+),
	  nsetof(?, ?, ?),	%   Should be same as "setof"
	  assert_to_list(+, -),
	  list_to_assert(+).
*/

% General BS for lazy typists
t :- trace.
h :- halt.
l(X) :- listing(X).			% Easy way to list predicates
:- op(500, fy, l).

% PREDICATE
% nil_to_var(?Input, -Converted)
% "Converted" is an uninstantiated variable if "Input" = []
% Else,  "Input" is returned as the head of the list "Input"

nil_to_var([], _) :- !.
nil_to_var([X|_], X).




% PREDICATE
% generate_pairs(Set, Pairs)
% Is true when "Pairs" is a list of all the possible pairs from the elements
% in set.
% eg  generate_pairs([a,b,c], [a-b, a-c, b-c]).
generate_pairs(Set, Pairs) :-
	generate_pairs(Set, [], Pairs).

generate_pairs([H], Pairs, Pairs) :- !.
generate_pairs([H|T], SoFar, Pairs) :-
	gen_pairs(H, T, [], Pairs1),
	append(SoFar, Pairs1, NextSoFar),
	generate_pairs(T, NextSoFar, Pairs).

gen_pairs(_, [], Pairs, Pairs) :- !.
gen_pairs(First, [H|T], SoFar, Pairs) :-
	append(SoFar, [First-H], NextSoFar),
	gen_pairs(First, T, NextSoFar, Pairs).


% PREDICATE
% error(Predicate, File)
% Prints an error message from Predicate and File

error(Predicate, File) :-
	concat(File, '.PL', FileName),
	writef('** ERROR **  See predicate "%t" in file: "%t"',
		[Predicate, File]).

% PREDICATE
% nmembers(Indices, Answers, Ans)
% Like nmember in LSTUTL.PL except that it works on a list.
% eg.   nmembers([3,5,1], [a,b,c,d,e,f,g,h], [c,e,a]) is true

nmembers([], _, []).
nmembers([N|Rest], Answers, [Ans|RestAns]) :-
	nmember(Ans, Answers, N),
	nmembers(Rest, Answers, RestAns).


% PREDICATE
% is_real_number(Atom)  Succeeds iff Atom is a real number.

is_real_number(N) :-
	integer(N), !.
is_real_number(N) :-
	name(N,Name),
	append(Front,[46|Back],Name),
	name(F,Front),
	name(B,Back),
	integer(F),
	integer(B).


% PREDICATE
% join_names(+Names, Joined)
% Concats each Name from Names together placing underscores in between.
% eg.   join_names([this, is, a, name], this_is_a_name)  is true

join_names(Name1, Name2, Joined) :-
	join_names([Name1, Name2], Joined).

join_names([Name1, Name2], Joined) :- !,
	concat(Name1, '_', Head),
	concat(Head, Name2, Joined).
join_names([Name1, Name2|Names], Joined) :-
	join_names([Name1, Name2], Head),
	join_names(Names, Tail),
	join_names([Head, Tail], Joined).



% PREDICATE
% Prints a pretty display of a list of "facts"
% "Heading" is an optional heading which comes before the list is output
% "Format" is a string which is used by "writef" to format the output
% "List" must be a list of functions of the same arity
%  eg.  List = [foo(a,b), foo(c,d), foo(iol, erf)]

% If there is nothing there, then don't print anything!
pretty_display_list(_, _, []) :- !.
pretty_display_list(Heading, Format, List) :-
	pretty_disp_list(Heading, Format, List).

pretty_disp_list(Heading, Format, List) :-
	call(Heading), 
	pretty_disp_list(Format, List).

pretty_disp_list(_, []).
pretty_disp_list(Format, [H|Rest]) :-
	H =.. [_|Args],
%	lists_to_atoms(Args, AtomArgs),        % Purpose unknown 22/4/86 (MFU)
	Writef =.. [writef, Format, Args],
	call(Writef),
	pretty_disp_list(Format, Rest).

% PREDICATE
% change_nth_x_to_y(OldList, N, X, Y, NewList)
% OldList is a list of identical simple structures.  If the nth argument in
% any of the structures in the list is "Old" it is replaced by "New" and 
% they are all returned in NewList
%   Needs replace/4 from UTIL:OCCUR.PL

change_nth_x_to_y([], _, _, _, []).
change_nth_x_to_y([Old|Olds], N, X, Y, [New|News]) :-
	arg(N, Old, X),
	replace([N], Old, Y, New),
	!,
	change_nth_x_to_y(Olds, N, X, Y, News).
change_nth_x_to_y([Old|Olds], N, X, Y, [Old|News]) :-
	change_nth_x_to_y(Olds, N, X, Y, News).


% PREDICATE
% replace_all(+OldItem, +NewItem, +OldList, -NewList)
% Replaces *all* occurrence of "OldItem" in "OldList" with "NewItem"
% returning "NewList".  Order *is* maintained

replace_all(_, _, [], []) :- !.
replace_all(OldItem, NewItem, OldList, NewList) :-
	replace_item(OldItem, NewItem, OldList, FirstPart, UnSearched), !,
	append(FirstPart, LastPart, NewList),
	replace_all(OldItem, NewItem, UnSearched, LastPart).
replace_all(_, _, Ans, Ans).


% PREDICATE
% replace_item(+OldItem, +NewItem, +OldList, -NewList)
% Replaces the first occurrence of "OldItem" in "OldList" with "NewItem"
% returning "NewList".  Order *is* maintained
% FAILS if "OldItem" is not found

replace_item(OldItem, NewItem, [OldItem|Rest], [NewItem|Rest]) :- !.
replace_item(OldItem, NewItem, [Item|Rest], [Item|NewRest]) :-
	replace_item(OldItem, NewItem, Rest, NewRest).


% PREDICATE
% replace_item(+OldItem, +NewItem, +OldList, -FirstPart, -UnSearched)
% same as replace_item/4 except the new list is returned in two parts.
% [FirstPart|UnSearched] is the new list.
% This makes "replace_all" more efficient

replace_item(OldItem, NewItem, [OldItem|Rest], [NewItem], Rest) :- !.
replace_item(OldItem, NewItem, [Item|Rest], [Item|FirstPart], NewRest) :-
	replace_item(OldItem, NewItem, Rest, FirstPart, NewRest).


% PREDICATE
% add_or_replace_item(+OldItem, +NewItem, +OldList, -NewList)
% Same as "replace_item" except it will not FAIL!
% If "OldItem" is not found, "NewItem" is added to "OldList anyway.

%   Replace old item
add_or_replace_item(OldItem, NewItem, OldList, NewList) :-	   
	replace_item(OldItem, NewItem, OldList, NewList), !.
%   Add new item 
add_or_replace_item(_, NewItem, OldList, [NewItem|OldList]).


% PREDICATE
% var_add_or_replace_item(+OldItem, +NewItem, +OldList, -NewList)
% Same as "replace_item" unless "OldItem" is a variable.  
% In that case, "NewItem" is simply added to "OldList.

%   Add new item 
var_add_or_replace_item(OldItem, NewItem, OldList, [NewItem|OldList]) :-  
	var(OldItem), !.					
%   Replace old item
var_add_or_replace_item(OldItem, NewItem, OldList, NewList) :-	   
	replace_item(OldItem, NewItem, OldList, NewList).


% PREDICATE
% verify_change(+Prompt, +Action, +Confirm, +Old, -New)
% "Prompt"s user for yes/no and does the "Action" IFF user answers yes.
% A confirmation message is printed IFF "Confirm" = confirm
% Generally, the "Action" will modify the object "Old", creating "New".
% That is, "Old", and "New" will be 2 of the arguments of "Action".
% If the user's response is "no", the object is returned unchanged.

verify_change(Prompt, Action, Confirm, OldIR, NewIR) :-
	yes_no(Prompt, Ans),
	help_if_necessary([verify,change,name],Ans,Response1),
	expand(command,Response1,Response),
%	check_abort(...),
	do_change(Response, Action, Confirm, OldIR, NewIR).

do_change(yes, Action, confirm, _, _) :- !,
	writef('<Confirmed>'), nl, ttyflush,	% Default confirmation message
	call(Action).
do_change(yes, Action, confirm-[YesMsg, _], _, _) :- 
	nonvar(YesMsg), !,
	writef('%t', [YesMsg]), nl, ttyflush,
	call(Action).
do_change(yes, Action, _, _, _) :- !,
	call(Action).
do_change(no, _, confirm, IR, IR) :- !,
	writef('<No Change>'), nl, ttyflush.
do_change(no, _, confirm-[_, NoMsg], IR, IR) :- !,
	writef('<%t>', [NoMsg]), nl, ttyflush.
do_change(no, _, _, IR, IR).


% PREDICATE
% "Prompt"s user for yes/no answer whether to do "Action"
% Similar to "verify_change", except that nothing is changed by "Action".
% There is thus no need for the last two arguments "Old" and "New".

verify_action(Prompt, Action) :-
	verify_action(Prompt, Action, noconfirm), !.
verify_action(Prompt, Action, Confirm) :-
	verify_change(Prompt, Action, Confirm, _, _).

%PREDICATE
% vars_to_ques_mk(+List, +NewList)
% Replaces any variable in the "List" with the character: '?'.  
% All other items are returned untouched and in the same order
vars_to_ques_mk([], []) :- !.
vars_to_ques_mk([H|T], [NewH|NewT]) :-
	var_to_ques_mk(H, NewH),
	vars_to_ques_mk(T, NewT).

var_to_ques_mk(X, '?') :- 
	var(X), !.
var_to_ques_mk(X, X).


%PREDICATE
/* "wait" is  used to hold the screen.  It waits for a  cairrage return
    and does nothing.  */
wait :-
	wait('Press RETURN to continue...', noclear).

wait(Prompt) :-
	wait(Prompt, noclear).

wait(Prompt, clear) :- !,
	write_prompt(Prompt), ttyflush, 
	prompt(Old, ''), 
	skip(31), 
	clear,
	prompt(_, Old).
wait(Prompt, _) :- !,
	write_prompt(Prompt), ttyflush, 
	prompt(Old, ''), 
	skip(31), 
	nl, nl,
	prompt(_, Old).


%PREDICATE
% islist(L) succeeds IFF "L" is a list.   This version assumes that use
% of the "|" operator is conventional.  Ie, [H|T] ==> T is a list.
islist(Var) :-
	var(Var), !, fail.
islist([]) :- !.
islist([_|_]).


%PREDICATE
% mywriteq(Term)
%  Same as writeq, with a full stop at the end and a carraige return to allow
%  later "read".

mywriteq(Term) :-
	writeq(Term),
	write('.'), nl.


%PREDICATE
% mywriteql(ListTerm)
% Same as mwriteq except that it prints a list one item per line

mywriteql([First|Rest]) :-	
	writef('[%q', [First]),		%   Open List, print first item 
	finish_mywriteql(Rest).		
mywriteql(Term) :-			%   If not a list, just "mywriteq" it
	mywriteq(Term).
finish_mywriteql([]) :-			%   Close list, print full stop
	writef('].\n').
finish_mywriteql([H|T]) :-		%   Print ',' after prev item and
	writef(',\n%q', [H]),		%   next item on next line
	finish_mywriteql(T).

%PREDICATE
%  nsetof(A, B, C)  Same as "setof" except it won't fail, returns null set
%  instead.

nsetof(A, B, C) :-
	setof(A, B, C), !.
nsetof(_, _, []).


%  assert_to_list(+Goal, -List)
%  Converts the assertions in the data base which satisfy "Goal" into a "List"
%  of goals.  "Goal" is in the form:  predicate(_, _, ..., _)

assert_to_list(G, [G|List]) :-
	functor(G, F, N),
	functor(NewG, F, N),
	retract(G), !,
	assert_to_list(NewG, List).
assert_to_list(_, []).


% list_to_assert(+List)
% Asserts each member of "List" into the data base.

list_to_assert([H|T]) :-
	assert(H), !,
	list_to_assert(T).
list_to_assert([]).
%  NIGEL's stuff which may be replaced in many cases with existing utilities

% PREDICATE
% add_item(Item, OldList, NewList)
% Adds an "Item" to OldList making NewList.  

add_item(Item, List, [Item|List]) :- !.


% member_list succeeds if all members of the first list are members of the
% second list
% **  SUBSET  **
member_list([],_):-!.
member_list([H|T],List):-
	member(H,List),!,
	member_list(T,List).

% put_list writes out a list with commas between the elements
put_list([]):-!.
put_list([X]):-!,
	write(X).
put_list([H|T]):-!,
	put_list([H]),
	write_rest(T).
write_rest([]):-!.
write_rest([H|T]):-
	writef(',%t',[H]),!,
	write_rest(T).

% remove_list removes the members of the first list from the second
% list to get the list in the third argument
% **  SET DIFFERENCE  **
remove_list(_,[],[]):-!.
remove_list(Removed_list,[H|T],New_list):-
	member(H,Removed_list),!,
	remove_list(Removed_list,T,New_list).
remove_list(Removed_list,[H|T],[H|Rest]):-!,
	remove_list(Removed_list,T,Rest).

% add_new_ones_to_list adds an item which is not in a list to that list.
% If it is already a member of the list nothing is done.
% **  UNION  **
% ***   Can be replaced by:   union([H],Old_List, NewList)   ***
add_new_ones_to_list(H,Old_list,Old_list):-
	member(H,Old_list),!.
add_new_ones_to_list(H,Old_list,[H|Old_list]).

% part_flatten takes a list of lists a returns a list
% eg [[a,b], [c,d],[c,d]]==> [a,b,c,d,c,d]
part_flatten([],[]):-!.
part_flatten([List|Others],Ans):-!,
	part_flatten(Others,Partans),
	append(List,Partans,Ans).

% removes duplicates from list in second argument to get list in
%third argument. Called with [] in first argument.
remove_duplicates(_,[],[]):-!.
remove_duplicates(Present_list,[H|T],New_list):-
      member(H,Present_list),!,
      remove_duplicates(Present_list,T,New_list).
remove_duplicates(Present_list,[H|T],[H|Rest]):-!,
      add_one_to_list(H,Present_list,Present_list1),!,
      remove_duplicates(Present_list1,T,Rest).

% counts the number of items in a list
count([],Number,Number):-!.
count([_|T],Old_numb,New_numb):-!,
    Newnumb1 is Old_numb+1,!,
    count(T,Newnumb1,New_numb).

% removes all the occurences of the item in the frst argument from the
% list in the second argument to get the list in the third argument
% Same as "delete" in UTIL:LISTUT.PL
remove(_,[],[]):-!.
remove(X,[X|T],New_list):-!,
      remove(X,T,New_list).
remove(X,[H|T],[H|Rest]):-!,
      remove(X,T,Rest).


/*
 replace1(+Old_item,+New_item,+Old_list,-New_list)
 This predicate removes one item from  list and replaces it with another.
NB It doesnot maintain the order of items i the first list.
*/
replace1(Old,New,Old_list,[New|New_list1]):-
	remove1(Old,Old_list,New_list1).


/*
remove1(+Item,+Old_list,-New_list)
 This is a special remove which :
     1) Fails if item to be removed not in list
     2) Only removes one item from list
*/
remove1(X,[X|T],T):-!.
remove1(A,[H|T],[H|Rest]):-!,
	remove1(A,T,Rest).

% checks if the members of two lists are the same
check_same_members(List1,List2):-
	check_same_members(List1,List1,List2,List2).

check_same_members([],_,[],_):-!.
check_same_members([H1|T1],List1,[H2|T2],List2):-
	member(H1,List2),
	member(H2,List1),!,
	check_same_members(T1,List1,T2,List2).

% raises the number in the first argument to the power in the second argument
%to get the number in the third argument.
to_the_power(Number,Power,Ans):-
	to_the_power(Number,Number,Power,Ans).

to_the_power(_,Number,1,Number):-!.
to_the_power(Number,Present_ans,Power,Ans):-!,
	eval(Power-1,Power1),
	eval(Number*Present_ans,Present_ans1),!,
	to_the_power(Number,Present_ans1,Power1,Ans).

