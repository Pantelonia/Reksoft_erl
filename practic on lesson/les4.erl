-module (les4).
-compile([export_all]).

loop_worker()->
	receive
		_ ->throw(die)
	after 1000->
		throw(tried_to_live)
	end.
loop_supervisor(0)->
	so_manny;
loop_supervisor(State) ->
	process_flag(trap_exit, true),
	Pid = spawn_link(fun loop_worker/0),
		receive
			{'EXIT',_,_} = MSG -> 
				io:format("Got Messege: ~p~n", [Msg])
				loop_supervisor(State-1);
			Msg ->
				io:format("Got Messege: ~p~n", [Msg])
			}
		end.

start()->
Pid = spawn(fun() -> loop_supervisor(2) end),
timer:sleep(500),
exit(Pid, kill).