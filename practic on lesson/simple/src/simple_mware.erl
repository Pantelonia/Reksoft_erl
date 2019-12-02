-module(simple_mware).
-behaviour(cowboy_middleware).
-export([execute/2]).

execute(Reaquest, Env) ->
	Headers =  cowboy_req:headers(Reaquest),
	case maps:get(
		<<"x-my-tokken">>,
		Headers, 
		<<"notoken">>) of 
	<<"notoken">> ->
		Req2 = cowboy_req:reply(401,#{}, <<"undf">>,Reaquest),
		{stop, Req2};
		_ -> 
			{ok, Reaquest, Env}
	end.

