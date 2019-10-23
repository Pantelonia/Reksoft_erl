-module(task1).
-export([match/2]).

match(Pattern, Structure) when is_list(Pattern), is_list(Structure)->
match(Pattern, Structure, []);
match(_Pattern,_Structure)->
throw("Bad argument").

match([HeadP|Pattern], [HeadS|Structure], ResultList)  ->
case HeadP of
	{var, Atom} -> 
		case is_bind({bind, Atom, HeadS}, ResultList) of
			{ok, bind} -> match(Pattern, Structure,[{bind, Atom, HeadS}| ResultList]);
			{ok, binded} -> match(Pattern,Structure,ResultList);
			_ -> {false, pattern_mismatch}
		
		end;
	HeadS ->match(Pattern,Structure, ResultList);
	_ -> {false, mismatch}
end;

match([],[], ResultList) ->
	{true,lists:reverse(ResultList)}.


is_bind(Tuple, [Tuple| _Tail]) -> {ok,binded};
is_bind({bind, Atom, NewValue},[{bind, Atom,Value}|_Tail]) -> {error,tryoverride};
is_bind(Tuple,[_Tuple|Tail]) -> is_bind(Tuple, Tail);
is_bind(Tuple, []) -> {ok, bind}.