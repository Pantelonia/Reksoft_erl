%%%-------------------------------------------------------------------
%% @doc simple public API
%% @end
%%%-------------------------------------------------------------------

-module(simple_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->

	 Dispatch = cowboy_router:compile([
            {'_', [
            	{"/", simple_handler, []},
            	{"/home", simple_handler, init},
            	{"/home/:goodid",simple_handler, bind}
            ]}
        ]),

    
    {ok, _} = cowboy:start_clear(http,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch},
        middlewares => [
        cowboy_router,
        simple_mware,
        cowboy_handler]
        }
        ),    

    simple_sup:start_link().

stop(_State) ->
    ok.

%% internal functions