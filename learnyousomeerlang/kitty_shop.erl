-module(kitty_shop).
-export([start_link/0, order_cat/4, return_cat/2, close_shop/1]).
-record(cat, {name , color = green , desctiption }).

start_link() -> spawn_link(fun init/0).

order_cat(Pid, Name, Color, Description) ->
	my_server:call(Pid, {order,Name, Color,Description}).

return_cat(Pid, Cat = #cat{})->
	Pid !{return, Cat},
	ok.
close_shop(Pid)->
	my_server:call(Pid, terminate).