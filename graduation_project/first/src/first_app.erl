%%%-------------------------------------------------------------------
%% @doc first public API
%% @end
%%%-------------------------------------------------------------------

-module(first_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
            {'_', [{"/", first_handler, []}]}
        ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
        ),    

    first_sup:start_link().

stop(_State) ->
    ok.

%% internal functions