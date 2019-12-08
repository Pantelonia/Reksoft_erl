erlang_demo
=====

A Cowboy OTP application

Build
-----
start back command

erl -sname Alex -erlang_demo port 8081 -erlang_demo back 1488 -erlang_demo user 8091 -pa "C:\Users\User\Desktop\Reksoft_erl\graduation_project\erlang_demo\_build\default\lib\erlang_demo\ebin" -pa "C:\Users\User\Desktop\Reksoft_erl\graduation_project\erlang_demo\_build\default\lib\cowboy\ebin" -pa "C:\Users\User\Desktop\Reksoft_erl\graduation_project\erlang_demo\_build\default\lib\cowlib\ebin" -pa "C:\Users\User\Desktop\Reksoft_erl\graduation_project\erlang_demo\_build\default\lib\ranch\ebin" -s test main