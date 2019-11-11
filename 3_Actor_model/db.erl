-module(db).
-compile([export_all]).



new()->
	spawn(?MODULE, proc,[[]] ).

write(Key, Element, DB)->
	case erlang:is_process_alive(DB) of 
		true -> 	
			DB ! {write, self(), Key, Element},
			receive 
				Msg -> Msg
			end;
		false ->
			{error, proc_is_down}
	end. 

read(Key, DB)->
	case erlang:is_process_alive(DB) of 
		true -> 	
			DB ! {read, self(), Key},
			receive 
				Msg -> Msg
			end;
		false ->
			{error, proc_is_down}
	end. 

delete(Key, DB)->
	case erlang:is_process_alive(DB) of 
		true -> 	
			DB ! {delete, self(), Key},
			receive 
				Msg -> Msg
			end;
		false ->
			{error, proc_is_down}
	end. 


match(Element, DB)->
	case erlang:is_process_alive(DB) of 
		true -> 	
			DB ! {match, self(), Element},
			receive 
				Msg -> Msg
			end;
		false ->
			{error, proc_is_down}
	end. 


proc(State)->
	NewState = receive
			{write, From, Key, Element} -> 	
				From ! ok,	
				[{Key, Element}| State];
				

			{read, From, Key} ->
				From ! read_internal(Key, State),
				State;
			{delete, From, Key} -> 
				From ! deleted,
				delete_internal(Key, State);

			{match, From, Element}->
				From ! match_internal(Element, State),
				State
			end,
	proc(NewState).


read_internal(Key, DB) ->
	lists:keyfind(Key, 1, DB).

delete_internal(Key, DB)->
	delete_internal(Key,DB, [] ).

delete_internal(Key, [{Key, _Element}| DB], ResultDB)->
	lists:reverse(ResultDB)++ DB;
delete_internal(Key,[{Key1, Element}| DB], ResultDB)->
	delete_internal(Key, DB, [{Key1, Element}| ResultDB]);
delete_internal(_Key, [], ResultDB)->
	lists:reverse(ResultDB).

match_internal(Element, DB)-> match_internal(Element,DB, []).

match_internal(_Element, [], Acc)-> lists:reverse(Acc);

match_internal(Element, [{Key,Element}|DB], Acc) when is_list(DB)->
	match_internal(Element, DB, [Key|Acc]);
	
match_internal(Element, [{_Key,_Element}|DB], Acc)->
	match_internal(Element,DB, Acc).






