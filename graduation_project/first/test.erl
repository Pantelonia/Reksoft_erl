-module(test).
-export([main/0]).
main() ->
    {ok,[[Name]]} = init:get_argument(sname),
    application:ensure_all_started(first),
   {ok, Port} = application:get_env(first, port),
    io:format("Welcame to our app ~p! Your port ~p\n", [Name, Port]).
%%    init:stop().