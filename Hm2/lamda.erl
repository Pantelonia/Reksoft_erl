%%%%%%%%%%%%%
%First part %
%%%%%%%%%%%%%
F = fun Lamda([Element|T],[Element1|T1], Operation)  ->
			case T++T1 of
				[] ->
					[Operation(Element,Element1)];
				T1 ->
					throw("Second list is larger then the first");
				T2 -> 
					throw("Second list is larger then the first");
				_ -> 
					[Operation(Element,Element1)|Lamda(T,T1, Operation)]
			end
	end.



%%%%%%%%%%%%%
%Second part%
%%%%%%%%%%%%%
D = fun Lamda([{dimension, N},{dotsA, List1}, {dotsB, List2}])->
	Func = fun Distanse(PointA, PointB, N) ->
		if
			N>0 ->
				[element(N,PointA) - element(N, PointB)| Distanse(PointA,PointB, N-1)];
			true -> []
		end
	end,
	F2 = fun Loop([H | T]) ->
		case T of
			[] ->
				H*H;
			_ ->
				H*H + Loop(T)
		end
	end,
	
[math:sqrt(F2(Func(A,B,N)))||A <- List1, B <- List2]
	
end.



