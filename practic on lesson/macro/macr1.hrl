-define(my_const, 3.14).

-record(myrecord, {key = 0, value = 0}).

-compile(export_all).
new_foo() -> ':)'.
show_foo() -> ?SOME_VALUE.
