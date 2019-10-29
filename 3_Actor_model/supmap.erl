-module (supmap).
-compile([export_all]).

map(F, List,PatrialResult)->
	Self = self(),
	Pids = [spawn(fun() ->
		 Result =F(X),
		 Self ! {result, self(), Result}

		end) || X<- List],
	collect(Pids).

collect([]) -> [];
collect([Pid| Tail])->
	Result = receive
		{result, Pid,X} -> X
	end,
	[Result| collect(Tail)].


test() -> 
	map(fun(X) -> X*2 end,[1,2,3] , true).

flush()->
	receive 
			MSg -> io:format("~p~n",[MSg]), flush()
	after 0->
		ok end.