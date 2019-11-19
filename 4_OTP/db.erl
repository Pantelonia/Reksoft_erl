-module(db).
-behaviour(gen_server).
-export([init/1,handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {enty = []}).


new(Name) ->
    gen_server:start_link({local, Name}, ?MODULE, [], []).

find(Key)->
    gen_server:call(Name, {find, Key}).

delete(Name)->
    gen_server:call(Name,delete).

delete(Name, Key)->
    gen_server:cast(Name,{delete, Key}).
 
delete_all(Name)->
    gen_server:cast(Name, delete_all).

insert(Name, Key, Value) ->
    gen_server:cast(Name, {insert, Key, Value}).




init()->
    {ok, #table}.


handle_call({find, Key}, _From, #state{record = DB} = State)->
    {reply, find_interal(Key, DB), State}.

handle_call(delete, _From, State)->
   {stop,delete, deleted, State}.

handle_cast({delete, Key}, #state{record = DB} = State)->
    NewDB =  [{K, Value}|| {K,Value}<- DB, K/= Key ].
    NewState = #state[record = NewDB],
    {noreply, NewState}.

handle_cast(delete_all,_State)->
    NewState = #state,
    {noreply, NewState}.
    

handle_cast({insert, Key, Value}, #state{enty = DB})->
    NewDB = [{K,V}|| {K,V}<- DB, K /= Key],
    NewState = #state{record =NewDB},
    {noreply, NewState}.
    

        

find_interal(Key, [{Key, Value}|DB])->
    {ok, Value};
find_interal(Key,[{_DifKey, _Value}|DB]) ->
    find_interal(Key,DB).
find(_Key, [])->
    not_found.
    