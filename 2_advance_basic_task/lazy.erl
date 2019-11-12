-module(lazy).
-compile([export_all]).
lazy_map(Fun, [Head|Tail]) ->
	fun() ->
		[Fun(Head)|lazy_map(Fun, Tail)]
	end;
lazy_map(_,_)->
	fun() ->
		[]
	end.



lazy_fold(Fun, Acc, [Head|Tail])->
	fun() ->
		NewAcc = Fun(Head, Acc),
		[NewAcc | lazy_fold(Fun, NewAcc, Tail)]
	end;

lazy_fold(_,_,_) ->
	fun() ->
		[]
	end.
lazy_filter(Pred, [Head|Tail])->
	case Pred(Head) of 
		true ->
			[Head|lazy_filter(Pred, Tail)];
		false ->
			[lazy_filter(Pred, Tail)]
	end;
lazy_filter(_,_)->
	fun() ->
		[]
	end.


test_map()->
	Fun = fun(X) ->
			X*X
		end,
	List = lists:seq(1, 10),
	lazy_map(Fun, List).

test_fold()->
	Fun = fun(X,Y) ->
			X+Y
		end,
	List = lists:seq(1, 10),
	lazy_fold(Fun, 0, List).

conc(Lazy)->
	case Lazy() of
	[H|T] ->
		[H| conc(T)];	
	_ ->
		 []
	end.