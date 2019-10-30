-module(dmap).

-compile(export_all).

map(F, List, PartialResult, Timeout) ->
    Self = self(),
    Ref = make_ref(),
    Pid = spawn_link(fun() -> Self ! {map_result, Ref, do_map(F, List, PartialResult, Timeout)} end),
    receive
        {map_result, Ref, Result} -> Result;
        {'EXIT', Pid, _} = Msg -> self() ! Msg, error
    after Timeout ->
        exit(Pid, kill),
        {error, timeout}
    end.

do_map(F, List, PartialResult, Timeout) ->
    Self = self(),
    process_flag(trap_exit, PartialResult),
    Pids = [ spawn_link(fun() ->
        Result = F(X),
        Self ! {result, self(), Result}
    end) || X <- List ],
    collect(Pids, Timeout).

collect([], _) ->
    io:format("~nCOLLECTED~n"),
    [];
collect([NextPid|Tail], Timeout) ->
    Result = receive
        {result, NextPid, X} -> X;
        {'EXIT', NextPid, Reason} -> {error, Reason}
    after Timeout -> {error, timeout}
    end,
    [Result|collect(Tail, Timeout)].

test() ->
    process_flag(trap_exit, true),
    spawn_link(fun() -> timer:sleep(100), throw(worker_dies) end),
    map(fun(X)->timer:sleep(1000+random:uniform(1000)), 10/X end, [1,2,3,4,5,6,7,8,9,0,10,11,12,13], true, 10).
