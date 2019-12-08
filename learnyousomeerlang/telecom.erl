-module(telecom).
-export([start_s/1]).
start_s(Port)->
    Pid = spawn_link(fun() ->
        {ok, LSocket} = gen_tcp:listen(Port, [binary, {active, false}]),
        spawn(fun() -> acceptor(LSocket) end),
        timer:sleep(infinity)
    end),
{ok, Pid}.

acceptor(LSocket)->
    {ok, Socket}= gen_tcp:accept(LSocket),
    spawn(fun() -> acceptor(LSocket) end),
    handle(Socket).

handle(Socket)->
    inet:setopts(Socket,[{active, once}]),
    receive
        {tcp, Socket,<<"quit, _/binary">>} ->
            gen_tcp:close(Socket);
        {tcp, Socket, Msg}->
            io:format("~p~n",[Msg]),
            gen_tcp:send(Socket, Msg),
            handle(Socket)
    end.