-module(my_server).
-compile([export_all]).

call(Pid, Msg)->
	Ref = erlang:monitor(process, Pid),
	Pid ! {sync, self(), Ref, Msg},
	receive 
		{Ref, Reply}->
			erlang:demonitor(Ref, [flush]),
			Reply;
		{'Down', Ref, process, Pid, Reason}->
			erlang:error(Reason)
	after 5000 ->
		erlang:error(timeout)
	end.

cast(Pid, Msg)->
	Pid ! {async, Msg},
	ok.

reply({Pid, Ref}, Reply)->
		Pid ! {Ref, Reply}.

init(Module, InitialState)->
		loop(Module,Module:init(InitialState)).

loop(Module, State) ->
		receive
			{async, Msg}->
					loop(Module, Module: handle_cast(Msg, State));
			{sync, Msg} ->
					loop(Module, Module: handle_cast(Msg, {Pid,Ref}, State))
		end.
