%%%-------------------------------------------------------------------
%% @doc erlang_demo public API
%% @end
%%%-------------------------------------------------------------------

-module(erlang_demo_app).

-behaviour(application).

-export([start/2, stop/1, get_h/0]).
-record(state, {pid_server}).

start(_StartType, _StartArgs) ->
    {ok, Port} = application:get_env(erlang_demo, port),
    {ok, User} = application:get_env(erlang_demo, user),
    {ok, Back} = application:get_env(erlang_demo, back),
    {ok,Pid_server} = local_back:start_link(Back, User),
    State = #state{pid_server = Pid_server},
    Dispatch = cowboy_router:compile([
            {'_', [
                {"/", erlang_demo_handler, []},
                {"/websocket", erws_handler, State}
            ]}
        ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
        ),    

    erlang_demo_sup:start_link().

stop(_State) ->
    ok.

%% internal functions

get_h() ->
    self().