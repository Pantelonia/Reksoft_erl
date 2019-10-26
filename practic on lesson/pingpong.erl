-module(pingpong).
-export([start/0, ping/3, pong/2]).

start()->
 Pid = spawn(?MODULE, pong, [0,0]),
 Pid1 = spawn(?MODULE, ping,[Pid, 0, 0]),
 {Pid,Pid1}.

ping(Pid,Counter, Statistic)->
	Pid ! {ping, self()},
	timer:sleep(3000),

	receive 
		{pong, _}->
			if
				Counter<10 ->
					CounterNew = Counter +1;
				true -> 
				io:fwrite("~p~n",[Counter]),	
				CounterNew = 0
								
			end,
			StatisticNew = Statistic +1,
			ping(Pid, CounterNew, StatisticNew);

		status -> io:fwrite("~p~n", [Statistic]);

		_  -> ping(Pid,Counter, Statistic)
	
	end.

pong(Counter, Statistic)->
	timer:sleep(3000),
	receive 
		{ping, Pid}->
			if
				Counter<20 ->
					CounterNew = Counter +1;
				true ->
				io:fwrite("~p~n",[Counter]),
				 CounterNew = 0
								
			end,
			StatisticNew = Statistic +1,
			Pid ! {pong, self()},
			pong( CounterNew, StatisticNew);

		status -> io:fwrite("~p~n", Statistic);

		_  -> pong(Counter, Statistic)
	
	end.