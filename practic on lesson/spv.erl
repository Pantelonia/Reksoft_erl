-module(spv).
-behaviour (supervisor).
-export([
	init/1]).

init()-> 
	Strategy = one_to_one,
	Intensity =10,
	Period = 60,
	% Flags = {Strategy, Intensy, Period},
	Flags = #{
		stratege => Strategy,
		intensity => Intensity,
		period => Period
	}
	Childs = [{
		id => locker,
		start => {locker3, start_link, []},
		restart => permament, 
		shutdown=> brutal_kill,
		module = [],
		type=> worker
		}],
	{ok, {Flags, Childs}}.