-module(les5Server).
-compile([export_all]).

loop()->
	receice
		{From, Ref, Request} ->
			Result = case Request of 
				{add, A, B}->
					timer:sleep(1000)
					{ok, A+B};
				{sub,A,B} ->
					timer:sleep(500)
					{ok, A-B};
				_ -> 
					{error, bad_req}
			end,
		From ! {reply, Ref,Result};
		Otherwise ->
			io:format("sm msg ~p", [Otherwise])
	end,
	loop().

start() ->
	spawn(les5Server, loop, []).
add(Proc, A, B) ->
	add(Proc,A, B, infinity).
add(Proc, A, B, Timer) ->
	call(Proc,{add, A,B, Timer}).

sub(Proc, A, B) ->
	sub(Proc,A, B, infinity).
sub(Proc, A, B, Timer) ->
	call(Proc,{sub, A,B, Timer}).
	 
call(Proc, Request)->
	call(Proc, Request, infinity).

call(Proc, Request, infinity)->
	Ref = make_ref().
	Proc ! {self(),Ref, Request},
		receive 

			{reply, Ref, {ok,Result}} ->
				Result;
			{reply, Ref, Otherwise} ->
				Otherwise
			
		end;

	
call(Proc, Request, Timer)->
	Ref = make_ref().

	Proc ! {self(), Ref, Request},
		receive 
			{reply, Ref, {ok,Result}} ->
				Result;
			{reply, Ref, Otherwise} ->
				Otherwise
		after Timer ->
			{error, Ref, timeout}
		end.
