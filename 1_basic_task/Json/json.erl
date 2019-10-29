-module(json).
-compile([export_all]).

map(_, []) -> [];
map(F, [H|T]) -> [F(H)|map(F, T)].

% inc(X) -> X+1.
% decr(X) -> X -1.

test()->
new([{key1,[{key2,val},{key3,[val1,val2,val3]}]}]).

new(Object) ->
	{obj, Object}.

read(KeySpec, {obj,[{ }]})->
	Struct =[KeySpec|Object],
	map( parse(Struct), Struct).

parse([KeySpec|Value])->
	parse(KeySpec, Value).

parse(Key,{ Key, Value})->
	Value;
parse(KeySpec, {_Key, Value})->
	if
		is_list(Value) ->
			parse(KeySpec, Value);
		 true-> not_found
	end.
