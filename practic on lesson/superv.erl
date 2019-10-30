-module(superv).

-compile(export_all).

loop_worker() ->
    receive
        _ -> throw(die)
    after 1000 ->
        throw(tired_of_living)
    end.

loop_supervisor(0) ->
    too_many;
loop_supervisor(Retries) ->
    %process_flag(trap_exit, true),
    Pid = spawn_monitor(fun loop_worker/0),
    receive
        {'DOWN', _, _, _, _}=Msg ->
            io:format("Got message: ~p~n", [Msg]),
            loop_supervisor(Retries - 1);
        Msg ->
            io:format("Got bad message: ~p~n", [Msg])
    end.

start() ->
    Pid = spawn(fun() -> loop_supervisor(2) end),
    timer:sleep(500).%,
    %%exit(Pid, kill).
