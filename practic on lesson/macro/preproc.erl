-module(preproc).
-export([foo/1]).
-define(SOME_VALUE, 1).
-include("$MACRO_PATH/macr1.hrl").

-define(b2i(T), binary_to_integer(t)).
foo(B)->
    ?b2i(B).