-module(sup_fold).
-compile([export_all]).

fold(Func, List)->
	Self =self(),

	SpawnProc = fun( A, B)->
		spawn(fun()->
				Result = Func(A,B),
				Self !{self(), Result}
			end)
	end,

	Pids = fun Deconstruct([H|([H1|T])])->	
		case  T of
			[] ->
				[SpawnProc( H,H1)];		
			_ ->
				if 
					length(T) =:= 1 -> 
						[SpawnProc(H,H1)|SpawnProc(T, 0)];
					true ->
						[SpawnProc(H,H1)| Deconstruct(T)]
				end
		end
	end,	
	K = get_result(Pids(List),[]),
	case length(K) of
		1 -> K;
		_ -> fold(Func, K)
		
	end.
	
	
get_result([], Acc)->
	lists:reverse(Acc);
get_result([_Fist|Pids], Acc)->
	receive
        {_First, Result} ->
            get_result(Pids, [Result|Acc])
    end.



