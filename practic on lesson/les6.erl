-module(les6).
-behaviour (gen_event).
-export([init/1, handle_event/2]).

init( Init) ->
	{ok, [Init]}.
handle_event(Event, State) ->
	io:format("~p - Another handler~n",[{Event,State}]),
	{ok, [Event|State]}.

% gen_event--логирование
% gen statem, gen_fsm  принятие покутов и расфосовка их по обработчикам
% gen_server -- anywhere