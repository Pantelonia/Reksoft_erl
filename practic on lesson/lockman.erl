-module(lockman).
-behaviour(gen_server).

%%----------------------------------------------------------------------------
%% BEHAVIOUR EXPORTS
%%----------------------------------------------------------------------------
-export([
  init/1,
  terminate/2,
  code_change/3,
  handle_call/3,
  handle_cast/2,
  handle_info/2
]).

%%----------------------------------------------------------------------------
%% PUBLIC API EXPORTS
%%----------------------------------------------------------------------------
-export([
  wait/2,
  fire/2,
  acquire/3,
  release/3,
  start_link/0
]).

%%----------------------------------------------------------------------------
%% TEST API EXPORTS
%%----------------------------------------------------------------------------
-export([
  test_acquire_release/0,
  test_wait_fire/0
]).

%%----------------------------------------------------------------------------
%% STRUCTURES
%%----------------------------------------------------------------------------
-record(lock, {
  key,
  from,
  queue
}).

-record(event, {
  key,
  waiting
}).

-record(state, {
  locks = [],
  events = []
}).



do_monitor(State,Server_pid)->
  
    receive 
      {monitor, Pid} ->
         Ref = erlang:monitor(process, Pid),
         do_monitor([{Pid, Ref}|State],Server_pid);

      {demonitor, Pid} ->
        {value, {Pid, _Ref}, NewState} = lists:keytake(Pid, 1, State),
          do_monitor(NewState, Server_pid);

      {'Down', Ref, process, Pid, Reason}->
        gen_server:call(Server_pid, {spawn_down, Pid}),
         NewState = lists:delete({Pid, Ref}, State),
        do_monitor(NewState,Server_pid)
    end.


%%----------------------------------------------------------------------------
%% PUBLIC API
%%----------------------------------------------------------------------------
wait(P, Atom) ->
  gen_server:call(P, {wait, Atom}, infinity).

fire(P, Atom) ->
  gen_server:cast(P, {fire, Atom}).

acquire(P, Atom, Pid_monitor) ->
  Pid_monitor ! {monitor, P},
  gen_server:call(P, {acquire, Atom}, infinity).

release(P, Atom, Pid_monitor) ->
  Pid_monitor ! {demonitor, P},
  gen_server:cast(P, {release, Atom, self()}).

start_link() ->
  gen_server:start_link(?MODULE, [], []).

%%----------------------------------------------------------------------------
%% LIFECYCLE
%%----------------------------------------------------------------------------
init([]) ->
  {ok, #state{}}.

init_monitor(Server_pid)->
  spawn(?MODULE, do_monitor, [[], Server_pid]).

terminate(_Reason, _State) ->
  ok.

code_change(_, State, _) ->
  {ok, State}.

%%----------------------------------------------------------------------------
%% HANDLERS
%%----------------------------------------------------------------------------
handle_call({acquire, Key}, From, #state{locks = Locks} = State) ->
  case lists:keyfind(Key, #lock.key, Locks) of
    false ->
      Lock = #lock{key = Key,
                   from = From,
                   queue = queue:new()},
      {reply, ok, State#state{locks = [Lock|Locks]}};
    #lock{key = Key, queue = Waiting} = Lock ->
      UpdatedQueue = queue:in(From, Waiting),
      NewLocks = lists:keyreplace(Key, #lock.key, Locks,
                                  Lock#lock{queue = UpdatedQueue}),
      {noreply, State#state{locks = NewLocks}}
  end;

handle_call({wait, Key}, From, #state{events = Events} = State) ->
  case lists:keytake(Key, #event.key, Events) of
    false ->
      Event = #event{key = Key,
                     waiting = [From]},
      {noreply, State#state{events = [Event|Events]}};
    {value, #event{key = Key, waiting = Waiting} = Event, NewEvents} ->
      NewEvent = Event#event{waiting = [From|Waiting]},
      {noreply, State#state{events = [NewEvent|NewEvents]}}
  end;
handle_call(_, _From, State) ->
  {reply, {error, wrong_request}, State}.

handle_cast({fire, Key}, #state{events = Events} = State) ->
  case lists:keytake(Key, #event.key, Events) of
    false ->
      {noreply, State};
    {value, #event{key = Key, waiting = Pids}, NewEvents} ->
      [gen_server:reply(Pid, ok) || Pid <- Pids],
      {noreply, State#state{events = NewEvents}}
  end;
handle_cast({release, Key, Pid}, #state{locks = Locks} = State) ->
  case lists:keytake(Key, #lock.key, Locks) of
    false ->
      {noreply, State};
    {value, #lock{key = Key, from = {Pid, _}} = Lock, NewLocks} ->
      case queue:out(Lock#lock.queue) of
        {{value, Client}, NewQueue} ->
          gen_server:reply(Client, ok),
          NewLock = Lock#lock{
            from = Client,
            queue = NewQueue
          },
          {noreply, State#state{locks = [NewLock|NewLocks]}};
        {empty, _Q} ->
          {noreply, State#state{locks = NewLocks}}
      end;
    {value, {Key, _, _}} ->
      {noreply, State}
  end;
handle_cast(_, State) ->
  {noreply, State};


handle_cast({spawn_down, Pid}, #state{locks = Locks} = State)->

    case [{Pid1, Tag} || #lock{from = {Pid1, Tag}} <- State#state.locks, Pid1 == Pid] of
    [] ->
      {noreply, State};
    [PidKey] ->
      case lists:keytake(PidKey, #lock.from, Locks) of
          false ->
              {noreply, State};
          {value, #lock{from = PidKey} = Lock, NewLocks} ->
              case queue:out(Lock#lock.queue) of
                {{value, Client}, NewQueue} ->
                    gen_server:reply(Client, ok),
                    NewLock = Lock#lock{
                    from = Client,
                    queue = NewQueue
                    },
                    {noreply, State#state{locks = [NewLock|NewLocks]}};
                {empty, _Q} ->
                    {noreply, State#state{locks = NewLocks}}
              end;
          {value, {_, PidKey, _}} ->
              {noreply, State}
        end
  end.




handle_info(_, State) ->
  {noreply, State}.

%%----------------------------------------------------------------------------
%% TESTS
%%----------------------------------------------------------------------------

test_acquire_release() ->
  {ok, LockManager} = lockman:start_link(),
  [spawn(
    fun() ->
      timer:sleep(rand:uniform(10)),
      ok = lockman:acquire(LockManager, lock),
      io:format("Do! ~p~n", [I]),
      timer:sleep(rand:uniform(10) * 1000),
      lockman:release(LockManager, lock)
    end
  ) || I <- lists:seq(1, 10)].

test_wait_fire() ->
  {ok, LockManager} = lockman:start_link(),
  [spawn(
    fun() ->
      ok = lockman:wait(LockManager, a),
      io:format("Do! ~p~n", [I])
    end
  ) || I <- lists:seq(1, 10)],
  timer:sleep(5000),
  lockman:fire(LockManager, a).
