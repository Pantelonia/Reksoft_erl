-module(simple_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Request, [] = State) ->

	io:format("~p~n", [State]),
    
   	Request2 = cowboy_req:reply(
   		200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"Response body - replace me\n">>,
        Request),
    {ok, Request2, State};

init(Request, init = State) ->
	Method  = cowboy_req:method(Request), 
   
   	Request2 = cowboy_req:reply(
   		200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"HOME! ", Method/binary>>,
        Request),
    {ok, Request2, State};

 init(Request, bind = State) ->
	GoodID  = cowboy_req:binding(goodid, Request, <<"NOt bind">>),
	io:format("~p~n",  [State]),
    
   	Request2 = cowboy_req:reply(
   		200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"HOME! ", GoodID/binary>>,
        Request),
    {ok, Request2, State}.
