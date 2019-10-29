-module(task2).
-export([get_value/2]).

get_value(List, Key) ->
	get_value(List, Key, []).

get_value([], Key, Result) -> 
	lists:reverse(Result);

get_value([{Arg, Value}| Tail], Key, Result) ->
	case Arg of
		Key -> get_value(Tail, Key,[Value|Result]);
		_ -> get_value(Tail, Key, Result)
			
	end.


	% get_value(Tail, Key, [Value|Result]);



