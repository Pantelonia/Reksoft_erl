%%%-------------------------------------------------------------------
%%% @author Paulo
%%% @copyright (C) 2019, <Recksoft>
%%% @doc
%%%
%%% @end
%%% Created : 21. Нояб. 2019 20:52
%%%-------------------------------------------------------------------
-module(atm).
-author("User").

-behaviour(gen_statem).

%% API
-export([
start_link/1,
insert_card/1,
push_button/1
]).

%% gen_statem callbacks
-export([
  init/1,
  waiting_card/3,
  waiting_pin/3,
  withdraw_from_balance/3,
  handle_event/4,
  terminate/3,
  code_change/4,
  callback_mode/0
]).

-define(SERVER, ?MODULE).

-record(account, {
  card,
  pin,
  balance = 0
}).
-record(state, {
  accounts,
  active_user = nil,
  buffer =[]
}).

%%%===================================================================
%%% API
%%%===================================================================

start_link(Accounts) ->
  gen_statem:start_link({local, ?MODULE}, ?MODULE, Accounts, []).

insert_card(Card)->
    gen_statem:call(?MODULE, {insert, Card}).
    
push_button(enter)->
    gen_statem:call(?MODULE, {button, enter});

push_button(Button)->
    gen_statem:cast(?MODULE, {button, Button }).


%%===================================================================
%% gen_statem callbacks
%%===================================================================


init(Accounts) ->
  {ok, waiting_card, #state{accounts = Accounts}}.


callback_mode() ->
  state_functions.

waiting_card({call, From}, {insert, Card}, #state{accounts = Accounts}) ->
    case lists:keyfind(Card, #account.card, Accounts) of        
      false ->
        {keep_state_and_data, [{reply, From, {error, "ATM doesn't servise this card"}}]};
      ActiveUser ->
        NewState = #state{accounts = Accounts, active_user = ActiveUser},
        {next_state, waiting_pin, NewState, [{reply, From, {ok, "Input your pin"}}, 
        {state_timeout, 10000, timeout}]}
       
    end;

waiting_card({call, From}, {button, _Button}, _State) ->
  {keep_state_and_data, [{reply, From, ok}]};

waiting_card(_EventType, _EventContent, _State) ->
  keep_state_and_data.



waiting_pin(state_timeout, timeout, State) ->
    io:format("Timeout~n"),
    {next_state, waiting_card, State};

% waiting_pin({call, From}, {button, enter}, #state{accounts =Accounts, active_user = ActiveUser, buffer = Buf})->
%     if
%         ActiveUser#account.pin == lists:reverse(Buf) ->
%             NewState = state#{ accounts = Accounts, active_user = ActiveUser },            
%             io:format("Correct pin ~p~n", [ActiveUser#account.pin]),
%             keep_state_and_data;
%         true ->
%             NewState = #state{accounts = Accounts},
%             {next_state, waiting_card, NewState, [{reply, From, {error, "Wrong pin, get your card"}}, {state_timeout, cancel}]}

%     end

waiting_pin({call, From}, {button, enter}, #state{accounts = Accounts, active_user = User, buffer = Buf})->
  Pin = lists:reverse(Buf),  
  if
      User#account.pin == Pin ->
            NewState = #state{
              accounts = Accounts,
              active_user = User
            },
            {next_state, withdraw_from_balance, NewState, [{reply, From, {ok, "Valid pin, enter the sum to withdraw"}}]};
      true ->
            NewState = #state{
              accounts = Accounts
            },
            {next_state, waiting_card, NewState, [{reply, From, {error, "Wrong pin, get your card"}}]}
  end;

waiting_pin(cast,{button, Button}, #state{accounts = Accounts, active_user = User, buffer = Buf} )->
    NewState = #state{accounts = Accounts, active_user = User, buffer = [Button +48| Buf]},
    {keep_state, NewState,
    [{state_timeout, 10000, timeout}]};



waiting_pin(_EventType, _EventContent, _State) ->
    keep_state_and_data.


withdraw_from_balance({call, From}, {button, enter}, #state{accounts = Accounts,  active_user = User, buffer = Buf})->
  Sum = lists:reverse(Buf),
  if
    Sum > User#account.balance ->
      NewState = #state{accounts = Accounts, active_user = User},
      {keep_state, NewState,[{reply, From, {error, "Your balance havn't this sum"}}]};
    true ->
      NewBalance = User#account.balance - sum,
      {_value, _tuple, NewAccounts} = lists:keytake(User#account.card, #account.card, Accounts),
      NewState  = [{card = User#account.card, pin = User#account.pin, balance = NewBalance}| NewAccounts],
      {next_state, waiting_card, NewState, [{reply, From, {ok, "Get your money and card"}}]}
  end;

withdraw_from_balance(cast, {button, Button}, #state{accounts = Accounts,  active_user = User, buffer = Buf})->
  NewState = #state{accounts = Accounts, active_user = User, buffer = [Button +48| Buf]},
  {keep_state, NewState};

withdraw_from_balance(_EventType, _EventContent, _State) ->
  keep_state_and_data.

  

    

% print_card(state_timeout, timeout, {State, _Card})->
%     io:format("Timeout~n", []),
%     {next_state, waiting_card, State};

% print_card(_EventType, _EventContent, {State, Card} )->
%         #state{accounts = Accounts} = State,
%         Account = lists:keyfind(Card, #account.card, Accounts),
%         Balance = Account#account.balance,
%         io:format("~p~n", [Balance]),
%         {next_state, waiting_card, State}.



handle_event(_EventType, _EventContent, _StateName, State) ->   
  NextStateName = the_next_state_name,
  {next_state, NextStateName, State}.


terminate(_Reason, _StateName, _State) ->
  ok.
code_change(_OldVsn, StateName, State, _Extra) ->
  {ok, StateName, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
% rr(atm).
% Ac1 = #account{card =123, pin = "123", balance = 321}.
% Ac2 = #account{card =1234, pin = "1234", balance = 4321}.
% Accounts = [Ac1, Ac2].
% PidATM = atm:start_link(Accounts).
% atm:insert_card(123).
% atm:push_button(1).