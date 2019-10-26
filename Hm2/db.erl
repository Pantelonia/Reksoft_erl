-module(db).
-export([new/0, destroy/1, write/3, delete/2, read/2, match/2]).

new() -> [].

destroy(_List) -> ok.

write(Key, Element, DB) ->
	delete(Key, Element),
	[{Key,Element}|DB].


delete(Key, DB) ->	delete(Key, DB, []).

delete(Key, [{Key, _Element} | DB], ResultDB) -> 
	DB ++ reverse(ResultDB);

delete(Key, [{Key1, Element}| DB], ResultDB) ->
	delete(Key, DB, [{Key1, Element}|ResultDB]);
% delete(_Key,[], _ResultDb) -> 


reverse(DB)->
	reverse(DB,[]).

reverse([], NewDB) -> NewDB;

reverse([Head|Tail], NewDB) when is_list(Tail)->
	reverse(Tail,[Head|NewDB]).

read(Key, [{Key,Element}| _DB]) ->
	{ok, Element};

read(Key, [{_Key,_Element}| DB] )->
	read(Key,DB).


match(Element, DB)-> match(Element,DB, []).
match(_Element, [], Acc)-> reverse(Acc);
match(Element, [{Key,Element}|DB], Acc) when is_list(DB)->
	match(Element, DB, [Key|Acc]);
match(Element, [{_Key,_Element}|DB], Acc)->
	match(Element,DB, Acc).




	



