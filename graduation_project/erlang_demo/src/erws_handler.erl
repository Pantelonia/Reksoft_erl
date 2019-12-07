%%%-------------------------------------------------------------------
%%% @author User
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. дек. 2019 0:18
%%%-------------------------------------------------------------------
-module(erws_handler).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-record(state, {pid_server}).


init(Req, State) ->
  {cowboy_websocket, Req, State}.

websocket_init(#state{pid_server = PidServer} = State) ->
  PidServer ! {websocket, self()},
  register(websocket, self()),
  {[{text, <<"Hello!">>}], State}.

websocket_handle({text, Msg}, State) ->
  io:format("Got: ~p~n", [Msg]),
  {[], State};

websocket_handle(_Data, State) ->
  {[], State}.

websocket_info({send, Msg}, State) ->
  {[{text, Msg}], State};

websocket_info(_Info, State) ->
  {[], State}.