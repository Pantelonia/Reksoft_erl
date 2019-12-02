-module(cb).
-compile([export_all]).

loop() -> timer: sleep (1000), io:format("tick~n"), loop().

create_proc() ->
	Self = self(),
	spawn(fun() ->
		ets: new(mytable, [public, named_table, {heir, Self, heritage}]),
		loop() end).